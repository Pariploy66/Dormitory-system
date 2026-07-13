import { NestFactory } from '@nestjs/core';
import { Logger, ValidationPipe } from '@nestjs/common';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';
import helmet from 'helmet';
import { AppModule } from './app.module';
import { ResponseInterceptor } from './common/interceptors/response.interceptor';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { IoAdapter } from '@nestjs/platform-socket.io';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    // Never let uncaught internals surface via the default Express error page.
    bufferLogs: false,
  });

  // ── Security headers ────────────────────────────────────────────────────────
  // helmet sets sane defaults (HSTS, X-Content-Type-Options, frameguard, …).
  // crossOriginResourcePolicy is relaxed so the mobile app can load /uploads
  // photos from a different origin than the API host.
  app.use(
    helmet({
      crossOriginResourcePolicy: { policy: 'cross-origin' },
    }),
  );

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
  // CORS_ORIGIN is a comma-separated allowlist. When unset we fall back to
  // reflecting the request origin ONLY outside production; production with no
  // allowlist configured refuses cross-origin requests (fail closed).
  const corsEnv = process.env.CORS_ORIGIN?.trim();
  const isProd = process.env.NODE_ENV === 'production';
  const origin = corsEnv
    ? corsEnv.split(',').map((o) => o.trim())
    : isProd
      ? false
      : true;
  if (isProd && !corsEnv) {
    logger.warn('CORS_ORIGIN not set in production — cross-origin requests are blocked.');
  }
  app.enableCors({
    origin,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Internal-API-Key'],
    credentials: true,
  });

  const port = process.env.PORT ?? 3000;
  await app.listen(port);
  logger.log(`NestJS backend listening on port ${port}`);
}

bootstrap();
