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
import { SkipThrottle } from '@nestjs/throttler';
import { IsString, IsIn, IsDateString, IsOptional } from 'class-validator';
import { AccessLogsService, IngestPayload } from './access-logs.service';
import { InternalApiKeyGuard } from '../../common/internal-api-key.guard';
import { AuthorizeGuard } from '../../common/guards/authorize.guard';
import { Authorize } from '../../common/decorators/authorize.decorator';

class IngestDto implements IngestPayload {
  @IsString() externalStudentId: string;
  @IsDateString() accessTime: string;
  @IsIn(['IN', 'OUT']) type: 'IN' | 'OUT';
  @IsString() gateName: string;
  @IsOptional() @IsString() photoUrl?: string;
  @IsOptional() @IsString() scanPhotoUrl?: string;
  // Raw JPEG/PNG as base64 (face scanner) — backend stores the file and
  // fills photoUrl/scanPhotoUrl itself. Data-URI prefix allowed.
  @IsOptional() @IsString() photoBase64?: string;
  @IsOptional() @IsString() scanPhotoBase64?: string;
}

// ── Pattern: auth guard → @Authorize → service handler (NewSystem standard) ──
@Controller()
export class AccessLogsController {
  constructor(private readonly service: AccessLogsService) {}

  // POST /internal/access-logs — internal only (FastAPI / face scanner)
  // No JWT — uses X-Internal-API-Key header instead. Exempt from the global
  // rate limit: this is trusted machine-to-machine ingest that can legitimately
  // burst (scan batches), and it is already gated by the internal API key.
  @SkipThrottle()
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
      // Base URL for turning stored /uploads/... paths into absolute links
      // the mobile app can load from wherever it reached this server.
      `${req.protocol}://${req.get('host')}`,
    );
  }
}
