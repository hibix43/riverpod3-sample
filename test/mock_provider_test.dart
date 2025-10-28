import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mock_provider_test.g.dart';

void main() {
  test('Minimum sample code to describe the problem', () {
    // final notifier = SampleNotifierMock();

    final container = ProviderContainer.test(
      // Not working
      overrides: [sampleProvider.overrideWith(() => SampleNotifierMock())],
      // overrides: [sampleProvider.overrideWith(() => SampleNotifier2())],

      // Pass the test by overriding the build method
      // overrides: [sampleProvider.overrideWithBuild((_, _) => false)],
    );

    // Null check operator used on a null value
    container.read(sampleProvider.notifier);
    // verify(notifier.build()).called(1);
  });
}

@riverpod
class SampleNotifier extends _$SampleNotifier {
  @override
  bool build() {
    return false;
  }
}

class SampleNotifierMock extends $Notifier<bool>
    with Mock
    implements SampleNotifier {}

class SampleNotifier2 extends $Notifier<bool> implements SampleNotifier {
  @override
  bool build() {
    return false;
  }

  @override
  void runBuild() {}
}
