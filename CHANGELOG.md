## [0.2.0] - 2026-10-24
### Added
- `List<Middleware>.combine()` composes middleware in list order; an empty list leaves the handler unchanged.

### Changed
- BREAKING: Rename `Middleware.add` to `Middleware.wrapIn`.
- BREAKING: Require Dart SDK `^3.13.0` and `http_interop` `^3.0.0`.
- Clarify middleware composition order, callback return values, and error propagation in API documentation.

### Fixed
- Preserve the original stack trace when middleware does not handle an error, including through `catchResponse`.

## [0.1.0] - 2024-07-14
### Added
- `Middleware.add()` extension method

### Changed
- Added the Request to the callbacks in `middleware()`

## [0.0.1] - 2024-07-13
### Added
- initial

[0.2.0]: https://github.com/f3ath/dart-http-interop-middleware/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/f3ath/dart-http-interop-middleware/compare/0.0.1...0.1.0
[0.0.1]: https://github.com/f3ath/dart-http-interop-middleware/releases/tag/0.0.1
