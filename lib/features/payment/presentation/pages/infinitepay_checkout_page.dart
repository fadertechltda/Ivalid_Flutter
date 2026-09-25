import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/payment_models.dart';
import '../../domain/payment_config.dart';

/// Abre o checkout do InfinitePay dentro do app e captura o redirecionamento
/// de "pagamento concluído".
///
/// Devolve (via `Navigator.pop`) o [CheckoutRedirect] com os dados do
/// pagamento, ou `null` se o usuário fechar a tela antes de concluir.
class InfinitePayCheckoutPage extends StatefulWidget {
  final String checkoutUrl;

  const InfinitePayCheckoutPage({super.key, required this.checkoutUrl});

  /// A WebView só existe em Android e iOS.
  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  State<InfinitePayCheckoutPage> createState() =>
      _InfinitePayCheckoutPageState();
}

class _InfinitePayCheckoutPageState extends State<InfinitePayCheckoutPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _onNavigationRequest,
          onPageStarted: (_) => setState(() {
            _isLoading = true;
            _hasError = false;
          }),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) {
            // Erros de sub-recursos (imagens, scripts de métricas) não devem
            // derrubar a tela; só a página principal importa.
            if (error.isForMainFrame ?? false) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    if (request.url.startsWith(PaymentConfig.redirectUrl)) {
      final redirect = CheckoutRedirect.tryParse(Uri.parse(request.url));
      // Sem os identificadores não dá para confirmar o pagamento: trata como
      // cancelado em vez de fingir que deu certo.
      Navigator.of(context).pop(redirect);
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: context.onBg),
          tooltip: 'Cancelar pagamento',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Icon(Icons.lock_rounded, size: 16, color: context.onBgAlpha(0.6)),
            const SizedBox(width: 8),
            Text(
              'Pagamento seguro',
              style: GoogleFonts.inter(
                color: context.onBg,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          if (!_hasError) WebViewWidget(controller: _controller),
          if (_isLoading && !_hasError)
            const Center(
              child: CircularProgressIndicator(color: AppColors.redPrimary),
            ),
          if (_hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off_rounded,
                        size: 48, color: context.onBgAlpha(0.4)),
                    const SizedBox(height: 16),
                    Text(
                      'Não foi possível carregar o pagamento.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.onBg,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _hasError = false);
                        _controller.loadRequest(Uri.parse(widget.checkoutUrl));
                      },
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
