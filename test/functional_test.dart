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
      final wrapped = middleware(onResponse: (Response response, _) async {
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

    test('Middleware.add combines two middleware functions', () async {
      final mw1 = middleware(onRequest: (Request request) async {
        if (request.method == 'get') {
          return Response(201, Body(), Headers());
        }
        return null;
      });

      final mw2 = middleware(onResponse: (Response response, _) async {
        if (response.statusCode == 201) {
          return Response(202, Body(), Headers());
        }
        return null;
      });

      final Handler return200 = (Request request) async {
        return Response(200, Body(), Headers());
      };

      final oneTwo = await mw1.add(mw2)(return200)(get);
      final twoOne = await mw2.add(mw1)(return200)(get);
      expect(oneTwo.statusCode, equals(202));
      expect(twoOne.statusCode, equals(201));
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
