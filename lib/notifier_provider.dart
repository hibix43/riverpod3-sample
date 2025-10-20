import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifier_provider.g.dart';

@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  bool build() {
    return false;
  }

  void turnOn() {
    state = true;
  }
}

class MyService {
  const MyService({required this.turnOn});

  final void Function() turnOn;

  void run() {
    turnOn();
  }
}

@riverpod
MyService myService(Ref ref) {
  // _TypeError (Null check operator used on a null value)
  return MyService(turnOn: ref.read(myProvider.notifier).turnOn);
}
