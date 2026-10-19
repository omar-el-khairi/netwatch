import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supervision_mobile/core/api_client.dart';
import 'package:supervision_mobile/core/theme.dart';
import 'package:supervision_mobile/features/auth/auth_cubit.dart';
import 'package:supervision_mobile/widgets/nw_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController(text: 'admin@supervision.local');
  final passCtrl = TextEditingController(text: 'Admin123!');
  late final TextEditingController apiCtrl;
  bool busy = false;
  bool obscure = true;
  bool showAdvanced = false;

  @override
  void initState() {
    super.initState();
    apiCtrl = TextEditingController(text: ApiClient.fallbackBaseUrl);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final api = context.read<ApiClient>();
      if (api.baseUrl.isNotEmpty) {
        apiCtrl.text = api.baseUrl;
      }
    });
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    apiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final urlError = ApiClient.validateBaseUrl(apiCtrl.text);
    if (urlError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(urlError), backgroundColor: NwColors.crit),
      );
      return;
    }
    setState(() => busy = true);
    await context.read<AuthCubit>().login(
          emailCtrl.text.trim(),
          passCtrl.text,
          apiUrl: apiCtrl.text.trim(),
        );
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Atmosphere background
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.6, -0.7),
                  radius: 1.1,
                  colors: [
                    NwColors.accent.withValues(alpha: 0.16),
                    NwColors.bg,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -40,
            top: 80,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    NwColors.info.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom -
                          48,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const NwBrandMark(height: 52, width: 16),
                        const SizedBox(height: 20),
                        Text(
                          'NetWatch',
                          style: GoogleFonts.dmSans(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.2,
                            color: NwColors.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Supervision réseau à distance.\nAlertes et statuts en un coup d’œil.',
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            height: 1.45,
                            color: NwColors.muted,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: NwColors.panel.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: NwColors.line),
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.mail_outline, color: NwColors.muted),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: passCtrl,
                                obscureText: obscure,
                                decoration: InputDecoration(
                                  labelText: 'Mot de passe',
                                  prefixIcon: const Icon(Icons.lock_outline, color: NwColors.muted),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() => obscure = !obscure),
                                    icon: Icon(
                                      obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                      color: NwColors.muted,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () => setState(() => showAdvanced = !showAdvanced),
                                  child: Text(
                                    showAdvanced ? 'Masquer l’URL API' : 'Configurer l’URL API',
                                    style: const TextStyle(color: NwColors.accent, fontSize: 13),
                                  ),
                                ),
                              ),
                              if (showAdvanced) ...[
                                TextField(
                                  controller: apiCtrl,
                                  keyboardType: TextInputType.url,
                                  decoration: const InputDecoration(
                                    labelText: 'URL API',
                                    hintText: 'http://192.168.1.135:4000',
                                    prefixIcon: Icon(Icons.dns_outlined, color: NwColors.muted),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (state.error != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: NwColors.crit.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: NwColors.crit.withValues(alpha: 0.35)),
                                  ),
                                  child: Text(
                                    state.error!,
                                    style: const TextStyle(color: NwColors.crit, fontSize: 13),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: busy ? null : _submit,
                                  child: Text(busy ? 'Connexion…' : 'Se connecter'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'MST-RSI · FST Settat',
                          style: GoogleFonts.dmSans(color: NwColors.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
