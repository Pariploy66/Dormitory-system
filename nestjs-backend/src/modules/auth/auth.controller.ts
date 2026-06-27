import {
  Body,
  Controller,
  Get,
  Post,
  Req,
  Request,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { IsString } from 'class-validator';
import { Request as ExpressRequest } from 'express';
import { AuthService, AuthLogMeta } from './auth.service';
import { ThaidLoginDto } from './auth.dto';
import { AuthorizeGuard } from '../../common/guards/authorize.guard';
import { Authorize } from '../../common/decorators/authorize.decorator';

class DeviceTokenDto {
  @IsString() fcmToken: string;
}

// Pull client IP + User-Agent for the app sign-in/out audit trail.
function extractMeta(req: ExpressRequest): AuthLogMeta {
  return {
    ipAddress: (req.headers['x-forwarded-for'] as string) ?? req.ip,
    userAgent: req.headers['user-agent'],
  };
}

// ── Auth routes: /auth/* (ThaID-only) ───────────────────────────────────────
// Login URL + code exchange are public; device registration requires our JWT.
@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  // GET /auth/thaid/login-url — public: returns ThaID authorization URL + state
  @Get('thaid/login-url')
  loginUrl() {
    return this.auth.getLoginUrl();
  }

  // POST /auth/thaid — public: exchange authorization code for our JWT (logs LOGIN)
  @Post('thaid')
  onThaidLogin(@Body() dto: ThaidLoginDto, @Req() req: ExpressRequest) {
    return this.auth.onThaidLogin(dto.code, extractMeta(req));
  }

  // POST /auth/logout — protected: record app sign-out (logs LOGOUT)
  @UseGuards(AuthGuard('jwt'), AuthorizeGuard)
  @Authorize('account', 'edit')
  @Post('logout')
  onLogout(@Request() req, @Req() raw: ExpressRequest) {
    return this.auth.onLogout(req.user.sub, extractMeta(raw));
  }

  // POST /auth/device — protected: auth → authorize(account, edit) → onUpdate
  @UseGuards(AuthGuard('jwt'), AuthorizeGuard)
  @Authorize('account', 'edit')
  @Post('device')
  onUpdate(@Request() req, @Body() dto: DeviceTokenDto) {
    return this.auth.onUpdate(req.user.sub, dto.fcmToken);
  }
}
