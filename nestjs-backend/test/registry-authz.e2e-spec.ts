import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { JwtService } from '@nestjs/jwt';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/common/prisma.service';
import { ResponseInterceptor } from '../src/common/interceptors/response.interceptor';
import { HttpExceptionFilter } from '../src/common/filters/http-exception.filter';

/**
 * End-to-end coverage of the crown-jewel security rule and the guard chain.
 *
 * Requires a running database seeded with the shared snapshot (117 students,
 * linked guardians). Run with:  npm run test:e2e
 */
describe('Registry authorization (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let jwt: JwtService;

  // Chosen at runtime from real data so the test is not tied to fixed IDs.
  let parentToken: string;
  let ownStudentId: string;
  let foreignStudentId: string;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleRef.createNestApplication();
    // Mirror main.ts so behaviour matches production.
    app.useGlobalPipes(
      new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }),
    );
    app.useGlobalInterceptors(new ResponseInterceptor());
    app.useGlobalFilters(new HttpExceptionFilter());
    await app.init();

    prisma = app.get(PrismaService);
    jwt = app.get(JwtService);

    // A parent (in the parents table) who guards at least one ACTIVE student.
    const entry = await prisma.parentStudentRegistry.findFirst({
      where: { student: { status: 'ACTIVE' } },
      include: { student: true },
    });
    if (!entry) throw new Error('Seed data missing: no active registry entry');

    const parent = await prisma.parent.findUnique({
      where: { citizenId: entry.parentCitizenId },
    });
    if (!parent) {
      throw new Error(
        'Seed data missing: registry parent has never logged in (no parents row). ' +
          'Log in once via ThaID or seed a parent to run this test.',
      );
    }

    ownStudentId = entry.studentId;
    parentToken = jwt.sign({ sub: parent.id });

    // A student this parent does NOT guard.
    const foreign = await prisma.student.findFirst({
      where: {
        status: 'ACTIVE',
        registryEntries: { none: { parentCitizenId: entry.parentCitizenId } },
      },
    });
    if (!foreign) throw new Error('Seed data missing: no un-owned student');
    foreignStudentId = foreign.id;
  });

  afterAll(async () => {
    await app.close();
  });

  it('GET /health → 200 liveness', () => {
    return request(app.getHttpServer()).get('/health').expect(200);
  });

  it('GET /health/ready → 200 (database reachable)', () => {
    return request(app.getHttpServer()).get('/health/ready').expect(200);
  });

  it('GET /me/profile without a token → 401', () => {
    return request(app.getHttpServer()).get('/me/profile').expect(401);
  });

  it('POST /internal/students/upsert without the API key → 401', () => {
    return request(app.getHttpServer())
      .post('/internal/students/upsert')
      .send({ externalStudentId: 'x', studentCode: 'x', name: 'x' })
      .expect(401);
  });

  it('parent CAN read the logs of their own child → 200', () => {
    return request(app.getHttpServer())
      .get(`/me/students/${ownStudentId}/logs?days=7`)
      .set('Authorization', `Bearer ${parentToken}`)
      .expect(200);
  });

  it("parent CANNOT read another family's child logs → 403", () => {
    return request(app.getHttpServer())
      .get(`/me/students/${foreignStudentId}/logs?days=7`)
      .set('Authorization', `Bearer ${parentToken}`)
      .expect(403);
  });
});
