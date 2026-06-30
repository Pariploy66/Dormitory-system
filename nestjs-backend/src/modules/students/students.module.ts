import {
  Body,
  Controller,
  Injectable,
  Module,
  Post,
  UseGuards,
} from '@nestjs/common';
import { Type } from 'class-transformer';
import {
  IsArray,
  IsIn,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { PrismaService } from '../../common/prisma.service';
import { InternalApiKeyGuard } from '../../common/internal-api-key.guard';

type StudentStatus = 'ACTIVE' | 'GRADUATED' | 'MOVED_OUT';
type Relationship = 'FATHER' | 'MOTHER' | 'GUARDIAN' | 'OTHER';

// ─── DTOs ────────────────────────────────────────────────────
export class UpsertStudentDto {
  @IsString() externalStudentId: string;
  @IsString() studentCode: string;
  @IsString() name: string;
  @IsOptional() @IsString() dormitory?: string;
  @IsOptional() @IsString() roomNumber?: string;
  @IsOptional() @IsString() room_number?: string; // snake_case from Postman/FastAPI
  @IsOptional() @IsIn(['ACTIVE', 'GRADUATED', 'MOVED_OUT'])
  status?: StudentStatus;
}

export class GuardianDto {
  // เลขบัตรประชาชนผู้ปกครอง (= pid จาก ThaID) ใช้จับคู่กับนักศึกษา
  @IsString() parentCitizenId: string;
  @IsString() studentCode: string;
  @IsOptional() @IsIn(['FATHER', 'MOTHER', 'GUARDIAN', 'OTHER'])
  relationship?: Relationship;
}

export class RegistrySyncDto {
  @IsArray() @ValidateNested({ each: true }) @Type(() => UpsertStudentDto)
  students: UpsertStudentDto[];

  @IsArray() @ValidateNested({ each: true }) @Type(() => GuardianDto)
  guardians: GuardianDto[];
}

// ─── Service ─────────────────────────────────────────────────
@Injectable()
export class StudentsService {
  constructor(private readonly prisma: PrismaService) {}

  async upsertStudent(dto: UpsertStudentDto) {
    const room = dto.roomNumber ?? dto.room_number;
    const status = dto.status ?? 'ACTIVE';
    const leftAt = status === 'ACTIVE' ? null : new Date();
    return this.prisma.student.upsert({
      where: { externalStudentId: dto.externalStudentId },
      create: {
        externalStudentId: dto.externalStudentId,
        studentCode: dto.studentCode,
        name: dto.name,
        dormitory: dto.dormitory,
        roomNumber: room,
        status,
        leftAt,
      },
      update: {
        name: dto.name,
        studentCode: dto.studentCode,
        dormitory: dto.dormitory,
        roomNumber: room,
        status,
        leftAt,
      },
    });
  }

  /** Link a guardian (by citizen ID) to a student in the registry. */
  async linkGuardian(dto: GuardianDto) {
    const student = await this.prisma.student.findUnique({
      where: { studentCode: dto.studentCode },
    });
    if (!student) return { ok: false, reason: 'Student not found' };

    await this.prisma.parentStudentRegistry.upsert({
      where: {
        parentCitizenId_studentId: {
          parentCitizenId: dto.parentCitizenId,
          studentId: student.id,
        },
      },
      create: {
        parentCitizenId: dto.parentCitizenId,
        studentId: student.id,
        relationship: dto.relationship ?? 'GUARDIAN',
      },
      update: { relationship: dto.relationship ?? 'GUARDIAN' },
    });
    return { ok: true };
  }

  /** Bulk-load the whole registrar registry (students + guardians) in one call. */
  async syncRegistry(dto: RegistrySyncDto) {
    for (const s of dto.students) await this.upsertStudent(s);
    let linked = 0;
    for (const g of dto.guardians) {
      const r = await this.linkGuardian(g);
      if (r.ok) linked++;
    }
    return { ok: true, students: dto.students.length, guardiansLinked: linked };
  }
}

// ─── Controllers ─────────────────────────────────────────────
@Controller('internal/students')
@UseGuards(InternalApiKeyGuard)
export class StudentsController {
  constructor(private readonly service: StudentsService) {}

  @Post('upsert')
  upsert(@Body() dto: UpsertStudentDto) {
    return this.service.upsertStudent(dto);
  }

  @Post('guardian')
  guardian(@Body() dto: GuardianDto) {
    return this.service.linkGuardian(dto);
  }
}

@Controller('internal/registry')
@UseGuards(InternalApiKeyGuard)
export class RegistryController {
  constructor(private readonly service: StudentsService) {}

  // Bulk-load the registrar file (students + guardians) in one request.
  @Post('sync')
  sync(@Body() dto: RegistrySyncDto) {
    return this.service.syncRegistry(dto);
  }
}

// ─── Module ──────────────────────────────────────────────────
@Module({
  providers: [StudentsService],
  controllers: [StudentsController, RegistryController],
})
export class StudentsModule {}
