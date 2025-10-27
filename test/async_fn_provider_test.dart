import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'async_fn_provider_test.g.dart';

void main() {
  // This demonstrates the issue where ref becomes unmounted during async operations
  // In real projects, this pattern is used when:
  // 1. Getting database instance from Provider
  // 2. Performing async write operations
  // 3. Invalidating ValueProvider that returns database values after the write (ref.invalidate)
  // UnmountedRefException occurs in step 3
  //
  // Note: While ref.mounted can be used to check and avoid the exception,
  // this would prevent subsequent async operations from executing, which is not desirable
  //
  // it's same? problem as the following link
  // https: //github.com/rrousselGit/riverpod/issues/4096

  test(
    'Provider returning async function throws UnmountedRefException',
    () async {
      final container = ProviderContainer.test();
      final asyncFn = container.read(asyncFnProvider);
      await asyncFn();
    },
  );
}

@riverpod
String stringSample(Ref ref) => 'hello';

@riverpod
Future<void> Function() asyncFn(Ref ref) {
  return () async {
    ref.read(stringSampleProvider);
    await Future.delayed(const Duration(milliseconds: 100));
    // UnmountedRefException occurs here
    ref.read(stringSampleProvider);
  };
}
