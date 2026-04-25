import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../common/prisma.service';
import { RegisterDto, LoginDto } from './auth.dto';
export declare class AuthService {
    private readonly prisma;
    private readonly jwt;
    constructor(prisma: PrismaService, jwt: JwtService);
    register(dto: RegisterDto): Promise<{
        accessToken: string;
        parentId: string;
    }>;
    login(dto: LoginDto): Promise<{
        accessToken: string;
        parentId: string;
    }>;
    registerDevice(parentId: string, fcmToken: string): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        fcmToken: string;
        parentId: string;
    }>;
    private signToken;
}
