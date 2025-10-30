import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mock_provider_test.g.dart';

void main() {
  test('Minimum sample code to describe the problem', () {
    final container = ProviderContainer.test(
      // Not working
      overrides: [sampleProvider.overrideWith(() => SampleNotifierMock())],
    );

    // Null check operator used on a null value
    container.read(sampleProvider.notifier);
  });
}

@riverpod
class SampleNotifier extends _$SampleNotifier {
  @override
  bool build() {
    return false;
  }
}

// Incorrect implementation!!
// class SampleNotifierMock extends $Notifier<bool>
//     with Mock
//     implements SampleNotifier {}

// Correct implementation!!
class SampleNotifierMock extends _$SampleNotifier
    with Mock
    implements SampleNotifier {
  @override
  bool build() {
    return false;
  }
}
