import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supervision_mobile/core/api_client.dart';
import 'package:supervision_mobile/core/notification_service.dart';
import 'package:supervision_mobile/core/realtime_service.dart';
import 'package:supervision_mobile/core/theme.dart';
import 'package:supervision_mobile/features/alerts/alerts_cubit.dart';
import 'package:supervision_mobile/features/alerts/alerts_page.dart';
import 'package:supervision_mobile/features/auth/auth_cubit.dart';
import 'package:supervision_mobile/features/servers/servers_cubit.dart';
import 'package:supervision_mobile/features/servers/servers_page.dart';
import 'package:supervision_mobile/widgets/nw_widgets.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiClient>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ServersCubit(api)..startAutoRefresh()),
        BlocProvider(create: (_) => AlertsCubit(api)..startAutoRefresh()),
      ],
      child: const _HomeShellView(),
    );
  }
}

class _HomeShellView extends StatefulWidget {
  const _HomeShellView();

  @override
  State<_HomeShellView> createState() => _HomeShellViewState();
}

class _HomeShellViewState extends State<_HomeShellView> {
  int index = 0;
  final _realtime = RealtimeService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connectSocket());
  }

  Future<void> _connectSocket() async {
    await NotificationService.instance.init();
    if (!mounted) return;
    final api = context.read<ApiClient>();
    final serversCubit = context.read<ServersCubit>();
    final alertsCubit = context.read<AlertsCubit>();
    _realtime.connect(
      baseUrl: api.baseUrl,
      onAlert: (data) async {
        alertsCubit.load(silent: true);
        serversCubit.load(silent: true);
        final map = data is Map ? data : <String, dynamic>{};
        final title = 'NetWatch · ${map['severity'] ?? 'alerte'}'.toUpperCase();
        final body = map['message']?.toString() ?? 'Nouvelle alerte';
        await NotificationService.instance.showAlert(title: title, body: body);
      },
      onServer: (_) {
        serversCubit.load(silent: true);
      },
      onMetric: (_) {
        serversCubit.load(silent: true);
      },
    );
    serversCubit.setLive(true);
    alertsCubit.setLive(true);
  }

  @override
  void dispose() {
    _realtime.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    final name = user?['name']?.toString() ?? 'Administrateur';
    final openAlerts = context.watch<AlertsCubit>().state.openCount;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.8, -1.0),
            radius: 1.2,
            colors: [
              NwColors.accent.withValues(alpha: 0.08),
              NwColors.bg,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
                child: Row(
                  children: [
                    const NwBrandMark(height: 34, width: 11),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NetWatch',
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            index == 0 ? 'Parc informatique' : 'Centre d’alertes',
                            style: const TextStyle(color: NwColors.muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Actualiser',
                      onPressed: () {
                        context.read<ServersCubit>().load();
                        context.read<AlertsCubit>().load();
                      },
                      icon: const Icon(Icons.refresh_rounded, color: NwColors.muted),
                    ),
                    IconButton(
                      tooltip: 'Déconnexion ($name)',
                      onPressed: () => context.read<AuthCubit>().logout(),
                      icon: const Icon(Icons.logout_rounded, color: NwColors.muted),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: index,
                  children: const [ServersPage(), AlertsPage()],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dns_outlined),
            selectedIcon: Icon(Icons.dns),
            label: 'Serveurs',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: openAlerts > 0,
              label: Text('$openAlerts'),
              backgroundColor: NwColors.crit,
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: openAlerts > 0,
              label: Text('$openAlerts'),
              backgroundColor: NwColors.crit,
              child: const Icon(Icons.notifications),
            ),
            label: 'Alertes',
          ),
        ],
      ),
    );
  }
}
