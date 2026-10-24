import 'package:http_interop/http_interop.dart';
import 'package:http_interop_middleware/http_interop_middleware.dart';
import 'package:test/test.dart';

void main() {
  group('MiddlewareListExt.combine', () {
    test('leaves the handler unchanged for an empty list', () {
      final Handler handler = (_) async =>
          Response(200, Body.empty(), Headers());

      expect(<Middleware>[].combine()(handler), same(handler));
    });

    for (final names in [
      <String>['a'],
      <String>['a', 'b', 'c'],
    ]) {
      test('wraps ${names.length} middleware in list order', () async {
        final calls = <String>[];
        final response = Response(200, Body.empty(), Headers());
        final request = Request('GET', Uri(), Body.empty(), Headers());
        final middlewares = names.map((name) {
          return middleware(
            onRequest: (_) async {
              calls.add('$name request');
              return null;
            },
            onResponse: (_, _) async {
              calls.add('$name response');
              return null;
            },
          );
        }).toList();
        final handler = middlewares.combine()((_) async {
          calls.add('handler');
          return response;
        });

        expect(await handler(request), same(response));
        expect(calls, [
          for (final name in names.reversed) '$name request',
          'handler',
          for (final name in names) '$name response',
        ]);
      });
    }
  });

  group('Unhandled errors', () {
    final middlewares = <String, Middleware>{
      'without onError': middleware(),
      'when onError returns null': middleware(onError: (_, _, _) async => null),
      'through catchResponse': catchResponse,
    };

    for (final entry in middlewares.entries) {
      test('preserves the original stack trace ${entry.key}', () async {
        final error = Exception('handler failed');
        final trace = StackTrace.fromString('original handler stack trace');
        final request = Request('GET', Uri(), Body.empty(), Headers());
        final handler = entry.value(
          (_) => Future<Response>.error(error, trace),
        );

        try {
          await handler(request);
        } catch (caughtError, caughtTrace) {
          expect(caughtError, same(error));
          expect(caughtTrace.toString(), trace.toString());
          return;
        }

        fail('Expected the handler error to propagate.');
      });
    }
  });
}
