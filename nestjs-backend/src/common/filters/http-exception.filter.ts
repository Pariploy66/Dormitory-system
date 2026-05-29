import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

/**
 * Catches all exceptions and formats them in the NewSystem envelope:
 *   { code: <numeric>, message: <string> }
 *
 * Code mapping:
 *   400 → 40000   Bad Request / Validation
 *   401 → 40100   Unauthorized
 *   403 → 40300   Forbidden
 *   404 → 40400   Not Found
 *   409 → 40900   Conflict
 *   5xx → 50000   Internal / unexpected
 */
@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx      = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request  = ctx.getRequest<Request>();

    let status  = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'Internal server error';

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const body = exception.getResponse();
      if (typeof body === 'string') {
        message = body;
      } else if (typeof body === 'object' && body !== null) {
        const b = body as Record<string, unknown>;
        if (Array.isArray(b['message'])) {
          message = (b['message'] as string[]).join('; ');
        } else if (typeof b['message'] === 'string') {
          message = b['message'];
        }
      }
    } else if (exception instanceof Error) {
      message = exception.message;
      this.logger.error(`Unhandled: ${exception.message}`, exception.stack);
    }

    const code = this.toCode(status);

    if (status >= 500) {
      this.logger.error(
        `${request.method} ${request.url} → ${status}: ${message}`,
      );
    }

    response.status(status).json({ code, message });
  }

  private toCode(status: number): number {
    const map: Record<number, number> = {
      400: 40000,
      401: 40100,
      403: 40300,
      404: 40400,
      409: 40900,
      422: 42200,
    };
    return map[status] ?? (status >= 500 ? 50000 : status * 100);
  }
}
