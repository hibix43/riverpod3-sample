import 'package:flutter/widgets.dart' show debugPrint;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

class Repository {
  Future<String> fetchData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return "hello";
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
    final data = await repository.fetchData();
    runSideEffect(data);
  }

  Future<void> calcWithRetry({int retryCount = 0}) async {
    try {
      final data = await repository.fetchData();
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
    final repository = ref.read(repositoryProvider);
    final data = await repository.fetchData();
    ref.read(runSideEffectProvider)(data);
  }

  Future<void> calcWithRetry({int retryCount = 0}) async {
    try {
      final repository = ref.read(repositoryProvider);
      final data = await repository.fetchData();
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

  Future<void> calcWithFuture() async {
    final repository = await ref.read(repositoryForFutureProvider.future);
    final data = await repository.fetchData();
    debugPrint("side effect: $data");
  }

  Future<void> calcWithFutureWithRetry({int retryCount = 0}) async {
    try {
      final repository = await ref.read(repositoryForFutureProvider.future);
      final data = await repository.fetchData();
      debugPrint("side effect: $data");
    } catch (e) {
      if (retryCount < 3) {
        await Future.delayed(const Duration(milliseconds: 500));
        await calcWithFutureWithRetry(retryCount: retryCount + 1);
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
Repository repository(Ref ref) {
  return Repository();
}

@riverpod
Future<Repository> repositoryForFuture(Ref ref) async {
  await Future.delayed(const Duration(seconds: 1));
  return Repository();
}

@riverpod
ServiceWithoutRef serviceWithoutRef(Ref ref) {
  return ServiceWithoutRef(
    repository: ref.watch(repositoryProvider),
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
ServiceWithoutRef serviceWithoutRef2(Ref ref) {
  final runSideEffectFunction = ref.watch(runSideEffectProvider);
  return ServiceWithoutRef(
    repository: ref.watch(repositoryProvider),
    runSideEffect: runSideEffectFunction,
  );
}

@riverpod
ServiceWithRef serviceWithRef(Ref ref) {
  return ServiceWithRef(ref: ref);
}
