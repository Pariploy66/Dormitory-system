import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Injectable, Logger } from '@nestjs/common';
import { Server, Socket } from 'socket.io';

// ── NewSystem pattern: socket.js → events.gateway.ts ──────────────────────────
// Follows the same io.on('connection') lifecycle from backend-node/server/routes/socket.js
// CORS origin mirrors the HTTP layer (CORS_ORIGIN env) so production locks it down.
@WebSocketGateway({
  cors: { origin: process.env.CORS_ORIGIN ?? true, credentials: true },
})
@Injectable()
export class EventsGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(EventsGateway.name);

  handleConnection(client: Socket) {
    this.logger.log(`client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`client disconnected: ${client.id}`);
  }

  /** Broadcast to all connected clients that a new access log was created. */
  emitLogCreated(studentId: string) {
    this.server.emit('log_created', { studentId });
  }
}
