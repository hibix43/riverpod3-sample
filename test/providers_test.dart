import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod3_sample/providers.dart';

void main() {
  group('ServiceWithoutRef', () {
    test('withoutRef_read_失敗', () async {
      final container = ProviderContainer.test();
      final service = await container.read(serviceWithoutRefProvider.future);
      await service.calc();
    });

    test('withoutRef_listen_成功', () async {
      final container = ProviderContainer.test();
      final sub = container.listen(
        serviceWithoutRefProvider.future,
        (previous, next) {},
      );
      final service = await sub.read();
      await service.calc();
      sub.close();
    });

    test('withoutRef2_read_失敗', () async {
      final container = ProviderContainer.test();
      final service = await container.read(serviceWithoutRef2Provider.future);
      await service.calc();
    });

    test('withoutRef2_listen_成功', () async {
      final container = ProviderContainer.test();
      final sub = container.listen(
        serviceWithoutRef2Provider.future,
        (previous, next) {},
      );
      final service = await sub.read();
      await service.calc();
      sub.close();
    });

    test('withoutRef_read_成功_例外期待', () async {
      final container = ProviderContainer.test(
        overrides: [driverProvider.overrideWith((r) => MockDriver())],
      );
      final service = await container.read(serviceWithoutRefProvider.future);
      await expectLater(service.calc, throwsA(isA<ApiFetchDataError>()));
    });

    test('withoutRef_listen_成功_例外期待', () async {
      final container = ProviderContainer.test(
        overrides: [driverProvider.overrideWith((r) => MockDriver())],
      );
      final sub = container.listen(
        serviceWithoutRefProvider.future,
        (previous, next) {},
      );
      final service = await sub.read();
      await expectLater(service.calc(), throwsA(isA<ApiFetchDataError>()));
      sub.close();
    });

    test('withoutRef2_listen_成功_例外期待', () async {
      final container = ProviderContainer.test(
        overrides: [driverProvider.overrideWith((r) => MockDriver())],
      );
      final sub = container.listen(
        serviceWithoutRef2Provider.future,
        (previous, next) {},
      );
      final service = await sub.read();
      await expectLater(service.calc(), throwsA(isA<ApiFetchDataError>()));
      sub.close();
    });

    test('withoutRef_read_成功_例外期待_リトライ', () async {
      final container = ProviderContainer.test(
        overrides: [driverProvider.overrideWith((r) => MockDriver())],
      );
      final service = await container.read(serviceWithoutRefProvider.future);
      await expectLater(
        service.calcWithRetry,
        throwsA(isA<ApiFetchDataError>()),
      );
    });

    test('withoutRef_listen_成功_例外期待_リトライ', () async {
      final container = ProviderContainer.test(
        overrides: [driverProvider.overrideWith((r) => MockDriver())],
      );
      final sub = container.listen(
        serviceWithoutRefProvider.future,
        (previous, next) {},
      );
      final service = await sub.read();
      await expectLater(
        service.calcWithRetry(),
        throwsA(isA<ApiFetchDataError>()),
      );
      sub.close();
    });

    test('withoutRef2_read_成功_例外期待_リトライ', () async {
      final container = ProviderContainer.test(
        overrides: [driverProvider.overrideWith((r) => MockDriver())],
      );
      final service = await container.read(serviceWithoutRef2Provider.future);
      await expectLater(
        service.calcWithRetry,
        throwsA(isA<ApiFetchDataError>()),
      );
    });
  });

  test('withoutRef2_listen_成功_例外期待_リトライ', () async {
    final container = ProviderContainer.test(
      overrides: [driverProvider.overrideWith((r) => MockDriver())],
    );
    final sub = container.listen(
      serviceWithoutRef2Provider.future,
      (previous, next) {},
    );
    final service = await sub.read();
    await expectLater(service.calcWithRetry, throwsA(isA<ApiFetchDataError>()));
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
        overrides: [driverProvider.overrideWith((r) => MockDriver())],
      );
      final service = container.read(serviceWithRefProvider);
      await expectLater(service.calc, throwsA(isA<ApiFetchDataError>()));
    });

    test('withRef_listen_成功_例外期待', () async {
      final container = ProviderContainer.test(
        overrides: [driverProvider.overrideWith((r) => MockDriver())],
      );
      final sub = container.listen(serviceWithRefProvider, (previous, next) {});
      final service = sub.read();
      await expectLater(service.calc, throwsA(isA<ApiFetchDataError>()));
      sub.close();
    });

    // calcWithRetryを実行する前に500ms待つようにすると失敗する
    // →逆に500msを待つ処理を削除すると成功する
    // →非同期処理の時間がautoDisposeによるRefの破棄より長い場合に失敗すると言えそう
    test('withRef_read_失敗_例外期待_リトライ', () async {
      final container = ProviderContainer.test(
        overrides: [driverProvider.overrideWith((r) => MockDriver())],
      );
      final service = container.read(serviceWithRefProvider);
      await expectLater(
        service.calcWithRetry,
        throwsA(isA<ApiFetchDataError>()),
      );
    });

    test('withRef_listen_成功_例外期待_リトライ', () async {
      final container = ProviderContainer.test(
        overrides: [driverProvider.overrideWith((r) => MockDriver())],
      );
      final sub = container.listen(serviceWithRefProvider, (previous, next) {});
      final service = sub.read();
      await expectLater(
        service.calcWithRetry,
        throwsA(isA<ApiFetchDataError>()),
      );
      sub.close();
    });
  });

  group('SyncStateUseCaseNotifier', () {
    test('executeWithServiceWithoutRef_read_失敗', () async {
      final container = ProviderContainer.test();
      final notifier = container.read(syncStateUseCaseProvider.notifier);
      await notifier.executeWithServiceWithoutRef();
    });

    test('executeWithServiceWithoutRef2_read_失敗', () async {
      final container = ProviderContainer.test();
      final notifier = container.read(syncStateUseCaseProvider.notifier);
      await notifier.executeWithServiceWithoutRef2();
    });

    test('executeWithServiceWithRef_read_失敗', () async {
      final container = ProviderContainer.test();
      final notifier = container.read(syncStateUseCaseProvider.notifier);
      await notifier.executeWithServiceWithRef();
    });

    test('executeWithServiceWithoutRef_listen_失敗', () async {
      final container = ProviderContainer.test();
      final sub = container.listen(
        syncStateUseCaseProvider.notifier,
        (previous, next) {},
      );
      final notifier = sub.read();
      await notifier.executeWithServiceWithoutRef();
      sub.close();
    });

    test('executeWithServiceWithoutRef2_listen_失敗', () async {
      final container = ProviderContainer.test();
      final sub = container.listen(
        syncStateUseCaseProvider.notifier,
        (previous, next) {},
      );
      final notifier = sub.read();
      await notifier.executeWithServiceWithoutRef2();
      sub.close();
    });

    test('executeWithServiceWithRef_listen_失敗', () async {
      final container = ProviderContainer.test();
      final sub = container.listen(
        syncStateUseCaseProvider.notifier,
        (previous, next) {},
      );
      final notifier = sub.read();
      await notifier.executeWithServiceWithRef();
      sub.close();
    });
  });

  group('AsyncStateUseCaseNotifier', () {
    test('executeWithServiceWithoutRef_read_失敗', () async {
      final container = ProviderContainer.test();
      final notifier = container.read(asyncStateUseCaseProvider.notifier);
      await notifier.executeWithServiceWithoutRef();
    });

    test('executeWithServiceWithRef_read_失敗', () async {
      final container = ProviderContainer.test();
      final notifier = container.read(asyncStateUseCaseProvider.notifier);
      await notifier.executeWithServiceWithRef();
    });

    test('executeWithServiceWithoutRef2_read_失敗', () async {
      final container = ProviderContainer.test();
      final notifier = container.read(asyncStateUseCaseProvider.notifier);
      await notifier.executeWithServiceWithoutRef2();
    });

    test('executeWithServiceWithoutRef_listen_成功', () async {
      final container = ProviderContainer.test();
      final sub = container.listen(
        asyncStateUseCaseProvider.notifier,
        (previous, next) {},
      );
      final notifier = sub.read();
      await notifier.executeWithServiceWithoutRef();
      sub.close();
    });

    test('executeWithServiceWithRef_listen_成功', () async {
      final container = ProviderContainer.test();
      final sub = container.listen(
        asyncStateUseCaseProvider.notifier,
        (previous, next) {},
      );
      final notifier = sub.read();
      await notifier.executeWithServiceWithRef();
      sub.close();
    });

    test('executeWithServiceWithoutRef2_listen_成功', () async {
      final container = ProviderContainer.test();
      final sub = container.listen(
        asyncStateUseCaseProvider.notifier,
        (previous, next) {},
      );
      final notifier = sub.read();
      await notifier.executeWithServiceWithoutRef2();
      sub.close();
    });
  });
}

class MockDriver extends Mock implements Driver {
  @override
  Future<String> runApi() async {
    throw ApiFetchDataError();
  }
}

class ApiFetchDataError extends Error {
  ApiFetchDataError();
}
