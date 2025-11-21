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
}

class ServiceWithRef {
  final Ref ref;

  const ServiceWithRef({required this.ref});

  Future<void> calc() async {
    final repository = ref.read(repositoryProvider);
    final data = await repository.fetchData();
    ref.read(runSideEffectProvider)(data);
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
