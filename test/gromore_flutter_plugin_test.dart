import 'package:flutter_test/flutter_test.dart';
import 'package:gromore_flutter_plugin/gromore_flutter_plugin.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('instance 返回全局唯一单例', () {
    final GromoreFlutterPlugin a = GromoreFlutterPlugin.instance;
    final GromoreFlutterPlugin b = GromoreFlutterPlugin.instance;
    expect(identical(a, b), isTrue);
  });
}
