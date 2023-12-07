// テストパッケージとテスト対象のアプリをインポートする
import 'package:flutter_test/flutter_test.dart';
import 'package:task2/main.dart';

void main() {
  // テストのグループを作成する
  group('Map app tests', () {
    // テストの前処理として、アプリを起動する
    setUpAll(() async {
      await tester.pumpWidget(MapApp());
    });

    // テストケース1: mapが表示されることを確認する
    testWidgets('map is displayed', (WidgetTester tester) async {
      // mapが存在することを検証する
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    // テストケース2: geojsonのレイヤデータを読み込み、map上に表示することを確認する
    testWidgets('geojson layer is displayed', (WidgetTester tester) async {
      // geojsonのレイヤデータを取得する
      final geojsonLayer = find.byType(GeoJSONWidget);
      // geojsonのレイヤデータが存在することを検証する
      expect(geojsonLayer, findsOneWidget);
      // geojsonのレイヤデータがmapの子要素であることを検証する
      expect(
          geojsonLayer, findsOneWidget.ancestor(of: find.byType(FlutterMap)));
    });
  });
}
