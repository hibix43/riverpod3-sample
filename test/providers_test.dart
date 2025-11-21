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
      await expectLater(service.calc(), throwsA(isA<Exception>()));
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
      await expectLater(service.calc(), throwsA(isA<Exception>()));
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
      await expectLater(service.calc(), throwsA(isA<Exception>()));
      sub.close();
    });
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
      await expectLater(service.calc(), throwsA(isA<Exception>()));
    });

    test('withRef_listen_成功_例外期待', () async {
      final container = ProviderContainer.test(
        overrides: [repositoryProvider.overrideWith((r) => MockRepository())],
      );
      final sub = container.listen(serviceWithRefProvider, (previous, next) {});
      final service = sub.read();
      await expectLater(service.calc(), throwsA(isA<Exception>()));
      sub.close();
    });
  });
}

class MockRepository extends Mock implements Repository {
  @override
  Future<String> fetchData() async {
    throw Exception('test');
  }
}
