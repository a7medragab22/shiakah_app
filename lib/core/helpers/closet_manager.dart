part of 'helpers.dart';

class ClosetManager extends ValueNotifier<List<String>> {
  static final ClosetManager instance = ClosetManager._internal();

  ClosetManager._internal() : super([]);

  void addItem(String path) {
    value = [path, ...value];
  }
}
