part of 'helpers.dart';

class ClosetManager extends ValueNotifier<List<String>> {
  static final ClosetManager instance = ClosetManager._internal();

  ClosetManager._internal() : super([]);

  void addItem(String path) {
    if (!value.contains(path)) {
      value = [path, ...value];
    }
  }

  void removeItem(String path) {
    value = value.where((item) => item != path).toList();
  }

  bool contains(String path) {
    return value.contains(path);
  }
}

