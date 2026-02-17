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
exports.B2gController = void 0;
const common_1 = require("@nestjs/common");
const jwt_auth_guard_1 = require("../../auth/jwt-auth.guard");
const roles_guard_1 = require("../../auth/roles/roles.guard");
const roles_decorator_1 = require("../../auth/roles/roles.decorator");
const rbac_constants_1 = require("../../auth/roles/rbac-constants");
let B2gController = class B2gController {
    async index(res) {
        return res.inertia.render('B2G/Dashboard', {
            title: 'Panel B2G - Gobierno Local',
        });
    }
    async captures(res) {
        return res.inertia.render('B2G/Captures/Index', {
            title: 'Solicitudes de Captura',
        });
    }
    async captureDetail(res) {
        return res.inertia.render('B2G/Captures/Detail', {
            title: 'Detalle de Solicitud',
        });
    }
};
exports.B2gController = B2gController;
__decorate([
    (0, common_1.Get)(),
    (0, roles_decorator_1.Roles)(...rbac_constants_1.CAPTURE_VIEWER_ROLES),
    __param(0, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], B2gController.prototype, "index", null);
__decorate([
    (0, common_1.Get)('captures'),
    (0, roles_decorator_1.Roles)(...rbac_constants_1.CAPTURE_VIEWER_ROLES),
    __param(0, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], B2gController.prototype, "captures", null);
__decorate([
    (0, common_1.Get)('captures/:id'),
    (0, roles_decorator_1.Roles)(...rbac_constants_1.CAPTURE_VIEWER_ROLES),
    __param(0, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], B2gController.prototype, "captureDetail", null);
exports.B2gController = B2gController = __decorate([
    (0, common_1.Controller)('b2g'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard)
], B2gController);
//# sourceMappingURL=b2g.controller.js.map