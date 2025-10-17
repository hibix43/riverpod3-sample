import 'package:flutter/widgets.dart' show debugPrint;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

class Repository {
  Future<String> fetchData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return "hello";
  }
}

class Service {
  final Repository repository;
  final void Function(String) runSideEffect;

  const Service({required this.repository, required this.runSideEffect});

  Future<void> calc() async {
    final data = await repository.fetchData();
    runSideEffect(data);
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
Service service(Ref ref) {
  return Service(
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
