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
var RemoteStorageService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.RemoteStorageService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const config_1 = require("@nestjs/config");
const uuid_1 = require("uuid");
const capture_request_entity_1 = require("../entities/capture-request.entity");
let RemoteStorageService = RemoteStorageService_1 = class RemoteStorageService {
    repository;
    configService;
    logger = new common_1.Logger(RemoteStorageService_1.name);
    constructor(repository, configService) {
        this.repository = repository;
        this.configService = configService;
    }
    async saveCapture(data, image) {
        this.logger.log('Saving capture to OVH S3 (not fully implemented in this step)...');
        const imageUrl = `https://s3.ovh.net/bucket/${(0, uuid_1.v4)()}.jpg`;
        const capture = this.repository.create({
            ...data,
            imageUrl,
            status: 'PENDING',
        });
        return this.repository.save(capture);
    }
    async getCaptures() {
        return this.repository.find({ order: { createdAt: 'DESC' } });
    }
};
exports.RemoteStorageService = RemoteStorageService;
exports.RemoteStorageService = RemoteStorageService = RemoteStorageService_1 = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(capture_request_entity_1.CaptureRequest)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        config_1.ConfigService])
], RemoteStorageService);
//# sourceMappingURL=remote-storage.service.js.map