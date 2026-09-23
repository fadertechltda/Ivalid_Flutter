import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ivalid/core/theme/app_colors.dart';

import '../widgets/settings_widgets.dart';

/// Segurança — redefinição de senha e verificação de e-mail.
class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _isBusy = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  Future<void> _sendPasswordReset() async {
    final email = _user?.email;
    if (email == null || email.isEmpty) {
      _showMessage('Nenhum e-mail associado à conta.', isError: true);
      return;
    }

    final confirmed = await _confirm(
      title: 'Redefinir senha',
      message: 'Enviaremos um link de redefinição de senha para $email.',
      confirmLabel: 'Enviar link',
    );
    if (confirmed != true) return;

    setState(() => _isBusy = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showMessage('Link enviado para $email. Verifique sua caixa de entrada.');
    } on FirebaseAuthException catch (e) {
      _showMessage('Erro ao enviar: ${e.message ?? e.code}', isError: true);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _sendEmailVerification() async {
    final user = _user;
    if (user == null) return;

    if (user.emailVerified) {
      _showMessage('Seu e-mail já está verificado.');
      return;
    }

    setState(() => _isBusy = true);
    try {
      await user.sendEmailVerification();
      _showMessage('E-mail de verificação enviado para ${user.email}.');
    } on FirebaseAuthException catch (e) {
      _showMessage('Erro ao enviar: ${e.message ?? e.code}', isError: true);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _signOutEverywhere() async {
    final confirmed = await _confirm(
      title: 'Encerrar sessão',
      message:
          'Você será desconectado neste dispositivo e precisará entrar novamente.',
      confirmLabel: 'Sair',
      isDestructive: true,
    );
    if (confirmed != true) return;

    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: ctx.onBg,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(fontSize: 14, color: ctx.onBgAlpha(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor:
                  isDestructive ? AppColors.redPrimary : AppColors.greenAccent,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.redPrimary : AppColors.greenAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final isVerified = user?.emailVerified ?? false;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: context.onBg),
        title: Text(
          'Segurança',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: context.onBg,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              const SettingsSectionLabel('Acesso'),
              SettingsCard(
                children: [
                  SettingsTile(
                    icon: Icons.lock_reset_rounded,
                    title: 'Alterar senha',
                    subtitle: 'Receba um link seguro por e-mail',
                    onTap: _isBusy ? null : _sendPasswordReset,
                  ),
                  SettingsTile(
                    icon: isVerified
                        ? Icons.verified_rounded
                        : Icons.mark_email_unread_outlined,
                    title: 'Verificação de e-mail',
                    subtitle: isVerified
                        ? 'E-mail verificado'
                        : 'Toque para enviar o e-mail de verificação',
                    iconColor:
                        isVerified ? AppColors.greenAccent : AppColors.redPrimary,
                    onTap: _isBusy ? null : _sendEmailVerification,
                  ),
                ],
              ),
              const SettingsSectionLabel('Sessão'),
              SettingsCard(
                children: [
                  SettingsTile(
                    icon: Icons.logout_rounded,
                    title: 'Encerrar sessão',
                    subtitle: 'Sair da conta neste dispositivo',
                    titleColor: AppColors.redPrimary,
                    onTap: _isBusy ? null : _signOutEverywhere,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Nunca compartilhe sua senha. O Ivalid nunca pedirá seus dados '
                'por telefone ou mensagem.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: context.onBgAlpha(0.45),
                ),
              ),
            ],
          ),
          if (_isBusy)
            Container(
              color: Colors.black.withValues(alpha: 0.15),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
