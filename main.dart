import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(TrackMe());
}

class TrackMe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Route Tracking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyTrackerViwe(),
    );
  }
}

class MyTrackerViwe extends StatefulWidget {
  @override
  _MyTrackerViweState createState() => _MyTrackerViweState();
}

class _MyTrackerViweState extends State<MyTrackerViwe> {
  MapController controller = MapController();
  List<LatLng> coordinates = [];

  @override
  void initState() {
    super.initState();

    startTracking();
  }

  void startTracking() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation != null) {
        setState(() {
          LatLng latLng =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          coordinates.add(latLng);
          controller.move(latLng, 15.0);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking App'),
        centerTitle: true,
      ),
      body: FlutterMap(
        mapController: controller,
        options: MapOptions(
          center: LatLng(0.0, 0.0),
          zoom: 16.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          PolylineLayerOptions(
            polylines: [
              Polyline(
                points: coordinates,
                color: Colors.green,
                strokeWidth: 5.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
