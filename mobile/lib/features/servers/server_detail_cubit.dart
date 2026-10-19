import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supervision_mobile/core/api_client.dart';

class ServerDetailState extends Equatable {
  const ServerDetailState({
    this.server,
    this.metrics = const [],
    this.loading = false,
    this.refreshing = false,
    this.error,
    this.updatedAt,
  });

  final Map<String, dynamic>? server;
  final List<dynamic> metrics;
  final bool loading;
  final bool refreshing;
  final String? error;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [server, metrics, loading, refreshing, error, updatedAt];
}

class ServerDetailCubit extends Cubit<ServerDetailState> {
  ServerDetailCubit(this.api, this.serverId) : super(const ServerDetailState());

  final ApiClient api;
  final String serverId;
  Timer? _timer;

  void startAutoRefresh() {
    load();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => load(silent: true));
  }

  Future<void> load({bool silent = false}) async {
    if (silent) {
      emit(ServerDetailState(
        server: state.server,
        metrics: state.metrics,
        refreshing: true,
        updatedAt: state.updatedAt,
      ));
    } else {
      emit(ServerDetailState(
        server: state.server,
        metrics: state.metrics,
        loading: true,
        updatedAt: state.updatedAt,
      ));
    }
    try {
      final server = await api.get('/api/servers/$serverId') as Map<String, dynamic>;
      final metrics = await api.get(
        '/api/metrics/$serverId?sinceMinutes=60&limit=120',
      ) as List<dynamic>;
      emit(ServerDetailState(
        server: server,
        metrics: List<dynamic>.from(metrics),
        updatedAt: DateTime.now(),
      ));
    } catch (e) {
      emit(ServerDetailState(
        server: state.server,
        metrics: state.metrics,
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
