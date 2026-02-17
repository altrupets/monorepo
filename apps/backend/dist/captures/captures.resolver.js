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
exports.CapturesResolver = void 0;
const graphql_1 = require("@nestjs/graphql");
const common_1 = require("@nestjs/common");
const capture_request_entity_1 = require("./entities/capture-request.entity");
const create_capture_input_1 = require("./dto/create-capture.input");
const storage_wrapper_interface_1 = require("./interfaces/storage-wrapper.interface");
const jwt_auth_guard_1 = require("../auth/jwt-auth.guard");
const roles_guard_1 = require("../auth/roles/roles.guard");
const roles_decorator_1 = require("../auth/roles/roles.decorator");
const rbac_constants_1 = require("../auth/roles/rbac-constants");
let CapturesResolver = class CapturesResolver {
    storage;
    constructor(storage) {
        this.storage = storage;
    }
    async getCaptures() {
        return this.storage.getCaptures();
    }
    async createCaptureRequest(input) {
        const imageBuffer = Buffer.from(input.imageBase64, 'base64');
        const { imageBase64, ...data } = input;
        return this.storage.saveCapture(data, imageBuffer);
    }
};
exports.CapturesResolver = CapturesResolver;
__decorate([
    (0, graphql_1.Query)(() => [capture_request_entity_1.CaptureRequest], { name: 'getCaptureRequests' }),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(...rbac_constants_1.CAPTURE_VIEWER_ROLES),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], CapturesResolver.prototype, "getCaptures", null);
__decorate([
    (0, graphql_1.Mutation)(() => capture_request_entity_1.CaptureRequest),
    __param(0, (0, graphql_1.Args)('input')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_capture_input_1.CreateCaptureInput]),
    __metadata("design:returntype", Promise)
], CapturesResolver.prototype, "createCaptureRequest", null);
exports.CapturesResolver = CapturesResolver = __decorate([
    (0, graphql_1.Resolver)(() => capture_request_entity_1.CaptureRequest),
    __param(0, (0, common_1.Inject)(storage_wrapper_interface_1.STORAGE_WRAPPER)),
    __metadata("design:paramtypes", [Object])
], CapturesResolver);
//# sourceMappingURL=captures.resolver.js.map