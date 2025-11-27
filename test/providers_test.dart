import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod3_sample/providers.dart';

void main() {
  group('ServiceWithoutRef', () {
    test('withoutRef_read_失敗', () async {
      final container = ProviderContainer.test();
      final service = container.read(serviceWithoutRefProvider);
      await service.calc();
    });

    test('withoutRef_listen_成功', () async {
      final container = ProviderContainer.test();
      final sub = container.listen(
        serviceWithoutRefProvider,
        (previous, next) {},
      );
      final service = sub.read();
      await service.calc();
      sub.close();
    });

    test('withoutRef2_read_成功', () async {
      final container = ProviderContainer.test();
      final service = container.read(serviceWithoutRef2Provider);
      await service.calc();
    });

    test('withoutRef2_listen_成功', () async {
      final container = ProviderContainer.test();
      final sub = container.listen(
        serviceWithoutRef2Provider,
        (previous, next) {},
      );
      final service = sub.read();
      await service.calc();
      sub.close();
    });

    test('withoutRef_read_成功_例外期待', () async {
      final container = ProviderContainer.test(
        overrides: [repositoryProvider.overrideWith((r) => MockRepository())],
      );
      final service = container.read(serviceWithoutRefProvider);
      await expectLater(service.calc, throwsA(isA<FetchDataError>()));
    });

    test('withoutRef_listen_成功_例外期待', () async {
      final container = ProviderContainer.test(
        overrides: [repositoryProvider.overrideWith((r) => MockRepository())],
      );
      final sub = container.listen(
        serviceWithoutRefProvider,
        (previous, next) {},
      );
      final service = sub.read();
      await expectLater(service.calc(), throwsA(isA<FetchDataError>()));
      sub.close();
    });

    test('withoutRef2_listen_成功_例外期待', () async {
      final container = ProviderContainer.test(
        overrides: [repositoryProvider.overrideWith((r) => MockRepository())],
      );
      final sub = container.listen(
        serviceWithoutRef2Provider,
        (previous, next) {},
      );
      final service = sub.read();
      await expectLater(service.calc(), throwsA(isA<FetchDataError>()));
      sub.close();
    });

    test('withoutRef_read_成功_例外期待_リトライ', () async {
      final container = ProviderContainer.test(
        overrides: [repositoryProvider.overrideWith((r) => MockRepository())],
      );
      final service = container.read(serviceWithoutRefProvider);
      await expectLater(service.calcWithRetry, throwsA(isA<FetchDataError>()));
    });

    test('withoutRef_listen_成功_例外期待_リトライ', () async {
      final container = ProviderContainer.test(
        overrides: [repositoryProvider.overrideWith((r) => MockRepository())],
      );
      final sub = container.listen(
        serviceWithoutRefProvider,
        (previous, next) {},
      );
      final service = sub.read();
      await expectLater(
        service.calcWithRetry(),
        throwsA(isA<FetchDataError>()),
      );
      sub.close();
    });

    test('withoutRef2_read_成功_例外期待_リトライ', () async {
      final container = ProviderContainer.test(
        overrides: [repositoryProvider.overrideWith((r) => MockRepository())],
      );
      final service = container.read(serviceWithoutRef2Provider);
      await expectLater(service.calcWithRetry, throwsA(isA<FetchDataError>()));
    });
  });

  test('withoutRef2_listen_成功_例外期待_リトライ', () async {
    final container = ProviderContainer.test(
      overrides: [repositoryProvider.overrideWith((r) => MockRepository())],
    );
    final sub = container.listen(
      serviceWithoutRef2Provider,
      (previous, next) {},
    );
    final service = sub.read();
    await expectLater(service.calcWithRetry, throwsA(isA<FetchDataError>()));
    sub.close();
  });

  group('ServiceWithRef', () {
    test('withRef_read_失敗', () async {
      final container = ProviderContainer.test();
      final service = container.read(serviceWithRefProvider);
      await service.calc();
    });

    test('withRef_listen_成功', () async {
      final container = ProviderContainer.test();
      final sub = container.listen(serviceWithRefProvider, (previous, next) {});
      final service = sub.read();
      await service.calc();
      sub.close();
    });

    test('withRef_read_成功_例外期待', () async {
      final container = ProviderContainer.test(
        overrides: [repositoryProvider.overrideWith((r) => MockRepository())],
      );
      final service = container.read(serviceWithRefProvider);
      await expectLater(service.calc, throwsA(isA<FetchDataError>()));
    });

    test('withRef_listen_成功_例外期待', () async {
      final container = ProviderContainer.test(
        overrides: [repositoryProvider.overrideWith((r) => MockRepository())],
      );
      final sub = container.listen(serviceWithRefProvider, (previous, next) {});
      final service = sub.read();
      await expectLater(service.calc, throwsA(isA<FetchDataError>()));
      sub.close();
    });

    // calcWithRetryを実行する前に500ms待つようにすると失敗する
    // →逆に500msを待つ処理を削除すると成功する
    // →非同期処理の時間がautoDisposeによるRefの破棄より長い場合に失敗すると言えそう
    test('withRef_read_失敗_例外期待_リトライ', () async {
      final container = ProviderContainer.test(
        overrides: [repositoryProvider.overrideWith((r) => MockRepository())],
      );
      final service = container.read(serviceWithRefProvider);
      await expectLater(service.calcWithRetry, throwsA(isA<FetchDataError>()));
    });

    test('withRef_listen_成功_例外期待_リトライ', () async {
      final container = ProviderContainer.test(
        overrides: [repositoryProvider.overrideWith((r) => MockRepository())],
      );
      final sub = container.listen(serviceWithRefProvider, (previous, next) {});
      final service = sub.read();
      await expectLater(service.calcWithRetry, throwsA(isA<FetchDataError>()));
      sub.close();
    });

    test('withRef_read_成功_Future期待', () async {
      final container = ProviderContainer.test();
      final service = container.read(serviceWithRefProvider);
      await service.calcWithFuture();
    });

    test('withRef_listen_成功_Future期待', () async {
      final container = ProviderContainer.test();
      final sub = container.listen(serviceWithRefProvider, (previous, next) {});
      final service = sub.read();
      await service.calcWithFuture();
      sub.close();
    });

    test('withRef_read_成功_Future期待_例外期待', () async {
      final container = ProviderContainer.test(
        overrides: [
          repositoryForFutureProvider.overrideWith((r) => MockRepository()),
        ],
      );
      final service = container.read(serviceWithRefProvider);
      await expectLater(service.calcWithFuture, throwsA(isA<FetchDataError>()));
    });

    test('withRef_listen_成功_Future期待_例外期待', () async {
      final container = ProviderContainer.test(
        overrides: [
          repositoryForFutureProvider.overrideWith((r) => MockRepository()),
        ],
      );
      final sub = container.listen(serviceWithRefProvider, (previous, next) {});
      final service = sub.read();
      await expectLater(service.calcWithFuture, throwsA(isA<FetchDataError>()));
      sub.close();
    });

    test('withRef_read_失敗_Future期待_例外期待_リトライ', () async {
      final container = ProviderContainer.test(
        overrides: [
          repositoryForFutureProvider.overrideWith((r) => MockRepository()),
        ],
      );
      final service = container.read(serviceWithRefProvider);
      await expectLater(
        service.calcWithFutureWithRetry,
        throwsA(isA<FetchDataError>()),
      );
    });

    test('withRef_listen_成功_Future期待_例外期待_リトライ', () async {
      final container = ProviderContainer.test(
        overrides: [
          repositoryForFutureProvider.overrideWith((r) => MockRepository()),
        ],
      );
      final sub = container.listen(serviceWithRefProvider, (previous, next) {});
      final service = sub.read();
      await expectLater(
        service.calcWithFutureWithRetry,
        throwsA(isA<FetchDataError>()),
      );
      sub.close();
    });
  });
}

class MockRepository extends Mock implements Repository {
  @override
  Future<String> fetchData() async {
    throw FetchDataError();
  }
}

class FetchDataError extends Error {
  FetchDataError();
}
