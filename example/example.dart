import 'package:http_interop/http_interop.dart';
import 'package:http_interop_middleware/http_interop_middleware.dart';

Future<void> main() async {
  final logResponse = middleware(
    onResponse: (response, _) async {
      print('Response: ${response.statusCode}');
      return null;
    },
  );
  final logRequest = middleware(
    onRequest: (request) async {
      print('Request: ${request.method} ${request.uri}');
      return null;
    },
  );

  final handler = [logResponse, logRequest].combine()(
    (_) async => Response(200, Body.empty(), Headers()),
  );

  await handler(Request('GET', Uri.parse('/hello'), Body.empty(), Headers()));
}
