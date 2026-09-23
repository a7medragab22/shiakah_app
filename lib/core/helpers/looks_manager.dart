part of 'helpers.dart';

class LooksManager extends ValueNotifier<List<String>> {
  static final LooksManager instance = LooksManager._internal();

  LooksManager._internal() : super([]);

  void toggleItem(String path) {
    if (value.contains(path)) {
      value = value.where((item) => item != path).toList();
    } else {
      value = [path, ...value];
    }
  }

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
