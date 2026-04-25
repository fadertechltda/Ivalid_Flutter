import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ivalid/core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import 'package:ivalid/features/home/presentation/pages/home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _termsError;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _emailRegex = RegExp(r'^[A-Za-z0-9+_.\-]+@[A-Za-z0-9.\-]+$');

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  bool get _isSignUpEnabled =>
      _nameController.text.isNotEmpty &&
      _emailController.text.isNotEmpty &&
      _passwordController.text.length >= 6 &&
      _confirmPasswordController.text.isNotEmpty &&
      _acceptTerms;

  bool _validate() {
    String? nameErr;
    String? emailErr;
    String? passwordErr;
    String? confirmPasswordErr;
    String? termsErr;

    if (_nameController.text.trim().length < 3) {
      nameErr = 'Informe seu nome completo';
    }
    if (!_emailRegex.hasMatch(_emailController.text)) {
      emailErr = 'E-mail inválido';
    }
    if (_passwordController.text.length < 6) {
      passwordErr = 'Mínimo 6 caracteres';
    }
    if (_confirmPasswordController.text != _passwordController.text) {
      confirmPasswordErr = 'As senhas não coincidem';
    }
    if (!_acceptTerms) {
      termsErr = 'Você precisa aceitar os termos';
    }

    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _passwordError = passwordErr;
      _confirmPasswordError = confirmPasswordErr;
      _termsError = termsErr;
    });

    return nameErr == null &&
        emailErr == null &&
        passwordErr == null &&
        confirmPasswordErr == null &&
        termsErr == null;
  }

  void _doSignup() async {
    if (!_validate()) return;

    FocusScope.of(context).unfocus();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final success = await auth.signup(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.onBackgroundLight,
                  ),
                  padding: const EdgeInsets.all(20),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ─── Logo (menor no signup) ───────────────
                          Image.asset(
                            'assets/images/logo_ivalid.png',
                            width: 96,
                            height: 96,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),

                          // ─── Headline ─────────────────────────────
                          Text(
                            'Crie sua conta',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),

                          // ─── Accent bar (green like Kotlin) ───────
                          Container(
                            height: 4,
                            width: 64,
                            decoration: BoxDecoration(
                              color: AppColors.greenAccent.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 8),

                          Text(
                            'Preencha seus dados para começar',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.onBackgroundLight
                                      .withOpacity(0.75),
                                ),
                          ),
                          const SizedBox(height: 28),

                          // ─── Card de formulário ───────────────────
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 32,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // Full Name
                                TextField(
                                  controller: _nameController,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) {
                                    if (_nameError != null) {
                                      setState(() => _nameError = null);
                                    }
                                  },
                                  style:
                                      Theme.of(context).textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    labelText: 'Nome completo',
                                    filled: true,
                                    fillColor: AppColors.backgroundLight,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: AppColors.outlineLight.withOpacity(0.5), width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: AppColors.greenAccent, width: 1.5),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: AppColors.redPrimary, width: 1.5),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      color: _nameController.text.isNotEmpty
                                          ? AppColors.greenAccent
                                          : AppColors.onBackgroundLight
                                              .withOpacity(0.4),
                                    ),
                                    errorText: _nameError,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Email
                                TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) {
                                    if (_emailError != null) {
                                      setState(() => _emailError = null);
                                    }
                                  },
                                  style:
                                      Theme.of(context).textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    labelText: 'E-mail',
                                    filled: true,
                                    fillColor: AppColors.backgroundLight,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: AppColors.outlineLight.withOpacity(0.5), width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: AppColors.greenAccent, width: 1.5),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: AppColors.redPrimary, width: 1.5),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: _emailController.text.isNotEmpty
                                          ? AppColors.greenAccent
                                          : AppColors.onBackgroundLight
                                              .withOpacity(0.4),
                                    ),
                                    errorText: _emailError,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Password
                                TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) {
                                    if (_passwordError != null) {
                                      setState(() => _passwordError = null);
                                    }
                                  },
                                  style:
                                      Theme.of(context).textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    labelText: 'Senha',
                                    filled: true,
                                    fillColor: AppColors.backgroundLight,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: AppColors.outlineLight.withOpacity(0.5), width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: AppColors.greenAccent, width: 1.5),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: AppColors.redPrimary, width: 1.5),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color:
                                          _passwordController.text.isNotEmpty
                                              ? AppColors.greenAccent
                                              : AppColors.onBackgroundLight
                                                  .withOpacity(0.4),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: _obscurePassword
                                            ? AppColors.onBackgroundLight
                                                .withOpacity(0.4)
                                            : AppColors.greenAccent,
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscurePassword =
                                              !_obscurePassword),
                                    ),
                                    errorText: _passwordError,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Confirm Password
                                TextField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  textInputAction: TextInputAction.done,
                                  onChanged: (_) {
                                    if (_confirmPasswordError != null) {
                                      setState(
                                          () => _confirmPasswordError = null);
                                    }
                                  },
                                  onSubmitted: (_) {
                                    if (_isSignUpEnabled && !auth.isLoading) {
                                      _doSignup();
                                    }
                                  },
                                  style:
                                      Theme.of(context).textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    labelText: 'Confirmar senha',
                                    filled: true,
                                    fillColor: AppColors.backgroundLight,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: AppColors.outlineLight.withOpacity(0.5), width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: AppColors.greenAccent, width: 1.5),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: AppColors.redPrimary, width: 1.5),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: _confirmPasswordController
                                              .text.isNotEmpty
                                          ? AppColors.greenAccent
                                          : AppColors.onBackgroundLight
                                              .withOpacity(0.4),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: _obscureConfirmPassword
                                            ? AppColors.onBackgroundLight
                                                .withOpacity(0.4)
                                            : AppColors.greenAccent,
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword),
                                    ),
                                    errorText: _confirmPasswordError,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Terms & Privacy
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _acceptTerms,
                                        onChanged: (val) {
                                          setState(() {
                                            _acceptTerms = val ?? false;
                                            _termsError = null;
                                          });
                                        },
                                        activeColor: AppColors.redPrimary,
                                        checkColor: Colors.white,
                                        side: BorderSide(
                                          color: AppColors.outlineLight,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 2),
                                        child: RichText(
                                          text: TextSpan(
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: AppColors
                                                  .onBackgroundLight,
                                            ),
                                            children: [
                                              const TextSpan(
                                                  text:
                                                      'Li e aceito os '),
                                              TextSpan(
                                                text: 'Termos de Uso',
                                                style: GoogleFonts.inter(
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: AppColors
                                                      .greenAccent,
                                                  decoration: TextDecoration
                                                      .underline,
                                                  decorationColor:
                                                      AppColors
                                                          .greenAccent,
                                                ),
                                              ),
                                              const TextSpan(
                                                  text: ' e a '),
                                              TextSpan(
                                                text:
                                                    'Política de Privacidade',
                                                style: GoogleFonts.inter(
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: AppColors
                                                      .greenAccent,
                                                  decoration: TextDecoration
                                                      .underline,
                                                  decorationColor:
                                                      AppColors
                                                          .greenAccent,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                if (_termsError != null) ...[
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 4),
                                      child: Text(
                                        _termsError!,
                                        style: GoogleFonts.inter(
                                          color: AppColors.redPrimary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                // Auth error
                                if (auth.errorMessage != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.redPrimary
                                          .withOpacity(0.08),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      auth.errorMessage!,
                                      style: GoogleFonts.inter(
                                        color: AppColors.redPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ─── Gradient Red Button ──────────────────
                          _GradientRedButton(
                            text: auth.isLoading
                                ? 'Criando...'
                                : 'Criar conta',
                            enabled: !auth.isLoading,
                            isLoading: auth.isLoading,
                            onPressed: _doSignup,
                          ),

                          const SizedBox(height: 20),

                          // ─── Back to login ────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Já tem uma conta?',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: AppColors.onBackgroundLight
                                          .withOpacity(0.75),
                                    ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  auth.clearError();
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Entrar',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.greenAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Botão gradiente vermelho ───────────────────────────────────────────────
class _GradientRedButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const _GradientRedButton({
    required this.text,
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  AppColors.redPrimary.withOpacity(enabled ? 1.0 : 0.5),
                  AppColors.redPrimaryDark.withOpacity(enabled ? 1.0 : 0.5),
                ],
              ),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: AppColors.redPrimary.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      text,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}



