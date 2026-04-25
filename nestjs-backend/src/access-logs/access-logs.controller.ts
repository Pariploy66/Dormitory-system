import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { IsString, IsIn, IsDateString } from 'class-validator';
import { AccessLogsService, IngestPayload } from './access-logs.service';
import { InternalApiKeyGuard } from '../common/internal-api-key.guard';

class IngestDto implements IngestPayload {
  @IsString() externalStudentId: string;
  @IsDateString() accessTime: string;
  @IsIn(['IN', 'OUT']) type: 'IN' | 'OUT';
  @IsString() gateName: string;
}

@Controller()
export class AccessLogsController {
  constructor(private readonly service: AccessLogsService) {}

  // ── Internal endpoint — called only by FastAPI ──────────────
  @UseGuards(InternalApiKeyGuard)
  @Post('internal/access-logs')
  ingest(@Body() dto: IngestDto) {
    return this.service.ingest(dto);
  }

  // ── Parent-facing endpoints ──────────────────────────────────
  @UseGuards(AuthGuard('jwt'))
  @Get('me/students')
  myStudents(@Request() req) {
    return this.service.getMyStudents(req.user.sub);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('me/students/:studentId/logs')
  logs(
    @Request() req,
    @Param('studentId') studentId: string,
    @Query('limit') limit?: string,
  ) {
    return this.service.getLogsForStudent(
      req.user.sub,
      studentId,
      limit ? parseInt(limit, 10) : 50,
    );
  }
}
