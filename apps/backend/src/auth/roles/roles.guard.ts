import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { UserRole } from './user-role.enum';
import { ROLES_KEY } from './roles.decorator';
import { GqlExecutionContext } from '@nestjs/graphql';
import { GqlContext } from '../interfaces/auth-request.interface';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<UserRole[]>(
      ROLES_KEY,
      [context.getHandler(), context.getClass()],
    );
    if (!requiredRoles) {
      return true;
    }

    let req: any;
    
    // Check if it's a GraphQL context
    try {
      const ctx = GqlExecutionContext.create(context);
      req = ctx.getContext<GqlContext>().req;
    } catch {
      // If not GraphQL, get HTTP request directly
      req = context.switchToHttp().getRequest();
    }
    
    const user = req.user;
    return requiredRoles.some((role) => user?.roles?.includes(role));
  }
}
