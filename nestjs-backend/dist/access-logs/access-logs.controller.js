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
exports.AccessLogsController = void 0;
const common_1 = require("@nestjs/common");
const passport_1 = require("@nestjs/passport");
const class_validator_1 = require("class-validator");
const access_logs_service_1 = require("./access-logs.service");
const internal_api_key_guard_1 = require("../common/internal-api-key.guard");
class IngestDto {
}
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], IngestDto.prototype, "externalStudentId", void 0);
__decorate([
    (0, class_validator_1.IsDateString)(),
    __metadata("design:type", String)
], IngestDto.prototype, "accessTime", void 0);
__decorate([
    (0, class_validator_1.IsIn)(['IN', 'OUT']),
    __metadata("design:type", String)
], IngestDto.prototype, "type", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], IngestDto.prototype, "gateName", void 0);
let AccessLogsController = class AccessLogsController {
    constructor(service) {
        this.service = service;
    }
    ingest(dto) {
        return this.service.ingest(dto);
    }
    myStudents(req) {
        return this.service.getMyStudents(req.user.sub);
    }
    logs(req, studentId, limit) {
        return this.service.getLogsForStudent(req.user.sub, studentId, limit ? parseInt(limit, 10) : 50);
    }
};
exports.AccessLogsController = AccessLogsController;
__decorate([
    (0, common_1.UseGuards)(internal_api_key_guard_1.InternalApiKeyGuard),
    (0, common_1.Post)('internal/access-logs'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [IngestDto]),
    __metadata("design:returntype", void 0)
], AccessLogsController.prototype, "ingest", null);
__decorate([
    (0, common_1.UseGuards)((0, passport_1.AuthGuard)('jwt')),
    (0, common_1.Get)('me/students'),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], AccessLogsController.prototype, "myStudents", null);
__decorate([
    (0, common_1.UseGuards)((0, passport_1.AuthGuard)('jwt')),
    (0, common_1.Get)('me/students/:studentId/logs'),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)('studentId')),
    __param(2, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String]),
    __metadata("design:returntype", void 0)
], AccessLogsController.prototype, "logs", null);
exports.AccessLogsController = AccessLogsController = __decorate([
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [access_logs_service_1.AccessLogsService])
], AccessLogsController);
//# sourceMappingURL=access-logs.controller.js.map