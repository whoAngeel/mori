import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'random_providers.g.dart';

/// The app-wide [Random]. Override in tests with `Random(seed)` for
/// deterministic draws and id generation.
@Riverpod(keepAlive: true)
Random random(Ref ref) => Random.secure();
