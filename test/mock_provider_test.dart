import 'package:flutter_riverpod/flutter_riverpod.dart'
    show Notifier, AsyncNotifier;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mock_provider_test.g.dart';

void main() {
  group('Notifier', () {
    test('Failed override with mock', () {
      final mock = SampleNotifierMockIncorrect();
      when(mock.build()).thenAnswer((_) => true);

      final container = ProviderContainer.test(
        overrides: [sampleProvider.overrideWith(() => mock)],
      );

      // Null check operator used on a null value
      final state = container.read(sampleProvider);
      expect(state, true);
    });

    test('Successfully override with mock', () {
      final mock = SampleNotifierMock();
      when(mock.build()).thenAnswer((_) => true);

      final container = ProviderContainer.test(
        overrides: [sampleProvider.overrideWith(() => mock)],
      );

      final state = container.read(sampleProvider);
      expect(state, true);
    });

    test('Successfully override with mock without generated code', () {
      final mock = SampleNotifierMockWithoutGeneratedCode();
      when(mock.build()).thenAnswer((_) => true);

      final container = ProviderContainer.test(
        overrides: [sampleProvider.overrideWith(() => mock)],
      );

      final state = container.read(sampleProvider);
      expect(state, true);
    });
  });

  group('AsyncNotifier', () {
    test('Failed override with mock', () async {
      final mock = SampleAsyncNotifierMockIncorrect();

      when(mock.build()).thenAnswer((_) async => true);

      final container = ProviderContainer.test(
        overrides: [sampleAsyncProvider.overrideWith(() => mock)],
      );

      // Bad state: The provider sampleAsyncProvider was disposed during loading state, yet no value could be emitted.
      final state = await container.read(sampleAsyncProvider.future);
      expect(state, true);
    });

    test('Successfully override with mock', () async {
      final mock = SampleAsyncNotifierMock();
      when(mock.build()).thenAnswer((_) async => true);

      final container = ProviderContainer.test(
        overrides: [sampleAsyncProvider.overrideWith(() => mock)],
      );

      final state = await container.read(sampleAsyncProvider.future);
      expect(state, true);
    });

    test('Successfully override with mock without generated code', () async {
      final mock = SampleAsyncNotifierMockWithoutGeneratedCode();
      when(mock.build()).thenAnswer((_) async => true);

      final container = ProviderContainer.test(
        overrides: [sampleAsyncProvider.overrideWith(() => mock)],
      );

      final state = await container.read(sampleAsyncProvider.future);
      expect(state, true);
    });
  });

  group('AsyncNotifier#build throws error', () {
    test('Failed override with mock', () async {
      final mock = SampleAsyncNotifierMockIncorrect();
      when(mock.build()).thenAnswer((_) async => throw Exception('test'));

      final container = ProviderContainer.test(
        overrides: [sampleAsyncProvider.overrideWith(() => mock)],
        retry: (retryCount, error) {
          return null;
        },
      );

      // retry を無効化してもしなくても以下のエラーが発生する
      // Expected: throws <Instance of 'Exception'>
      // Actual: <Instance of 'Future<bool>'>
      //  Which: threw StateError:<Bad state: The provider sampleAsyncProvider was disposed during loading state, yet no value could be emitted.>
      await expectLater(
        container.read(sampleAsyncProvider.future),
        throwsA(isA<Exception>()),
      );

      // retry を無効化してもしなくても以下のエラーが発生する
      // TimeoutException after 0:00:30.000000: Test timed out after 30 seconds. See https://pub.dev/packages/test#timeouts
      // dart:isolate  _RawReceivePort._handleMessage
      // Expected: throws <Instance of 'Exception'>
      // Actual: <Instance of 'Future<bool>'>
      // Which: threw StateError:<Bad state: The provider sampleAsyncProvider was disposed during loading state, yet no value could be emitted.>
      final sub = container.listen(
        sampleAsyncProvider.future,
        (previous, next) {},
      );
      await expectLater(sub.read(), throwsA(isA<Exception>()));
      sub.close();
    });

    test('Successfully override with mock', () async {
      final mock = SampleAsyncNotifierMock();
      when(mock.build()).thenAnswer((_) async => throw Exception('test'));

      final container = ProviderContainer.test(
        overrides: [sampleAsyncProvider.overrideWith(() => mock)],
        retry: (retryCount, error) {
          return null;
        },
      );

      // retry を無効化しないと以下のエラーが発生する
      // Expected: throws <Instance of 'Exception'>
      // Actual: <Instance of 'Future<bool>'>
      //  Which: threw StateError:<Bad state: The provider sampleAsyncProvider was disposed during loading state, yet no value could be emitted.>
      await expectLater(
        container.read(sampleAsyncProvider.future),
        throwsA(isA<Exception>()),
      );

      // retry を無効化しないと以下のエラーが発生する
      // TimeoutException after 0:00:30.000000: Test timed out after 30 seconds. See https://pub.dev/packages/test#timeouts
      // dart:isolate  _RawReceivePort._handleMessage
      // Expected: throws <Instance of 'Exception'>
      // Actual: <Instance of 'Future<bool>'>
      // Which: threw StateError:<Bad state: The provider sampleAsyncProvider was disposed during loading state, yet no value could be emitted.>
      final sub = container.listen(
        sampleAsyncProvider.future,
        (previous, next) {},
      );
      await expectLater(sub.read(), throwsA(isA<Exception>()));
      sub.close();
    });

    test('Successfully override with mock without generated code', () async {
      final mock = SampleAsyncNotifierMockWithoutGeneratedCode();
      when(mock.build()).thenAnswer((_) async => throw Exception('test'));

      final container = ProviderContainer.test(
        overrides: [sampleAsyncProvider.overrideWith(() => mock)],
        retry: (retryCount, error) {
          return null;
        },
      );

      // retry を無効化しないと以下のエラーが発生する
      // StateError:<Bad state: The provider sampleAsyncProvider was disposed during loading state, yet no value could be emitted.>
      await expectLater(
        container.read(sampleAsyncProvider.future),
        throwsA(isA<Exception>()),
      );

      // retry を無効化しないと以下のエラーが発生する
      // TimeoutException after 0:00:30.000000: Test timed out after 30 seconds.
      // Expected: throws <Instance of 'Exception'> with `message`: 'Exception: test'
      // Actual: <Instance of 'Future<bool>'>
      // Which: threw StateError:<Bad state: The provider sampleAsyncProvider was disposed during loading state, yet no value could be emitted.>
      final sub = container.listen(
        sampleAsyncProvider.future,
        (previous, next) {},
      );
      await expectLater(
        sub.read(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: test',
          ),
        ),
      );
      sub.close();
    });
  });
}

