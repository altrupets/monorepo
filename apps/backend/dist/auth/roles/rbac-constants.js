"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SUPER_USER_ROLES = exports.CAPTURE_VIEWER_ROLES = exports.USER_ADMIN_ROLES = void 0;
const user_role_enum_1 = require("./user-role.enum");
exports.USER_ADMIN_ROLES = [
    user_role_enum_1.UserRole.SUPER_USER,
    user_role_enum_1.UserRole.USER_ADMIN,
    user_role_enum_1.UserRole.LEGAL_REPRESENTATIVE,
];
exports.CAPTURE_VIEWER_ROLES = [
    user_role_enum_1.UserRole.SUPER_USER,
    user_role_enum_1.UserRole.GOVERNMENT_ADMIN,
];
exports.SUPER_USER_ROLES = [user_role_enum_1.UserRole.SUPER_USER];
//# sourceMappingURL=rbac-constants.js.map