import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'override_with_build_test.g.dart';

@riverpod
class SampleNotifier extends _$SampleNotifier {
  @override
  Future<void> build() async {
    return;
  }
}

void main() {
  test('Override with build test', () async {
    final container = ProviderContainer.test(
      overrides: [
        sampleProvider.overrideWithBuild((r, n) {
          throw Exception('test');
        }),
      ],
      // overrideWithBuildでthrowするようにしてもretryが呼ばれてすぐにAsyncErrorにならないので
      // retryを無効化する必要がある
      retry: (retryCount, error) {
        return null;
      },
    );

    expect(container.read(sampleProvider), isA<AsyncError>());
  });
}
