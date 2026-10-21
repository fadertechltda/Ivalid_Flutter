import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

/// Erro devolvido pela API (ou falha de rede). [message] já serve para o usuário.
class ApiException implements Exception {
  final int statusCode;

  /// `CodigoExcecao` da API (0–8), quando o corpo trouxer.
  final int? codigo;
  final String message;

  /// Em `409` de pedido, o resumo com a lista `problemas` (itens indisponíveis).
  final Map<String, dynamic>? resumo;

  const ApiException(
    this.message, {
    this.statusCode = 0,
    this.codigo,
    this.resumo,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isNetwork => statusCode == 0;

  /// Itens que a API recusou (estoque/indisponibilidade), se houver.
  List<Map<String, dynamic>> get problemas {
    final raw = resumo?['problemas'];
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().toList();
  }

  @override
  String toString() => message;
}

/// Cliente HTTP da API. Anexa o token do Firebase quando há usuário logado.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);

  Future<dynamic> post(String path, {Object? body}) =>
      _send('POST', path, body: body);

  Future<dynamic> put(String path, {Object? body}) =>
      _send('PUT', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path')
        .replace(queryParameters: (query == null || query.isEmpty) ? null : query);

    final headers = <String, String>{'Accept': 'application/json'};
    final token = await _idToken();
    if (token != null) headers['Authorization'] = 'Bearer $token';
    if (body != null) headers['Content-Type'] = 'application/json';

    final request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _client.send(request).timeout(ApiConfig.timeout),
      );
    } on TimeoutException {
      throw const ApiException(
        'O servidor demorou para responder. Tente novamente em instantes.',
      );
    } catch (_) {
      throw const ApiException(
        'Sem conexão com o servidor. Verifique sua internet.',
      );
    }

    dynamic decoded;
    if (response.bodyBytes.isNotEmpty) {
      try {
        decoded = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {
        decoded = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    throw _toException(response.statusCode, decoded);
  }

  Future<String?> _idToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      return await user.getIdToken();
    } catch (_) {
      return null;
    }
  }

  static ApiException _toException(int status, dynamic body) {
    final map = body is Map<String, dynamic> ? body : const <String, dynamic>{};
    final codigo = (map['codigo'] as num?)?.toInt();
    final info = map['informacaoAdicional'];
    final resumo = map['resumo'];

    String? fromBody;
    if (info is String && info.isNotEmpty) {
      fromBody = info;
    } else if (map['title'] is String) {
      fromBody = map['title'] as String;
    }

    final message = switch (status) {
      401 => 'Sua sessão expirou. Entre novamente.',
      403 => 'Você não tem permissão para esta ação.',
      404 => fromBody ?? 'Não encontramos o que você procurava.',
      >= 500 => 'O servidor está indisponível no momento. Tente novamente.',
      _ => fromBody ?? 'Não foi possível concluir a operação (código $status).',
    };

    return ApiException(
      message,
      statusCode: status,
      codigo: codigo,
      resumo: resumo is Map<String, dynamic> ? resumo : null,
    );
  }

  void dispose() => _client.close();
}
