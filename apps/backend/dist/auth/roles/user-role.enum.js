"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserRole = void 0;
const graphql_1 = require("@nestjs/graphql");
var UserRole;
(function (UserRole) {
    UserRole["SUPER_USER"] = "SUPER_USER";
    UserRole["GOVERNMENT_ADMIN"] = "GOVERNMENT_ADMIN";
    UserRole["USER_ADMIN"] = "USER_ADMIN";
    UserRole["LEGAL_REPRESENTATIVE"] = "LEGAL_REPRESENTATIVE";
    UserRole["WATCHER"] = "WATCHER";
    UserRole["HELPER"] = "HELPER";
    UserRole["RESCUER"] = "RESCUER";
    UserRole["ADOPTER"] = "ADOPTER";
    UserRole["DONOR"] = "DONOR";
    UserRole["VETERINARIAN"] = "VETERINARIAN";
})(UserRole || (exports.UserRole = UserRole = {}));
(0, graphql_1.registerEnumType)(UserRole, {
    name: 'UserRole',
});
//# sourceMappingURL=user-role.enum.js.map