import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
  
}

class _MyAppState extends State<MyApp> {
  
  late GoogleMapController _googleMapController;
  
  final Set<Polyline>_polyline={};

  PolylinePoints polylinePoints = PolylinePoints();
  
  
  Marker _origin = Marker(markerId: MarkerId('1'), position: LatLng(42.318498726, -83.2265324272));
  Marker _destination = Marker(markerId: MarkerId('2'), position: LatLng(42.3, -83.2));

  Future<http.Response> fetchDirections() {
    return http.get(Uri.parse('https://maps.googleapis.com/maps/api/directions/json?origin=' + _origin.position.latitude.toString() + "," + _origin.position.longitude.toString() + "&destination=" + _destination.position.latitude.toString() + ',' + _destination.position.longitude.toString() + "&key=AIzaSyDuqPr3_Lnv59Xk0YofGya3W24W76Vihwc"));
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Color(0xB00B13),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Route Runner'),
          elevation: 2,
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
          target: LatLng(42.3, -83.2),
          zoom: 14,
        ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onLongPress: _addMarker,
          markers: {
            _origin,
            _destination
          },
          polylines: _polyline,
          zoomControlsEnabled: false,
          
        ),
        floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 50,
        margin: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: () {_addMarker(LatLng(0.0, 0.0));},
          child: const Center(
            child: Text('Get Route'),
          ),
        ),
      ),
      ),
    );
  }
  void _onMapCreated(GoogleMapController){
    
  }

  void _addMarker(LatLng pos){
    setState(() {
      var jsonData, parsedJson, polyLineData;
      var polylinePoints;
      var result;
      List<LatLng> locations = List.empty(growable: true);
      var lat, lng, latSide, lngSide;

      fetchDirections().then((value) => {
        jsonData = jsonDecode(value.body),
        polyLineData = jsonData['routes'][0]['overview_polyline']['points'].toString(),

        //debugPrint(value.body),
        result = PolylinePoints().decodePolyline(polyLineData),
        for(int i = 0; i < result.length; i++){
          latSide = result[i].toString().split('/')[0],
          lngSide = result[i].toString().split('/')[1],
          lat = latSide.split(':')[1],
          lng = lngSide.split(':')[1],
          locations.add(LatLng(double.parse(lat) , double.parse(lng))),
          debugPrint(locations[i].toString()),
        },

        _polyline.add(Polyline(
              polylineId: PolylineId('1'),
              visible: true,
              //latlng is List<LatLng>
              points: locations,
              color: Colors.blue,
          ))
      });
    });
  }
}
