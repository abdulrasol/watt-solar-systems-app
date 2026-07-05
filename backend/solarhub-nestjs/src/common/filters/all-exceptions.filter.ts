import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    
    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'Internal server error';
    let errorDetails: any = true;

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const res = exception.getResponse();
      
      // Handling validation errors from class-validator
      if (typeof res === 'object' && (res as any).message) {
        if (Array.isArray((res as any).message)) {
          message = 'Validation failed';
          errorDetails = (res as any).message; // Returns array of errors
        } else {
          message = (res as any).message;
          errorDetails = true;
        }
      } else if (typeof res === 'string') {
        message = res;
      }
    } else if (exception instanceof Error) {
      message = exception.message;
    }

    const errorFormat = {
      status: status,
      message: message,
      body: {}, // Always empty for errors based on Django's json_response logic
      error: errorDetails,
      message_user: message, // Same logic as Django where message_user = message if error
    };

    response.status(status).json(errorFormat);
  }
}
