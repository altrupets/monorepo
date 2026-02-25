"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.WebModule = void 0;
const common_1 = require("@nestjs/common");
const admin_controller_1 = require("./controllers/admin.controller");
const b2g_controller_1 = require("./controllers/b2g.controller");
const web_auth_controller_1 = require("./controllers/web-auth.controller");
const auth_module_1 = require("../auth/auth.module");
let WebModule = class WebModule {
};
exports.WebModule = WebModule;
exports.WebModule = WebModule = __decorate([
    (0, common_1.Module)({
        imports: [auth_module_1.AuthModule],
        controllers: [admin_controller_1.AdminController, b2g_controller_1.B2gController, web_auth_controller_1.WebAuthController],
    })
], WebModule);
//# sourceMappingURL=web.module.js.map