@riverpod
class SampleNotifier extends _$SampleNotifier {
  @override
  bool build() {
    return false;
  }
}

// Correct implementation!!
class SampleNotifierMock extends _$SampleNotifier
    with Mock
    implements SampleNotifier {
  @override
  bool build() {
    return noSuchMethod(
          Invocation.method(#build, []),
          returnValue: false,
          returnValueForMissingStub: false,
        )
        as bool;
  }
}

// Incorrect implementation!!
class SampleNotifierMockIncorrect extends $Notifier<bool>
    with Mock
    implements SampleNotifier {
  @override
  bool build() {
    return noSuchMethod(
          Invocation.method(#build, []),
          returnValue: false,
          returnValueForMissingStub: false,
        )
        as bool;
  }
}

// Correct implementation without generated code!!
// Notifier クラスを利用するためには import 'package:flutter_riverpod/flutter_riverpod.dart'; が必要だった
// しかし、VSCodeのquick fixでは import 'package:flutter_riverpod/flutter_riverpod.dart'; を追加してくれない
// そのため、手動で追加する必要があった
// import 'package:flutter_riverpod/flutter_riverpod.dart';
class SampleNotifierMockWithoutGeneratedCode extends Notifier<bool>
    with Mock
    implements SampleNotifier {
  @override
  bool build() {
    return noSuchMethod(
          Invocation.method(#build, []),
          returnValue: false,
          returnValueForMissingStub: false,
        )
        as bool;
  }
}

@riverpod
class SampleAsyncNotifier extends _$SampleAsyncNotifier {
  @override
  FutureOr<bool> build() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return false;
  }
}

class SampleAsyncNotifierMock extends _$SampleAsyncNotifier
    with Mock
    implements SampleAsyncNotifier {
  @override
  FutureOr<bool> build() async {
    return noSuchMethod(
          Invocation.method(#build, []),
          returnValue: false,
          returnValueForMissingStub: false,
        )
        as FutureOr<bool>;
  }
}

@riverpod
class SampleAsyncNotifierMockIncorrect extends $AsyncNotifier<bool>
    with Mock
    implements SampleAsyncNotifier {
  @override
  FutureOr<bool> build() async {
    return noSuchMethod(
          Invocation.method(#build, []),
          returnValue: false,
          returnValueForMissingStub: false,
        )
        as FutureOr<bool>;
  }
}

@riverpod
class SampleAsyncNotifierMockWithoutGeneratedCode extends AsyncNotifier<bool>
    with Mock
    implements SampleAsyncNotifier {
  @override
  FutureOr<bool> build() async {
    return noSuchMethod(
          Invocation.method(#build, []),
          returnValue: false,
          returnValueForMissingStub: false,
        )
        as FutureOr<bool>;
  }
}
