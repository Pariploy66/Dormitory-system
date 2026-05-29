import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

/**
 * Wraps every successful response in the NewSystem envelope:
 *   { code: 20000, message: 'Success', data: <payload> }
 *
 * HTTP 201 Created → code 20100.
 * Errors are handled separately by HttpExceptionFilter.
 */
@Injectable()
export class ResponseInterceptor<T>
  implements NestInterceptor<T, ApiResponse<T>>
{
  intercept(
    context: ExecutionContext,
    next: CallHandler,
  ): Observable<ApiResponse<T>> {
    const httpContext = context.switchToHttp();
    const response = httpContext.getResponse<{ statusCode: number }>();

    return next.handle().pipe(
      map((data) => {
        const statusCode =
          (response as { statusCode: number }).statusCode ?? 200;
        return {
          code: statusCode === 201 ? 20100 : 20000,
          message: 'Success',
          data: data ?? null,
        };
      }),
    );
  }
}
