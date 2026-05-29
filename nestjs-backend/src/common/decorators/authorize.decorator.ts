import { SetMetadata } from '@nestjs/common';

export const AUTHORIZE_KEY = 'authorize';

export interface AuthorizeOptions {
  resource: string;
  action: 'view' | 'edit' | 'delete';
}

/**
 * Marks an endpoint with the resource + action it requires.
 * Mirrors NewSystem's authorize.requirePermission(resource, action).
 *
 * Usage:
 *   @Authorize('logs', 'view')
 *   @Authorize('account', 'edit')
 */
export const Authorize = (
  resource: string,
  action: 'view' | 'edit' | 'delete',
) => SetMetadata(AUTHORIZE_KEY, { resource, action } satisfies AuthorizeOptions);
