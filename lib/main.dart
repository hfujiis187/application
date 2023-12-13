import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geojson/geojson.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 地図の表示を制御するためのMapControllerを作成します
  final MapController _mapController = MapController();
  // 地図のレイヤーを管理するリストを作成
  List<LayerOptions> _layers = [
    TileLayerOptions(
        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        subdomains: ['a', 'b', 'c']),
  ];

  //GeoJsonファイルを読み込み、解析し、マップ上に表示します。
  void _loadGeoJson(String path) async {
    // GeoJsonオブジェクトを作成します。
    final geoJson = GeoJson();
    // 指定されたパスからGeoJsonファイルを読み込み、解析します。
    await geoJson.parse(await rootBundle.loadString(path), verbose: true);
    // 解析された各フィーチャーを処理します。
    geoJson.processedFeatures.listen((feature) {
      // フィーチャーがポイント型の場合
      if (feature.type == GeoJsonFeatureType.point) {
        // ポイントのジオメトリを取得します。
        final point = feature.geometry as GeoJsonPoint;
        // マーカーをマップに追加します。
        setState(() {
          _layers.add(MarkerLayerOptions(markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(point.geoPoint.latitude, point.geoPoint.longitude),
              builder: (ctx) => Container(
                child: FlutterLogo(),
              ),
            )
          ]));
          // 地図の中心座標を更新します。
          _mapController.move(
              LatLng(point.geoPoint.latitude, point.geoPoint.longitude), 13.0);
        });
      }
      // フィーチャーがライン型の場合
      else if (feature.type == GeoJsonFeatureType.line) {
        // ラインのジオメトリを取得します。
        final line = feature.geometry as GeoJsonLine;
        // ラインの各ポイントを取得します。
        final points = line.geoSerie?.geoPoints
            ?.map((point) => LatLng(point.latitude, point.longitude))
            .toList();
        // ポイントが存在する場合のみ、ポリラインをマップに追加します。
        if (points != null && points.isNotEmpty) {
          setState(() {
  _layers.add(PolylineLayerOptions(polylines: [
    Polyline(
      points: points,
      color: Colors.red,
      strokeWidth: 4.0,
    )
  ]));
});

            // 地図の中心座標を更新します。
            final avgLat =
                points.map((p) => p.latitude).reduce((a, b) => a + b) /
                    points.length;
            final avgLng =
                points.map((p) => p.longitude).reduce((a, b) => a + b) /
                    points.length;
            _mapController.move(LatLng(avgLat, avgLng), 13.0);
          });
        }
      }

      // フィーチャーがマルチポリゴン型の場合
      else if (feature.type == GeoJsonFeatureType.multipolygon) {
        // マルチポリゴンのジオメトリを取得します。
        final multipolygon = feature.geometry as GeoJsonMultiPolygon;
        // 各ポリゴンを処理します。
        for (final polygon in multipolygon.polygons) {
          // ポリゴンの各ポイントを取得します。
          final points = polygon.geoSeries.first.geoPoints
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
          // ポリラインをマップに追加します。
          setState(() {
            _layers.add(PolylineLayerOptions(polylines: [
              Polyline(
                points: points,
                color: Colors.blue.withOpacity(0.7),
                strokeWidth: 4.0,
              )
            ]));
          });
        }
      }
      // フィーチャーがジオメトリコレクション型の場合
      else if (feature.type == GeoJsonFeatureType.geometryCollection) {
        // ジオメトリコレクションを取得します。
        final geometryCollection =
            feature.geometry as GeoJsonGeometryCollection;
        // ジオメトリコレクションがnullでない場合
        if (geometryCollection.geometries != null) {
          // 各ジオメトリを処理します。
          for (final geometry in geometryCollection.geometries!) {
            // ジオメトリがジオメトリコレクション型の場合
            if (geometry?.type != null &&
                geometry?.type == GeoJsonFeatureType.geometryCollection) {
              // 内部のジオメトリコレクションを取得します。
              final geometryCollectionInner =
                  geometry as GeoJsonGeometryCollection;
              // 内部のジオメトリコレクションがnullでない場合
              if (geometryCollectionInner.geometries != null) {
                // 各内部ジオメトリを処理します。
                for (final geometryInner
                    in geometryCollectionInner.geometries!) {
                  // 内部ジオメトリがポイント型の場合
                  if (geometryInner?.type != null &&
                      geometryInner?.type == GeoJsonFeatureType.point) {
                    // ポイントを取得します。
                    final point = geometryInner as GeoJsonPoint;
                    // ポイントを取得します。
                    final points = [
                      LatLng(point.geoPoint.latitude, point.geoPoint.longitude)
                    ];
                    // ポイントをマップに追加します。
                    setState(() {
                      _layers.add(PolylineLayerOptions(polylines: [
                        Polyline(
                          points: points,
                          color: Colors.red,
                          strokeWidth: 4.0,
                        )
                      ]));
                    });
                  }
                }
              }
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      //ボタン１
                      onPressed: () {
                        print('Button pressed'); // ボタン確認
                        setState(() {
                          _layers = _layers.sublist(0, 1);
                        });
                        _loadGeoJson('assets/アーム幅.geojson');
                      },
                      child: Text('Button 1')),
                  // ボタン2の処理
                  //ElevatedButton(onPressed: () {}, child: Text('Button 2')),
                  //ElevatedButton(onPressed: () {}, child: Text('Button 3')),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  // 地図の初期表示を設定
                  center: LatLng(35.6895, 139.6917),
                  zoom: 13.0,
                ),
                layers: _layers,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
