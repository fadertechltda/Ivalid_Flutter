import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ivalid/core/theme/app_colors.dart';

import '../widgets/settings_widgets.dart';

/// Dados da conta — exibe e edita o perfil do usuário no Firestore.
class AccountDataPage extends StatefulWidget {
  const AccountDataPage({super.key});

  @override
  State<AccountDataPage> createState() => _AccountDataPageState();
}

class _AccountDataPageState extends State<AccountDataPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = _user;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      _nameController.text =
          (data?['fullName'] as String?) ?? user.displayName ?? '';
      _phoneController.text = (data?['phone'] as String?) ?? '';
    } catch (e) {
      debugPrint('Erro ao carregar dados da conta: $e');
      _nameController.text = user.displayName ?? '';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = _user;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final name = _nameController.text.trim();
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': name,
        'phone': _phoneController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await user.updateDisplayName(name);

      if (!mounted) return;
      _showMessage('Dados atualizados com sucesso!');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Não foi possível salvar: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
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
    final createdAt = user?.metadata.creationTime;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: context.onBg),
        title: Text(
          'Dados da conta',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: context.onBg,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                children: [
                  const SettingsSectionLabel('Informações pessoais'),
                  _buildField(
                    controller: _nameController,
                    label: 'Nome completo',
                    icon: Icons.person_outline_rounded,
                    validator: (v) => (v == null || v.trim().length < 3)
                        ? 'Informe seu nome completo'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _phoneController,
                    label: 'Telefone',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  const SettingsSectionLabel('Conta'),
                  SettingsCard(
                    children: [
                      SettingsTile(
                        icon: Icons.email_outlined,
                        title: 'E-mail',
                        subtitle: user?.email ?? 'Não informado',
                        iconColor: AppColors.greenAccent,
                      ),
                      SettingsTile(
                        icon: Icons.verified_user_outlined,
                        title: 'E-mail verificado',
                        subtitle:
                            (user?.emailVerified ?? false) ? 'Sim' : 'Não',
                        iconColor: AppColors.greenAccent,
                      ),
                      if (createdAt != null)
                        SettingsTile(
                          icon: Icons.calendar_today_outlined,
                          title: 'Membro desde',
                          subtitle: DateFormat('dd/MM/yyyy', 'pt_BR')
                              .format(createdAt),
                          iconColor: AppColors.greenAccent,
                        ),
                    ],
                  ),

                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Salvar alterações',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 14, color: context.onBg),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: context.onBgAlpha(0.5)),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          color: context.onBgAlpha(0.5),
        ),
        filled: true,
        fillColor: context.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.redPrimary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
