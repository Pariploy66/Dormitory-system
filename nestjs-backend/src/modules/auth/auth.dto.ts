// ─── auth/dto/thaid-login.dto.ts ────────────────────────────
import { IsString } from 'class-validator';

// Authorization code returned by ThaID after the user signs in.
export class ThaidLoginDto {
  @IsString() code: string;
}
