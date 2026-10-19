import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supervision_mobile/core/api_client.dart';

class ServersState extends Equatable {
  const ServersState({
    this.servers = const [],
    this.loading = false,
    this.refreshing = false,
    this.live = false,
    this.error,
    this.updatedAt,
  });

  final List<dynamic> servers;
  final bool loading;
  final bool refreshing;
  final bool live;
  final String? error;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [servers, loading, refreshing, live, error, updatedAt];
}

class ServersCubit extends Cubit<ServersState> {
  ServersCubit(this.api) : super(const ServersState());

  final ApiClient api;
  Timer? _timer;

  void setLive(bool value) {
    emit(ServersState(
      servers: state.servers,
      live: value,
      updatedAt: state.updatedAt,
      error: state.error,
    ));
  }

  /// Polling de secours (plus lent si Socket.IO est actif).
  void startAutoRefresh({Duration interval = const Duration(seconds: 20)}) {
    load();
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => load(silent: true));
  }

  Future<void> load({bool silent = false}) async {
    if (silent) {
      emit(ServersState(
        servers: state.servers,
        refreshing: true,
        live: state.live,
        updatedAt: state.updatedAt,
      ));
    } else {
      emit(ServersState(
        servers: state.servers,
        loading: true,
        live: state.live,
        updatedAt: state.updatedAt,
      ));
    }
    try {
      final data = await api.get('/api/servers') as List<dynamic>;
      emit(ServersState(
        servers: List<dynamic>.from(data),
        live: state.live,
        updatedAt: DateTime.now(),
      ));
    } catch (e) {
      emit(ServersState(
        servers: state.servers,
        live: state.live,
        error: e.toString().replaceFirst('Exception: ', ''),
        updatedAt: state.updatedAt,
      ));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
