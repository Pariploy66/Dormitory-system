import {
  Injectable,
  ConflictException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../common/prisma.service';
import { RegisterDto, LoginDto } from './auth.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const exists = await this.prisma.parent.findFirst({
      where: { OR: [{ email: dto.email }, { phone: dto.phone }] },
    });
    if (exists) throw new ConflictException('Email or phone already in use');

    const passwordHash = await bcrypt.hash(dto.password, 12);
    const parent = await this.prisma.parent.create({
      data: {
        name: dto.name,
        phone: dto.phone,
        email: dto.email,
        passwordHash,
        identityProvider: 'LOCAL',
      },
    });

    return this.signToken(parent.id, parent.email);
  }

  async login(dto: LoginDto) {
    const parent = await this.prisma.parent.findUnique({
      where: { email: dto.email },
    });
    if (!parent || !parent.passwordHash) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const valid = await bcrypt.compare(dto.password, parent.passwordHash);
    if (!valid) throw new UnauthorizedException('Invalid credentials');

    return this.signToken(parent.id, parent.email);
  }

  /** Register or update FCM token for push notifications */
  async registerDevice(parentId: string, fcmToken: string) {
    return this.prisma.device.upsert({
      where: { fcmToken },
      create: { parentId, fcmToken },
      update: { parentId },
    });
  }

  private signToken(sub: string, email: string) {
    const payload = { sub, email };
    return {
      accessToken: this.jwt.sign(payload),
      parentId: sub,
    };
  }
}
