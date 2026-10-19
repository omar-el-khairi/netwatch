import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supervision_mobile/core/api_client.dart';

enum AlertFilter { all, open, critical }

class AlertsState extends Equatable {
  const AlertsState({
    this.alerts = const [],
    this.filter = AlertFilter.all,
    this.loading = false,
    this.refreshing = false,
    this.live = false,
    this.error,
    this.updatedAt,
  });

  final List<dynamic> alerts;
  final AlertFilter filter;
  final bool loading;
  final bool refreshing;
  final bool live;
  final String? error;
  final DateTime? updatedAt;

  List<dynamic> get filtered {
    switch (filter) {
      case AlertFilter.open:
        return alerts.where((a) => (a as Map)['acknowledged'] != true).toList();
      case AlertFilter.critical:
        return alerts.where((a) => (a as Map)['severity'] == 'critical').toList();
      case AlertFilter.all:
        return alerts;
    }
  }

  int get openCount =>
      alerts.where((a) => (a as Map)['acknowledged'] != true).length;

  @override
  List<Object?> get props =>
      [alerts, filter, loading, refreshing, live, error, updatedAt];
}

class AlertsCubit extends Cubit<AlertsState> {
  AlertsCubit(this.api) : super(const AlertsState());

  final ApiClient api;
  Timer? _timer;

  void setLive(bool value) {
    emit(AlertsState(
      alerts: state.alerts,
      filter: state.filter,
      live: value,
      updatedAt: state.updatedAt,
    ));
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 20)}) {
    load();
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => load(silent: true));
  }

  void setFilter(AlertFilter filter) {
    emit(AlertsState(
      alerts: state.alerts,
      filter: filter,
      live: state.live,
      updatedAt: state.updatedAt,
    ));
  }

  Future<void> load({bool silent = false}) async {
    if (silent) {
      emit(AlertsState(
        alerts: state.alerts,
        filter: state.filter,
        refreshing: true,
        live: state.live,
        updatedAt: state.updatedAt,
      ));
    } else {
      emit(AlertsState(
        alerts: state.alerts,
        filter: state.filter,
        loading: true,
        live: state.live,
        updatedAt: state.updatedAt,
      ));
    }
    try {
      final data = await api.get('/api/alerts?limit=80') as List<dynamic>;
      emit(AlertsState(
        alerts: List<dynamic>.from(data),
        filter: state.filter,
        live: state.live,
        updatedAt: DateTime.now(),
      ));
    } catch (e) {
      emit(AlertsState(
        alerts: state.alerts,
        filter: state.filter,
        live: state.live,
        error: e.toString().replaceFirst('Exception: ', ''),
        updatedAt: state.updatedAt,
      ));
    }
  }

  Future<void> acknowledge(String id) async {
    await api.post('/api/alerts/$id/acknowledge');
    await load(silent: true);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
