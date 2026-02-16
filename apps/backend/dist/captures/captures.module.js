"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CapturesModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const config_1 = require("@nestjs/config");
const capture_request_entity_1 = require("./entities/capture-request.entity");
const captures_resolver_1 = require("./captures.resolver");
const storage_wrapper_interface_1 = require("./interfaces/storage-wrapper.interface");
const local_storage_service_1 = require("./storage/local-storage.service");
const remote_storage_service_1 = require("./storage/remote-storage.service");
const StorageProvider = {
    provide: storage_wrapper_interface_1.STORAGE_WRAPPER,
    useFactory: (configService, local, remote) => {
        const type = configService.get('STORAGE_TYPE', 'local');
        return type === 'remote' ? remote : local;
    },
    inject: [config_1.ConfigService, local_storage_service_1.LocalStorageService, remote_storage_service_1.RemoteStorageService],
};
let CapturesModule = class CapturesModule {
};
exports.CapturesModule = CapturesModule;
exports.CapturesModule = CapturesModule = __decorate([
    (0, common_1.Module)({
        imports: [typeorm_1.TypeOrmModule.forFeature([capture_request_entity_1.CaptureRequest]), config_1.ConfigModule],
        providers: [
            captures_resolver_1.CapturesResolver,
            local_storage_service_1.LocalStorageService,
            remote_storage_service_1.RemoteStorageService,
            StorageProvider,
        ],
        exports: [storage_wrapper_interface_1.STORAGE_WRAPPER],
    })
], CapturesModule);
//# sourceMappingURL=captures.module.js.map