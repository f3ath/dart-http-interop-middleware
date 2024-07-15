import 'package:http_interop/http_interop.dart';
import 'package:http_interop_middleware/http_interop_middleware.dart';

/// Middleware that allows the inner handler to throw a Response.
final Middleware catchResponse =
    middleware(onError: (err, t, r) async => (err is Response) ? err : null);
