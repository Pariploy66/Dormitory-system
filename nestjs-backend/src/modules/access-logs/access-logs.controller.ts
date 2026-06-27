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
import { InternalApiKeyGuard } from '../../common/internal-api-key.guard';
import { AuthorizeGuard } from '../../common/guards/authorize.guard';
import { Authorize } from '../../common/decorators/authorize.decorator';

class IngestDto implements IngestPayload {
  @IsString() externalStudentId: string;
  @IsDateString() accessTime: string;
  @IsIn(['IN', 'OUT']) type: 'IN' | 'OUT';
  @IsString() gateName: string;
}

// ── Pattern: auth guard → @Authorize → service handler (NewSystem standard) ──
@Controller()
export class AccessLogsController {
  constructor(private readonly service: AccessLogsService) {}

  // POST /internal/access-logs — internal only (FastAPI)
  // No JWT — uses X-Internal-API-Key header instead
  @UseGuards(InternalApiKeyGuard)
  @Post('internal/access-logs')
  onCreate(@Body() dto: IngestDto) {
    return this.service.onCreate(dto);
  }

  // GET /me/profile — auth → authorize(account, view) → onQuery
  @UseGuards(AuthGuard('jwt'), AuthorizeGuard)
  @Authorize('account', 'view')
  @Get('me/profile')
  onQuery(@Request() req) {
    return this.service.onQuery(req.user.sub);
  }

  // GET /me/students — auth → authorize(students, view) → onQuerys
  @UseGuards(AuthGuard('jwt'), AuthorizeGuard)
  @Authorize('students', 'view')
  @Get('me/students')
  onQuerys(@Request() req) {
    return this.service.onQuerys(req.user.sub);
  }

  // GET /me/students/:studentId/logs — auth → authorize(logs, view) → onQueryLogs
  @UseGuards(AuthGuard('jwt'), AuthorizeGuard)
  @Authorize('logs', 'view')
  @Get('me/students/:studentId/logs')
  onQueryLogs(
    @Request() req,
    @Param('studentId') studentId: string,
    @Query('days') days?: string,
  ) {
    return this.service.onQueryLogs(
      req.user.sub,
      studentId,
      days ? parseInt(days, 10) : 7,
    );
  }
}
