import 'package:flutter/material.dart';
import 'package:supervision_mobile/core/theme.dart';
import 'package:supervision_mobile/features/auth/auth_cubit.dart';
import 'package:supervision_mobile/features/auth/login_page.dart';
import 'package:supervision_mobile/features/home/home_shell.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supervision_mobile/core/api_client.dart';
import 'package:supervision_mobile/core/auth_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NetWatchApp());
}

class NetWatchApp extends StatelessWidget {
  const NetWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiClient();
    final authRepo = AuthRepository(api);

    return RepositoryProvider.value(
      value: api,
      child: BlocProvider(
        create: (_) => AuthCubit(authRepo)..restore(),
        child: MaterialApp(
          title: 'NetWatch',
          debugShowCheckedModeBanner: false,
          theme: buildNetWatchTheme(),
          home: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state.status == AuthStatus.unknown) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: NwColors.accent),
                  ),
                );
              }
              if (state.status == AuthStatus.authenticated) {
                return const HomeShell();
              }
              return const LoginPage();
            },
          ),
        ),
      ),
    );
  }
}
