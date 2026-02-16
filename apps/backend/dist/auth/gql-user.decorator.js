"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.GqlUser = void 0;
const common_1 = require("@nestjs/common");
const graphql_1 = require("@nestjs/graphql");
exports.GqlUser = (0, common_1.createParamDecorator)((data, context) => {
    const ctx = graphql_1.GqlExecutionContext.create(context);
    const { req } = ctx.getContext();
    return req.user;
});
//# sourceMappingURL=gql-user.decorator.js.map