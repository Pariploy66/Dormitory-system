import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Real-time Socket.IO client — NewSystem pattern from socketio.service.js
/// Emits a [studentId] string on [logCreatedStream] whenever the server
/// broadcasts a 'log_created' event (fired on every new access-log ingest).
class SocketService {
  io.Socket? _socket;
  final _controller = StreamController<String>.broadcast();

  Stream<String> get logCreatedStream => _controller.stream;
  bool get isConnected => _socket?.connected ?? false;

  /// Connect to the NestJS server.  Call once from [setupServiceLocator].
  void connect(String baseUrl) {
    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableReconnection()
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) => _log('connected'));
    _socket!.onDisconnect((_) => _log('disconnected'));
    _socket!.onConnectError((e) => _log('connect error: $e'));

    _socket!.on('log_created', (data) {
      final studentId = (data as Map?)?['studentId'] as String? ?? '';
      if (studentId.isNotEmpty && !_controller.isClosed) {
        _controller.add(studentId);
      }
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    if (!_controller.isClosed) _controller.close();
  }

  void _log(String msg) => debugPrint('[Socket] $msg');
}
