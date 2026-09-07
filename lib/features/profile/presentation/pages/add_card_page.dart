import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/payment_provider.dart';

class AddCardPage extends StatefulWidget {
  final String cardType; // Crédito, Débito, Voucher, Vale Refeição, etc.

  const AddCardPage({super.key, required this.cardType});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  final _numberFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _expiryFocusNode = FocusNode();
  final _cvvFocusNode = FocusNode();

  bool _showBack = false;
  String _cardBrand = 'UNKNOWN';

  @override
  void initState() {
    super.initState();
    
    // Listener do CVV para girar o cartão
    _cvvFocusNode.addListener(() {
      setState(() {
        _showBack = _cvvFocusNode.hasFocus;
      });
    });

    // Listener do Número do Cartão para identificar a bandeira
    _numberController.addListener(() {
      final brand = PaymentProvider.detectCardBrand(_numberController.text);
      if (brand != _cardBrand) {
        setState(() {
          _cardBrand = brand;
        });
      }
    });
  }

  @override
  void dispose() {
    _numberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _numberFocusNode.dispose();
    _nameFocusNode.dispose();
    _expiryFocusNode.dispose();
    _cvvFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onBackgroundLight, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.cardType.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.onBackgroundLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // ─── CARTÃO 3D INTERATIVO (VOLTA E MEIA FLIP) ─────────────────────
                      _buildAnimatedCard(),
                      
                      const SizedBox(height: 36),

                      // ─── FORMULÁRIO ───────────────────────────────────────────
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Número do cartão'),
                            const SizedBox(height: 8),
                            _buildCardNumberField(),

                            const SizedBox(height: 20),

                            _buildInputLabel('Nome do titular (igual ao cartão)'),
                            const SizedBox(height: 8),
                            _buildCardholderNameField(),

                            const SizedBox(height: 20),

                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInputLabel('Validade'),
                                      const SizedBox(height: 8),
                                      _buildExpiryField(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInputLabel('CVV'),
                                      const SizedBox(height: 8),
                                      _buildCvvField(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // ─── BOTÃO SALVAR CARTÃO ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Salvar Cartão',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── RENDERIZADOR DO CARTÃO COM ANIMAÇÃO DE GIRO 3D ──────────────────────────
  Widget _buildAnimatedCard() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      tween: Tween<double>(begin: 0, end: _showBack ? 180 : 0),
      builder: (context, angle, child) {
        final isBack = angle >= 90;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012) // Perspectiva 3D apurada
            ..rotateY(angle * math.pi / 180),
          alignment: Alignment.center,
          child: isBack
              ? Transform(
                  transform: Matrix4.identity()..rotateY(math.pi),
                  alignment: Alignment.center,
                  child: _buildCardBack(),
                )
              : _buildCardFront(),
        );
      },
    );
  }

  Widget _buildCardFront() {
    final Gradient cardGrad = _getCardGradient(_cardBrand);

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: cardGrad,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Holographic orb overlay
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.15,
              child: Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Topo do Cartão: Chip + Símbolo do tipo ou bandeira
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Chip do Cartão com design sofisticado
                    Container(
                      width: 44,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.yellow[200]!, Colors.yellow[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.amber[700]!, width: 0.5),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 8, top: 4, bottom: 4, right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black26, width: 0.5),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 14, top: 8, bottom: 8, right: 14,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black26, width: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Bandeira dinâmica
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _buildBrandIcon(_cardBrand, key: ValueKey(_cardBrand)),
                    ),
                  ],
                ),

                // Meio: Número do Cartão
                Text(
                  _numberController.text.isEmpty
                      ? '0000 0000 0000 0000'
                      : _numberController.text,
                  style: GoogleFonts.sourceCodePro(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    shadows: [
                      const Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 2),
                    ],
                  ),
                ),

                // Rodapé: Nome do Titular e Validade
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NOME DO TITULAR',
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _nameController.text.isEmpty
                                ? 'NOME IGUAL AO CARTÃO'
                                : _nameController.text.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'VALIDADE',
                          style: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _expiryController.text.isEmpty ? 'MM/AA' : _expiryController.text,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    final Gradient cardGrad = _getCardGradient(_cardBrand);

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: cardGrad,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Faixa Magnética Preta
          Container(
            width: double.infinity,
            height: 38,
            color: Colors.black.withValues(alpha: 0.85),
          ),
          const SizedBox(height: 20),
          // Painel de Assinatura e CVV
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.only(right: 12),
                    alignment: Alignment.centerRight,
                    child: Text(
                      'ASSINATURA DO TITULAR',
                      style: GoogleFonts.inter(
                        color: Colors.black26,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 55,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.amber[300]!, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _cvvController.text.isEmpty ? '***' : _cvvController.text,
                    style: GoogleFonts.sourceCodePro(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Declaração de segurança
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'IV PAGO SEGURANÇA 100% CODIFICADA',
                  style: GoogleFonts.inter(
                    color: Colors.white30,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  widget.cardType.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: Colors.white60,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── FORMATADORES E COMPONENTES DE ENTRADA ──────────────────────────────────
  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.onBackgroundLight.withValues(alpha: 0.55),
      ),
    );
  }

  Widget _buildCardNumberField() {
    return TextFormField(
      controller: _numberController,
      focusNode: _numberFocusNode,
      keyboardType: TextInputType.number,
      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      maxLength: 19, // 16 dígitos + 3 espaços
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CardNumberFormatter(),
      ],
      decoration: InputDecoration(
        counterText: '',
        hintText: '0000 0000 0000 0000',
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.redPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.redPrimary, width: 1),
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 14),
          child: _buildBrandIcon(_cardBrand, width: 34, height: 20),
        ),
        suffixIconConstraints: const BoxConstraints(maxHeight: 24),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Insira o número do cartão';
        }
        final clean = value.replaceAll(' ', '');
        if (clean.length < 13) {
          return 'Número de cartão inválido';
        }
        return null;
      },
    );
  }

  Widget _buildCardholderNameField() {
    return TextFormField(
      controller: _nameController,
      focusNode: _nameFocusNode,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.characters,
      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      onChanged: (val) {
        setState(() {}); // Força update da visualização do cartão
      },
      decoration: InputDecoration(
        hintText: 'Como impresso no cartão',
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.redPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.redPrimary, width: 1),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Insira o nome do titular';
        }
        return null;
      },
    );
  }

  Widget _buildExpiryField() {
    return TextFormField(
      controller: _expiryController,
      focusNode: _expiryFocusNode,
      keyboardType: TextInputType.number,
      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      maxLength: 5, // MM/AA
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        ExpiryDateFormatter(),
      ],
      onChanged: (val) {
        setState(() {});
      },
      decoration: InputDecoration(
        counterText: '',
        hintText: 'MM/AA',
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.redPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.redPrimary, width: 1),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Insira a validade';
        }
        if (value.length < 5) {
          return 'Inválido';
        }
        return null;
      },
    );
  }

  Widget _buildCvvField() {
    return TextFormField(
      controller: _cvvController,
      focusNode: _cvvFocusNode,
      keyboardType: TextInputType.number,
      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      maxLength: _cardBrand == 'AMERICANEXPRESS' ? 4 : 3,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      obscureText: true,
      onChanged: (val) {
        setState(() {});
      },
      decoration: InputDecoration(
        counterText: '',
        hintText: '123',
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.redPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.redPrimary, width: 1),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Insira o CVV';
        }
        if (value.length < 3) {
          return 'Inválido';
        }
        return null;
      },
    );
  }

  // ─── AUXILIARES DE ESTILIZAÇÃO E DETECÇÃO DE BANDEIRA ─────────────────────────
  Gradient _getCardGradient(String brand) {
    switch (brand) {
      case 'VISA':
        return const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'MASTERCARD':
        return const LinearGradient(
          colors: [Color(0xFF141E30), Color(0xFF243B55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'ELO':
        return const LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'AMERICANEXPRESS':
        return const LinearGradient(
          colors: [Color(0xFF134E5E), Color(0xFF71B280)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'HIPERCARD':
        return const LinearGradient(
          colors: [Color(0xFFB20A2C), Color(0xFFFB6262)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        // Gradiente padrão - Glassmorphic e vibrante (Vermelho ao roxo)
        return const LinearGradient(
          colors: [Color(0xFFE63946), Color(0xFF833AB4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Widget _buildBrandIcon(String brand, {double width = 48, double height = 30, Key? key}) {
    switch (brand) {
      case 'VISA':
        return SvgPicture.asset(
          'assets/images/VISA.svg',
          width: width,
          height: height,
          fit: BoxFit.contain,
          key: key,
        );
      case 'MASTERCARD':
        return Image.asset(
          'assets/images/MASTERCARD.png',
          width: width,
          height: height,
          fit: BoxFit.contain,
          key: key,
        );
      case 'ELO':
        return Image.asset(
          'assets/images/ELO.png',
          width: width,
          height: height,
          fit: BoxFit.contain,
          key: key,
        );
      case 'AMERICANEXPRESS':
        return Image.asset(
          'assets/images/AMERICANEXPRESS.png',
          width: width,
          height: height,
          fit: BoxFit.contain,
          key: key,
        );
      case 'HIPERCARD':
        return SvgPicture.asset(
          'assets/images/HIPERCARD.svg',
          width: width,
          height: height,
          fit: BoxFit.contain,
          key: key,
        );
      default:
        return const SizedBox.shrink(key: ValueKey('empty'));
    }
  }

  // ─── SALVAMENTO DO CARTÃO ───────────────────────────────────────────────────
  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      
      final card = CreditCardModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        number: _numberController.text,
        holderName: _nameController.text.toUpperCase(),
        expiryDate: _expiryController.text,
        cvv: _cvvController.text,
        brand: _cardBrand,
        type: widget.cardType,
      );

      paymentProvider.addCard(card);

      // Mostrar snackbar de sucesso e voltar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cartão ${card.brand} salvo com sucesso!'),
          backgroundColor: AppColors.greenAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }
}

// FORMATADORES DE TEXTO (FORMATTERS)
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;
    
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    
    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (newText[i] == '/') continue;
      buffer.write(newText[i]);
      var nonZeroIndex = buffer.length;
      if (nonZeroIndex == 2 && i != newText.length - 1) {
        buffer.write('/');
      }
    }
    
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}
