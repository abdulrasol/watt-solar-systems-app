import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

export interface Response<T> {
  status: number;
  message: string;
  body: T;
  error: boolean;
  message_user: string | null;
}
import { RAW_RESPONSE_KEY } from '../decorators/raw-response.decorator';

@Injectable()
export class ResponseInterceptor<T> implements NestInterceptor<T, Response<T> | T> {
  constructor(private reflector: Reflector) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<Response<T> | T> {
    const isRaw = this.reflector.getAllAndOverride<boolean>(RAW_RESPONSE_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isRaw) {
      return next.handle().pipe(
        map((data) => this.prefixMediaUrls(data))
      );
    }

    const ctx = context.switchToHttp();
    const response = ctx.getResponse();

    return next.handle().pipe(
      map((data) => {
        let message = 'Success';
        let body = data;

        // If the service returns an object with message and data/user separately
        if (data && typeof data === 'object' && !Array.isArray(data)) {
          if (data.message) {
            message = data.message;
            body = { ...data };
            delete body.message;
          }
        }

        // Recursively prepend media base URL to known image paths
        body = this.prefixMediaUrls(body);

        // For endpoints that return empty objects, we pass them as is.
        return {
          status: response.statusCode,
          message: message,
          body: body ?? {},
          error: false,
          message_user: null,
        };
      }),
    );
  }

  private prefixMediaUrls(obj: any): any {
    if (!obj) return obj;
    if (typeof obj === 'string') {
      if (obj.match(/^(company_logos|works_images|posters|product_images|users\/avatars)\//)) {
        const baseUrl = process.env.BASE_URL || 'http://localhost:3000';
        return `${baseUrl}/media/${obj}`;
      }
      return obj;
    }
    if (Array.isArray(obj)) {
      return obj.map(item => this.prefixMediaUrls(item));
    }
    if (typeof obj === 'object') {
      const newObj: any = {};
      for (const key in obj) {
        newObj[key] = this.prefixMediaUrls(obj[key]);
      }
      return newObj;
    }
    return obj;
  }
}
