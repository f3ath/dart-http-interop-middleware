import 'package:http_interop/http_interop.dart';
import 'package:http_interop_middleware/http_interop_middleware.dart';
import 'package:test/test.dart';

main() {
  final ok = Response(200, Body(), Headers());
  final ise = Response(500, Body(), Headers());

  final get = Request('get', Uri(), Body(), Headers());
  final post = Request('post', Uri(), Body(), Headers());

  Request? loggedRequest;
  Response? loggedResponse;

  returnOk(Request request) async {
    loggedRequest = request;
    return ok;
  }

  returnError(Request request) async {
    loggedRequest = request;
    return ise;
  }

  throwISEOnPost(Request request) async {
    loggedRequest = request;
    if (request.method == 'post') throw ise;
    return ok;
  }

  setUp(() {
    loggedRequest = null;
    loggedResponse = null;
  });

  group('Middleware', () {
    test('Can wrap a handler', () async {
      final wrapped = middleware()(returnOk);
      expect(await wrapped(get), same(ok));
      expect(loggedRequest, same(get));
    });

    test('Calls onRequest', () async {
      final wrapped = middleware(onRequest: (Request request) async {
        if (request.method == 'post') return ise;
        return null;
      })(returnOk);
      expect(await wrapped(post), same(ise));
      expect(loggedRequest, isNull);
      expect(await wrapped(get), same(ok));
      expect(loggedRequest, same(get));
    });

    test('Calls onResponse', () async {
      final wrapped = middleware(onResponse: (Response response) async {
        loggedResponse = response;
        if (response.statusCode == 500) return ok;
        return null;
      })(returnError);
      expect(await wrapped(get), same(ok));
      expect(loggedResponse, same(ise));

      expect(await wrapped(post), same(ok));
      expect(loggedRequest, same(post));
      expect(loggedResponse, same(ise));
    });
  });

  group('CatchResponse', () {
    test('catches response', () async {
      final wrapped = catchResponse(throwISEOnPost);
      expect(await wrapped(get), equals(ok));
      expect(await wrapped(post), equals(ise));
    });
  });

}
