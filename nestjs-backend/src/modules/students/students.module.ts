import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../common/prisma.service';
import { IsString, IsOptional } from 'class-validator';
import {
  Body,
  Controller,
  Post,
  UseGuards,
  Module,
} from '@nestjs/common';
import { InternalApiKeyGuard } from '../../common/internal-api-key.guard';

// ─── DTO ────────────────────────────────────────────────────
export class UpsertStudentDto {
  @IsString() externalStudentId: string;
  @IsString() studentCode: string;
  @IsString() name: string;
  @IsOptional() @IsString() dormitory?: string;
  @IsOptional() @IsString() roomNumber?: string;
  // รับ snake_case จาก Postman / FastAPI
  @IsOptional() @IsString() room_number?: string;
}

export class LinkStudentDto {
  // เลขบัตรประชาชนผู้ปกครอง (= pid จาก ThaID) ใช้จับคู่กับนักศึกษา
  @IsString() parentCitizenId: string;
  @IsString() studentCode: string;
}

// ─── Service ────────────────────────────────────────────────
@Injectable()
export class StudentsService {
  constructor(private readonly prisma: PrismaService) {}

  async upsertStudent(dto: UpsertStudentDto) {
    const room = dto.roomNumber ?? dto.room_number;
    return this.prisma.student.upsert({
      where: { externalStudentId: dto.externalStudentId },
      create: {
        externalStudentId: dto.externalStudentId,
        studentCode: dto.studentCode,
        name: dto.name,
        dormitory: dto.dormitory,
        roomNumber: room,
      },
      update: {
        name: dto.name,
        studentCode: dto.studentCode,
        dormitory: dto.dormitory,
        roomNumber: room,
      },
    });
  }

  async linkStudentToParent(dto: LinkStudentDto) {
    const student = await this.prisma.student.findUnique({
      where: { studentCode: dto.studentCode },
    });
    if (!student) {
      return { ok: false, reason: 'Student not found' };
    }

    // ผู้ปกครองอาจยังไม่เคย login ThaID — สร้าง stub ด้วย citizenId ไว้ก่อน
    // name + thaidSub จะถูกเติมตอน login ThaID ครั้งแรก
    const parent = await this.prisma.parent.upsert({
      where: { citizenId: dto.parentCitizenId },
      create: { citizenId: dto.parentCitizenId, name: '' },
      update: {},
    });

    await this.prisma.parentStudentMapping.upsert({
      where: { parentId_studentId: { parentId: parent.id, studentId: student.id } },
      create: { parentId: parent.id, studentId: student.id },
      update: {},
    });
    return { ok: true };
  }
}

// ─── Controller ─────────────────────────────────────────────
@Controller('internal/students')
@UseGuards(InternalApiKeyGuard)
export class StudentsController {
  constructor(private readonly service: StudentsService) {}

  @Post('upsert')
  upsert(@Body() dto: UpsertStudentDto) {
    return this.service.upsertStudent(dto);
  }

  @Post('link')
  link(@Body() dto: LinkStudentDto) {
    return this.service.linkStudentToParent(dto);
  }
}

// ─── Module ─────────────────────────────────────────────────
@Module({
  providers: [StudentsService],
  controllers: [StudentsController],
})
export class StudentsModule {}
