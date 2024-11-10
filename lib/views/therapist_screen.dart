import 'package:aura_techwizard/models/user.dart';
import 'package:aura_techwizard/resources/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TherapistScreen extends StatefulWidget {
  final String userUid;
  const TherapistScreen({super.key, required this.userUid});

  @override
  State<TherapistScreen> createState() => _TherapistScreenState();
}

class _TherapistScreenState extends State<TherapistScreen> {
  
  LatLng? _currentLocation;
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = widget.userUid;
    _getCurrentLocationAndUpdateUsers();
  }

  // Function to get current location and update in Firestore
  Future<void> _getCurrentLocationAndUpdateUsers() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update current user's location in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _launchMaps(double? latitude, double? longitude) async {
    if (latitude != null && longitude != null) {
      // Updated Google Maps URL with location and search term for therapists
      final url = 'https://www.google.com/maps/search/therapist+near+me/@$latitude,$longitude,13z';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        print('Could not launch $url');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Therapist near me'),
      ),
      body: Column(
        children: [
          if (user != null && user.latitude != null && user.longitude != null)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => _launchMaps(user.latitude, user.longitude),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lat: ${user.latitude?.toStringAsFixed(4)}\nLng: ${user.longitude?.toStringAsFixed(4)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to open in Maps',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
