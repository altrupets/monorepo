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
exports.WebAuthController = void 0;
const common_1 = require("@nestjs/common");
const auth_service_1 = require("../../auth/auth.service");
const rbac_constants_1 = require("../../auth/roles/rbac-constants");
let WebAuthController = class WebAuthController {
    authService;
    constructor(authService) {
        this.authService = authService;
    }
    async loginPage(res) {
        return res.inertia.render('Auth/Login', {
            title: 'Iniciar Sesión',
        });
    }
    async login(loginInput, res) {
        try {
            const user = await this.authService.validateUser(loginInput.username, loginInput.password);
            if (!user) {
                return res.inertia.render('Auth/Login', {
                    title: 'Iniciar Sesión',
                    errors: { login: 'Credenciales inválidas' },
                });
            }
            const result = await this.authService.login(user);
            res.cookie('jwt', result.access_token, {
                httpOnly: true,
                secure: process.env.NODE_ENV === 'production',
                sameSite: 'strict',
                maxAge: 24 * 60 * 60 * 1000,
            });
            const userWithRoles = await this.authService.validateToken(result.access_token);
            const hasUserAdminRole = userWithRoles.roles.some(role => rbac_constants_1.USER_ADMIN_ROLES.includes(role));
            const hasCaptureViewerRole = userWithRoles.roles.some(role => rbac_constants_1.CAPTURE_VIEWER_ROLES.includes(role));
            if (hasUserAdminRole) {
                return res.redirect('/admin');
            }
            else if (hasCaptureViewerRole) {
                return res.redirect('/b2g');
            }
            return res.redirect('/');
        }
        catch (error) {
            return res.inertia.render('Auth/Login', {
                title: 'Iniciar Sesión',
                errors: { login: 'Credenciales inválidas' },
            });
        }
    }
    async logout(res) {
        res.clearCookie('jwt');
        return res.redirect('/login');
    }
};
exports.WebAuthController = WebAuthController;
__decorate([
    (0, common_1.Get)('login'),
    __param(0, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], WebAuthController.prototype, "loginPage", null);
__decorate([
    (0, common_1.Post)('login'),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], WebAuthController.prototype, "login", null);
__decorate([
    (0, common_1.Post)('logout'),
    __param(0, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], WebAuthController.prototype, "logout", null);
exports.WebAuthController = WebAuthController = __decorate([
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [auth_service_1.AuthService])
], WebAuthController);
//# sourceMappingURL=web-auth.controller.js.map