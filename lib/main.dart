import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';//Unused import: 'package:flutter_map/flutter_map.dart'.Try removing the import directive.
import 'package:flutter_riverpod/flutter_riverpod.dart'; // flutter_riverpodパッケージをインポート
import 'package:flutter/services.dart';
import 'package:geojson/geojson.dart'; // geojsonパッケージをインポート
import 'package:latlong2/latlong.dart'; // Unused import: 'package:flutter_map/flutter_map.dart'.Try removing the import directive.
void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map Demo',
      home: MapPage(), 
    );
  }
}

class MapPage extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) { 

    final AsyncValue<GeoJsonFeatureCollection> articleList = ref.watch(articleListProvider); 
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Map Demo'),
      ),
      body: Center(
        child: articleList.when(
          data: (geojson) => ListView.builder( 
            itemCount: geojson.features.length, // The getter 'features' isn't defined for the type 'GeoJsonFeatureCollection'.Try importing the library that defines 'features', correcting the name to the name of an existing getter, or defining a getter or field named 'features'.
            itemBuilder: (context, index) => Column(
              children: [
                ListTile(
                  title: Text(geojson.features[index].title), // The getter 'features' isn't defined for the type 'GeoJsonFeatureCollection'.\Try importing the library that defines 'features', correcting the name to the name of an existing getter, or defining a getter or field named 'features'.
                  subtitle: Text(
                    'LGTM: ${geojson.features[index].likes_count} 
                    'コメント: ${geojson.features[index].comments_count}'), // The getter 'features' isn't defined for the type 'GeoJsonFeatureCollection'.Try importing the library that defines 'features', correcting the name to the name of an existing getter, or defining a getter or field named 'features'.
                  contentPadding: const EdgeInsets.all(16),
                  tileColor: Colors.lightGreen,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          error: (error, stackTrace) => Text('エラーが発生しました。\n${error.toString()}'),
          loading: () => const CircularProgressIndicator(),
        ),
      ),
    );
  }
}

final articleListProvider = FutureProvider<GeoJsonFeatureCollection>((ref) async { // GeoJsonFeatureCollection型を使って型を指定
  final data = await rootBundle.loadString('assets/geojson_file_1.geojson');
  final features = await featuresFromGeoJson(data); // featuresFromGeoJson関数を使ってGeoJSONデータを解析
  return features;
});


