import { AuthService } from './auth.service';
import { RegisterDto, LoginDto } from './auth.dto';
declare class DeviceTokenDto {
    fcmToken: string;
}
export declare class AuthController {
    private readonly auth;
    constructor(auth: AuthService);
    register(dto: RegisterDto): Promise<{
        accessToken: string;
        parentId: string;
    }>;
    login(dto: LoginDto): Promise<{
        accessToken: string;
        parentId: string;
    }>;
    registerDevice(req: any, dto: DeviceTokenDto): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        fcmToken: string;
        parentId: string;
    }>;
}
export {};
