import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  Logger,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AUTHORIZE_KEY, AuthorizeOptions } from '../decorators/authorize.decorator';

/**
 * Authorization guard — mirrors NewSystem's requirePermission middleware.
 *
 * In this system every authenticated parent can view/edit their own data only.
 * Row-level ownership is enforced inside service methods (parent–student mapping).
 * This guard ensures:
 *   1. The endpoint is decorated with @Authorize (resource + action declared)
 *   2. The requesting user is authenticated (JWT payload present on req.user)
 *
 * Place AFTER AuthGuard('jwt') so req.user is already populated:
 *   @UseGuards(AuthGuard('jwt'), AuthorizeGuard)
 *   @Authorize('logs', 'view')
 */
@Injectable()
export class AuthorizeGuard implements CanActivate {
  private readonly logger = new Logger(AuthorizeGuard.name);

  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const options = this.reflector.getAllAndOverride<AuthorizeOptions | undefined>(
      AUTHORIZE_KEY,
      [context.getHandler(), context.getClass()],
    );

    // Endpoint not decorated with @Authorize → skip guard (public route)
    if (!options) return true;

    const request = context.switchToHttp().getRequest<{ user?: { sub: string; email: string } }>();
    const user = request.user;

    if (!user?.sub) {
      this.logger.warn(
        `Authorize(${options.resource}, ${options.action}) — no authenticated user`,
      );
      throw new ForbiddenException('Access denied');
    }

    this.logger.debug(
      `Authorize: user=${user.sub} resource=${options.resource} action=${options.action} → allowed`,
    );

    return true;
  }
}
