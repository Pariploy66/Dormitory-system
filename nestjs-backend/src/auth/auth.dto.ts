// ─── auth/dto/register.dto.ts ──────────────────────────────
import { IsEmail, IsString, MinLength, IsMobilePhone } from 'class-validator';

export class RegisterDto {
  @IsString() @MinLength(2) name: string;
  @IsMobilePhone('th-TH') phone: string;
  @IsEmail() email: string;
  @IsString() @MinLength(8) password: string;
}

// ─── auth/dto/login.dto.ts ──────────────────────────────────
export class LoginDto {
  @IsEmail() email: string;
  @IsString() password: string;
}
