import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';
import { IsString } from 'class-validator';
import {
  Body,
  Controller,
  Post,
  UseGuards,
  Module,
} from '@nestjs/common';
import { InternalApiKeyGuard } from '../common/internal-api-key.guard';

// ─── DTO ────────────────────────────────────────────────────
export class UpsertStudentDto {
  @IsString() externalStudentId: string;
  @IsString() studentCode: string;
  @IsString() name: string;
}

export class LinkStudentDto {
  @IsString() parentPhone: string;
  @IsString() studentCode: string;
}

// ─── Service ────────────────────────────────────────────────
@Injectable()
export class StudentsService {
  constructor(private readonly prisma: PrismaService) {}

  async upsertStudent(dto: UpsertStudentDto) {
    return this.prisma.student.upsert({
      where: { externalStudentId: dto.externalStudentId },
      create: dto,
      update: { name: dto.name, studentCode: dto.studentCode },
    });
  }

  async linkStudentToParent(dto: LinkStudentDto) {
    const [parent, student] = await Promise.all([
      this.prisma.parent.findUnique({ where: { phone: dto.parentPhone } }),
      this.prisma.student.findUnique({ where: { studentCode: dto.studentCode } }),
    ]);
    if (!parent || !student) {
      return { ok: false, reason: 'Parent or student not found' };
    }
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
