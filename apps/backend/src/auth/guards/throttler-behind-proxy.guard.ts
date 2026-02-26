import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';

@Injectable()
export class ThrottlerBehindProxyGuard extends ThrottlerGuard {
  async canActivate(context: ExecutionContext): Promise<boolean> {
    // Allow health checks to bypass rate limiting
    const request = context.switchToHttp().getRequest();
    if (request.path === '/health' || request.path === '/healthz') {
      return true;
    }

    return super.canActivate(context);
  }
}
