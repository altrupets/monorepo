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
exports.RefreshTokenInput = exports.UserProfile = exports.AuthPayload = void 0;
const graphql_1 = require("@nestjs/graphql");
const user_role_enum_1 = require("../roles/user-role.enum");
let AuthPayload = class AuthPayload {
    access_token;
    refresh_token;
    expires_in;
};
exports.AuthPayload = AuthPayload;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], AuthPayload.prototype, "access_token", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], AuthPayload.prototype, "refresh_token", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", Number)
], AuthPayload.prototype, "expires_in", void 0);
exports.AuthPayload = AuthPayload = __decorate([
    (0, graphql_1.ObjectType)()
], AuthPayload);
let UserProfile = class UserProfile {
    userId;
    username;
    roles;
};
exports.UserProfile = UserProfile;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], UserProfile.prototype, "userId", void 0);
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], UserProfile.prototype, "username", void 0);
__decorate([
    (0, graphql_1.Field)(() => [user_role_enum_1.UserRole]),
    __metadata("design:type", Array)
], UserProfile.prototype, "roles", void 0);
exports.UserProfile = UserProfile = __decorate([
    (0, graphql_1.ObjectType)()
], UserProfile);
let RefreshTokenInput = class RefreshTokenInput {
    refresh_token;
};
exports.RefreshTokenInput = RefreshTokenInput;
__decorate([
    (0, graphql_1.Field)(),
    __metadata("design:type", String)
], RefreshTokenInput.prototype, "refresh_token", void 0);
exports.RefreshTokenInput = RefreshTokenInput = __decorate([
    (0, graphql_1.InputType)()
], RefreshTokenInput);
//# sourceMappingURL=auth.types.js.map