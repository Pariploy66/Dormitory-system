import { Global, Module } from '@nestjs/common';
import { AuthorizeGuard } from './guards/authorize.guard';

/**
 * Global module — exports AuthorizeGuard so all feature modules can inject it
 * without importing CommonModule explicitly.
 */
@Global()
@Module({
  providers: [AuthorizeGuard],
  exports: [AuthorizeGuard],
})
export class CommonModule {}
