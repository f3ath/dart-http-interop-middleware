import 'package:http_interop/http_interop.dart';

/// A [Middleware] is a function that wraps a [Handler] and can modify its
/// behavior. It can be used to add logging, error handling, or any other
/// cross-cutting concerns.
typedef Middleware = Handler Function(Handler handller);

extension MiddlewareExt on Middleware {
  /// Wraps this middleware in [other].
  ///
  /// `a.wrapIn(b)(handler)` is equivalent to `b(a(handler))`. Requests enter
  /// [other] first, then this middleware, then the handler. Responses return
  /// through this middleware first, then [other]. Either middleware can
  /// short-circuit the request before it reaches the handler.
  Middleware wrapIn(Middleware other) =>
      (handler) => other(this(handler));
}

extension MiddlewareListExt on List<Middleware> {
  /// Combines the middleware by wrapping each item in the next.
  ///
  /// `[a, b, c].combine()` is equivalent to `a.wrapIn(b).wrapIn(c)`.
  /// Requests enter the last item first; responses return through the first
  /// item first. An empty list produces middleware that returns the handler
  /// unchanged.
  Middleware combine() => fold<Middleware>(
    (handler) => handler,
    (combined, next) => combined.wrapIn(next),
  );
}

/// Creates middleware with optional request, response, and error callbacks.
///
/// [onRequest] runs before the inner handler. Returning `null` continues to the
/// handler. Returning a [Response] skips the handler but still passes that
/// response to [onResponse].
///
/// [onResponse] receives the response from [onRequest] or the inner handler,
/// along with the request. Returning a [Response] replaces the response;
/// returning `null` preserves it.
///
/// [onError] receives errors thrown by [onRequest], the inner handler, or
/// [onResponse], along with the stack trace and request. Returning a [Response]
/// handles the error and returns that response without calling [onResponse].
/// If [onError] is omitted or returns `null`, the error is rethrown with its
/// original stack trace. Errors thrown by [onError] propagate to the caller.
Middleware middleware({
  Future<Response?> Function(Request)? onRequest,
  Future<Response?> Function(Response, Request)? onResponse,
  Future<Response?> Function(Object, StackTrace, Request)? onError,
}) =>
    (handler) => (request) async {
      try {
        final response =
            await onRequest?.call(request) ?? await handler(request);
        return await onResponse?.call(response, request) ?? response;
      } catch (error, trace) {
        final response = await onError?.call(error, trace, request);
        if (response != null) return response;
        rethrow;
      }
    };
