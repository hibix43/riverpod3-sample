import 'package:flutter/widgets.dart' show debugPrint;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

class Driver {
  const Driver._();

  static Future<Driver> create() async {
    await Future.delayed(const Duration(seconds: 1));
    return const Driver._();
  }

  Future<String> runApi() async {
    await Future.delayed(const Duration(seconds: 1));
    return "hello";
  }
}

class Repository {
  final Driver driver;

  Repository({required this.driver});

  Future<String> fetchHelloWorld() async {
    final data = await driver.runApi();
    return "$data world";
  }
}

class ServiceWithoutRef {
  final Repository repository;
  final void Function(String) runSideEffect;

  const ServiceWithoutRef({
    required this.repository,
    required this.runSideEffect,
  });

  Future<void> calc() async {
    final data = await repository.fetchHelloWorld();
    runSideEffect(data);
  }

  Future<void> calcWithRetry({int retryCount = 0}) async {
    try {
      final data = await repository.fetchHelloWorld();
      runSideEffect(data);
    } catch (e) {
      if (retryCount < 3) {
        await Future.delayed(const Duration(milliseconds: 500));
        await calcWithRetry(retryCount: retryCount + 1);
      } else {
        debugPrint('retry count is over 3 with error: $e');
        rethrow;
      }
    }
  }
}

class ServiceWithRef {
  final Ref ref;

  const ServiceWithRef({required this.ref});

  Future<void> calc() async {
    final repository = await ref.read(repositoryProvider.future);
    final data = await repository.fetchHelloWorld();
    ref.read(runSideEffectProvider)(data);
  }

  Future<void> calcWithRetry({int retryCount = 0}) async {
    try {
      final repository = await ref.read(repositoryProvider.future);
      final data = await repository.fetchHelloWorld();
      ref.read(runSideEffectProvider)(data);
    } catch (e) {
      if (retryCount < 3) {
        await Future.delayed(const Duration(milliseconds: 500));
        await calcWithRetry(retryCount: retryCount + 1);
      } else {
        debugPrint('retry count is over 3 with error: $e');
        rethrow;
      }
    }
  }
}

@riverpod
void Function(String) runSideEffect(Ref ref) {
  return (String data) {
    debugPrint("side effect: $data");
  };
}

@riverpod
Future<Driver> driver(Ref ref) {
  return Driver.create();
}

@riverpod
Future<Repository> repository(Ref ref) async {
  final driver = await ref.watch(driverProvider.future);
  return Repository(driver: driver);
}

@riverpod
Future<ServiceWithoutRef> serviceWithoutRef(Ref ref) async {
  final repository = await ref.watch(repositoryProvider.future);
  return ServiceWithoutRef(
    repository: repository,
    runSideEffect: (data) {
      // UnmountedRefException (Cannot use the Ref of  after it has been disposed.
      ref.read(runSideEffectProvider)(data);

      // Following code is also the same error
      // final sub = ref.listen(runSideEffectProvider, (previous, next) {});
      // sub.read()(data);
      // sub.close();
    },
  );
}

@riverpod
Future<ServiceWithoutRef> serviceWithoutRef2(Ref ref) async {
  final repository = await ref.watch(repositoryProvider.future);
  // ref.read(serviceWithoutRef2Provider.future); としたら、UnmountedRefExceptionが発生する
  final runSideEffectFunction = ref.watch(runSideEffectProvider);
  return ServiceWithoutRef(
    repository: repository,
    runSideEffect: runSideEffectFunction,
  );
}

@riverpod
ServiceWithRef serviceWithRef(Ref ref) {
  return ServiceWithRef(ref: ref);
}
