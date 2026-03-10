import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../../models/listing_model.dart';

class LiveDirectionsScreen extends StatefulWidget {
  final ListingModel listing;
  const LiveDirectionsScreen({super.key, required this.listing});

  @override
  State<LiveDirectionsScreen> createState() => _LiveDirectionsScreenState();
}

class _LiveDirectionsScreenState extends State<LiveDirectionsScreen> {
  LocationData? _currentLocation;
  bool _loading = true;
  String? _error;
  late final Location _location;
  Stream<LocationData>? _locationStream;
  @override
  void initState() {
    super.initState();
    _location = Location();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          setState(() {
            _error = 'Location services are disabled. Showing only destination.';
            _loading = false;
          });
          return;
        }
      }
      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          setState(() {
            _error = 'Location permission denied. Showing only destination.';
            _loading = false;
          });
          return;
        }
      }
      final loc = await _location.getLocation();
      setState(() {
        _currentLocation = loc;
        _loading = false;
      });
      _locationStream = _location.onLocationChanged;
      _locationStream!.listen((locData) {
        setState(() {
          _currentLocation = locData;
        });
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to get location: $e. Showing only destination.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dest = LatLng(widget.listing.latitude, widget.listing.longitude);
    final userLoc = _currentLocation != null && _currentLocation!.latitude != null && _currentLocation!.longitude != null
        ? LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!)
        : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Live Directions')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_error != null)
                  Container(
                    color: Colors.amber[100],
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: const TextStyle(color: Colors.black87))),
                      ],
                    ),
                  ),
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: userLoc ?? dest,
                      initialZoom: 14,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.kigali_city_directory',
                      ),
                      MarkerLayer(markers: [
                        if (userLoc != null)
                          Marker(
                            point: userLoc,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.my_location, color: Colors.blue, size: 36),
                          ),
                        Marker(
                          point: dest,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                        ),
                      ]),
                      if (userLoc != null)
                        PolylineLayer(polylines: [
                          Polyline(
                            points: [userLoc, dest],
                            color: Colors.amber,
                            strokeWidth: 4,
                          ),
                        ]),
                    ],
                  ),
                ),
                if (userLoc == null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Your location is unavailable. Only the destination is shown.\nIf using an emulator, set a mock location in the emulator controls.',
                      style: const TextStyle(color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
    );
  }
}
