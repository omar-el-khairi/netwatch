import 'package:socket_io_client/socket_io_client.dart' as io;

typedef JsonHandler = void Function(dynamic data);

class RealtimeService {
  io.Socket? _socket;

  bool get connected => _socket?.connected == true;

  void connect({
    required String baseUrl,
    required JsonHandler onAlert,
    required JsonHandler onServer,
    JsonHandler? onMetric,
  }) {
    disconnect();
    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!
      ..onConnect((_) {})
      ..onDisconnect((_) {})
      ..on('alert:new', onAlert)
      ..on('alert:updated', onAlert)
      ..on('server:update', onServer);

    if (onMetric != null) {
      _socket!.on('metric:new', onMetric);
    }
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }
}
