import 'package:http_interop/http_interop.dart';

/// A [Middleware] is a function that wraps a [Handler] and can modify its
/// behavior. It can be used to add logging, error handling, or any other
/// cross-cutting concerns.
typedef Middleware = Handler Function(Handler handller);

/// Creates a new middleware.
/// [onError] is called when the inner handler throws an error, if [onError]
/// returns a Response, it will be returned, otherwise the error will be rethrown.
/// [onRequest] is called before the inner handler is called. If [onRequest]
/// returns a Response, it will be returned and the inner handler will not be called.
/// [onResponse] is called after the inner handler is called. If [onResponse]
/// returns a Response, it will be returned.
Middleware middleware({
  Future<Response?> Function(Request)? onRequest,
  Future<Response?> Function(Response)? onResponse,
  Future<Response?> Function(Object, StackTrace)? onError,
}) =>
    (handler) => (request) async {
          try {
            final response =
                await onRequest?.call(request) ?? await handler(request);
            return await onResponse?.call(response) ?? response;
          } catch (error, stacktrace) {
            return await onError?.call(error, stacktrace) ?? (throw error);
          }
        };
