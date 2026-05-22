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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.StudentsModule = exports.StudentsController = exports.StudentsService = exports.LinkStudentDto = exports.UpsertStudentDto = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../common/prisma.service");
const class_validator_1 = require("class-validator");
const common_2 = require("@nestjs/common");
const internal_api_key_guard_1 = require("../common/internal-api-key.guard");
class UpsertStudentDto {
}
exports.UpsertStudentDto = UpsertStudentDto;
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpsertStudentDto.prototype, "externalStudentId", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpsertStudentDto.prototype, "studentCode", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpsertStudentDto.prototype, "name", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpsertStudentDto.prototype, "dormitory", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpsertStudentDto.prototype, "roomNumber", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpsertStudentDto.prototype, "room_number", void 0);
class LinkStudentDto {
}
exports.LinkStudentDto = LinkStudentDto;
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], LinkStudentDto.prototype, "parentPhone", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], LinkStudentDto.prototype, "studentCode", void 0);
let StudentsService = class StudentsService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async upsertStudent(dto) {
        const room = dto.roomNumber ?? dto.room_number;
        return this.prisma.student.upsert({
            where: { externalStudentId: dto.externalStudentId },
            create: {
                externalStudentId: dto.externalStudentId,
                studentCode: dto.studentCode,
                name: dto.name,
                dormitory: dto.dormitory,
                roomNumber: room,
            },
            update: {
                name: dto.name,
                studentCode: dto.studentCode,
                dormitory: dto.dormitory,
                roomNumber: room,
            },
        });
    }
    async linkStudentToParent(dto) {
        const [parent, student] = await Promise.all([
            this.prisma.parent.findUnique({ where: { phone: dto.parentPhone } }),
            this.prisma.student.findUnique({ where: { studentCode: dto.studentCode } }),
        ]);
        if (!parent || !student) {
            return { ok: false, reason: 'Parent or student not found' };
        }
        await this.prisma.parentStudentMapping.upsert({
            where: { parentId_studentId: { parentId: parent.id, studentId: student.id } },
            create: { parentId: parent.id, studentId: student.id },
            update: {},
        });
        return { ok: true };
    }
};
exports.StudentsService = StudentsService;
exports.StudentsService = StudentsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], StudentsService);
let StudentsController = class StudentsController {
    constructor(service) {
        this.service = service;
    }
    upsert(dto) {
        return this.service.upsertStudent(dto);
    }
    link(dto) {
        return this.service.linkStudentToParent(dto);
    }
};
exports.StudentsController = StudentsController;
__decorate([
    (0, common_2.Post)('upsert'),
    __param(0, (0, common_2.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [UpsertStudentDto]),
    __metadata("design:returntype", void 0)
], StudentsController.prototype, "upsert", null);
__decorate([
    (0, common_2.Post)('link'),
    __param(0, (0, common_2.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [LinkStudentDto]),
    __metadata("design:returntype", void 0)
], StudentsController.prototype, "link", null);
exports.StudentsController = StudentsController = __decorate([
    (0, common_2.Controller)('internal/students'),
    (0, common_2.UseGuards)(internal_api_key_guard_1.InternalApiKeyGuard),
    __metadata("design:paramtypes", [StudentsService])
], StudentsController);
let StudentsModule = class StudentsModule {
};
exports.StudentsModule = StudentsModule;
exports.StudentsModule = StudentsModule = __decorate([
    (0, common_2.Module)({
        providers: [StudentsService],
        controllers: [StudentsController],
    })
], StudentsModule);
//# sourceMappingURL=students.module.js.map