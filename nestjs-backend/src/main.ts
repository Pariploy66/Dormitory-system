import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';
import { AppModule } from './app.module';
import { ResponseInterceptor } from './common/interceptors/response.interceptor';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { IoAdapter } from '@nestjs/platform-socket.io';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // Scan photos arrive as base64 JSON from the face scanner — raise the body
  // limit (default 100kb is far too small for JPEG payloads).
  app.useBodyParser('json', { limit: '10mb' });

  // Serve stored gate photos (uploads/access-logs/*.jpg) to the mobile app.
  app.useStaticAssets(join(process.cwd(), 'uploads'), { prefix: '/uploads/' });

  // ── Global pipes ───────────────────────────────────────────────────────────
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,            // strip unknown fields
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // ── NewSystem response envelope: { code, message, data } ──────────────────
  app.useGlobalInterceptors(new ResponseInterceptor());
  app.useGlobalFilters(new HttpExceptionFilter());

  // ── Socket.IO adapter (NewSystem pattern: socket.js) ─────────────────────
  app.useWebSocketAdapter(new IoAdapter(app));

  // ── CORS ───────────────────────────────────────────────────────────────────
  app.enableCors({
    origin: process.env.CORS_ORIGIN ?? true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Internal-API-Key'],
    credentials: true,
  });

  const port = process.env.PORT ?? 3000;
  await app.listen(port);
  console.log(`NestJS backend listening on port ${port}`);
}

bootstrap();
