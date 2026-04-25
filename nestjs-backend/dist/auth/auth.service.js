"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const bcrypt = require("bcrypt");
const prisma_service_1 = require("../common/prisma.service");
let AuthService = class AuthService {
    constructor(prisma, jwt) {
        this.prisma = prisma;
        this.jwt = jwt;
    }
    async register(dto) {
        const exists = await this.prisma.parent.findFirst({
            where: { OR: [{ email: dto.email }, { phone: dto.phone }] },
        });
        if (exists)
            throw new common_1.ConflictException('Email or phone already in use');
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
    async login(dto) {
        const parent = await this.prisma.parent.findUnique({
            where: { email: dto.email },
        });
        if (!parent || !parent.passwordHash) {
            throw new common_1.UnauthorizedException('Invalid credentials');
        }
        const valid = await bcrypt.compare(dto.password, parent.passwordHash);
        if (!valid)
            throw new common_1.UnauthorizedException('Invalid credentials');
        return this.signToken(parent.id, parent.email);
    }
    async registerDevice(parentId, fcmToken) {
        return this.prisma.device.upsert({
            where: { fcmToken },
            create: { parentId, fcmToken },
            update: { parentId },
        });
    }
    signToken(sub, email) {
        const payload = { sub, email };
        return {
            accessToken: this.jwt.sign(payload),
            parentId: sub,
        };
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        jwt_1.JwtService])
], AuthService);
//# sourceMappingURL=auth.service.js.map