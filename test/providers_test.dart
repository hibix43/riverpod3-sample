import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod3_sample/providers.dart';

void main() {
  test('UnmountedRefException occurs test', () async {
    final container = ProviderContainer.test();
    final service = container.read(serviceProvider);
    await service.calc();
  });

  test('UnmountedRefException does not occur test', () async {
    final container = ProviderContainer.test();
    final sub = container.listen(serviceProvider, (previous, next) {});
    final service = sub.read();
    await service.calc();
    sub.close();
  });
}
