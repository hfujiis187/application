import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(MyApp());
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

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Map Demo'),
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/geojson_file_1.geojson'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('エラーが発生しました。\n${snapshot.error.toString()}');
          } else if (snapshot.hasData) {
            final geojson = jsonDecode(snapshot.data!);
            final features = geojson['features'] as List;
            final markers = features.map((feature) {
              final coordinates = feature['geometry']['coordinates'][0][0];
              return Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(coordinates[1], coordinates[0]),
                builder: (ctx) => const Icon(Icons.location_on),
              );
            }).toList();
            return FlutterMap(
              options: MapOptions(
                center: LatLng(35.6895, 139.6917),
                zoom: 13.0,
                plugins: [
                  MarkerClusterPlugin(),
                ],
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerClusterLayerOptions(
                  maxClusterRadius: 120,
                  size: Size(40, 40),
                  fitBoundsOptions: FitBoundsOptions(
                    padding: EdgeInsets.all(50),
                  ),
                  markers: markers,
                  polygonOptions: PolygonOptions(
                      borderColor: Colors.blueAccent,
                      color: Colors.black12,
                      borderStrokeWidth: 3),
                  builder: (context, markers) {
                    return FloatingActionButton(
                      child: Text(markers.length.toString()),
                      onPressed: null,
                    );
                  },
                ),
              ],
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
