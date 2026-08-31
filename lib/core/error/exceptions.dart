/// Low-level errors thrown *inside* the Data layer (datasources).
///
/// These never leak past a repository: `*RepositoryImpl` converts them into
/// [Failure]s from `core/error/failures.dart`.
class CacheException implements Exception {
  const CacheException([this.message = 'Cache error']);

  final String message;

  @override
  String toString() => 'CacheException($message)';
}
