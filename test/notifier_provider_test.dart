import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod3_sample/notifier_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

void main() {
  test('turnOn() should turn on the notifier', () {
    final container = ProviderContainer.test();
    final notifier = container.read(myProvider.notifier);
    notifier.turnOn();
    expect(container.read(myProvider), isTrue);
  });

  test('Mockito test', () {
    final container = ProviderContainer.test(
      overrides: [myProvider.overrideWith(() => MyNotifierMock())],
    );
    final service = container.read(myServiceProvider);
    service.run();
    expect(container.read(myProvider), isTrue);
  });
}

class MyNotifierMock extends $Notifier<bool> with Mock implements MyNotifier {}
