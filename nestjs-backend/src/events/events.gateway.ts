import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Injectable } from '@nestjs/common';
import { Server, Socket } from 'socket.io';

// ── NewSystem pattern: socket.js → events.gateway.ts ──────────────────────────
// Follows the same io.on('connection') lifecycle from backend-node/server/routes/socket.js
@WebSocketGateway({ cors: { origin: '*' } })
@Injectable()
export class EventsGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server: Server;

  handleConnection(client: Socket) {
    console.log(`[WS] client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    console.log(`[WS] client disconnected: ${client.id}`);
  }

  /** Broadcast to all connected clients that a new access log was created. */
  emitLogCreated(studentId: string) {
    this.server.emit('log_created', { studentId });
  }
}
