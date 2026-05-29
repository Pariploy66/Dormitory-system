import { Body, Controller, Post, Request, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AuthService } from './auth.service';
import { RegisterDto, LoginDto } from './auth.dto';
import { AuthorizeGuard } from '../common/guards/authorize.guard';
import { Authorize } from '../common/decorators/authorize.decorator';
import { IsString } from 'class-validator';

class DeviceTokenDto {
  @IsString() fcmToken: string;
}

// ── Auth routes: /auth/* ───────────────────────────────────────────────────
// Pattern: auth guard → authorize → service handler (NewSystem standard)
// Register + Login are public — no JWT guard needed.
@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  // POST /auth/register — public
  @Post('register')
  onCreate(@Body() dto: RegisterDto) {
    return this.auth.onCreate(dto);
  }

  // POST /auth/login — public
  @Post('login')
  onLogin(@Body() dto: LoginDto) {
    return this.auth.onLogin(dto);
  }

  // PUT /auth/device — protected: auth → authorize(account, edit) → onUpdate
  @UseGuards(AuthGuard('jwt'), AuthorizeGuard)
  @Authorize('account', 'edit')
  @Post('device')
  onUpdate(@Request() req, @Body() dto: DeviceTokenDto) {
    return this.auth.onUpdate(req.user.sub, dto.fcmToken);
  }
}
