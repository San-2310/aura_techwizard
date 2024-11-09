import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String photoUrl;
  final String username;
  final String fullname;
  final String uid;
  final String contactnumber;
  final double? latitude;
  final double? longitude;

  const User({
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.fullname,
    required this.uid,
    required this.contactnumber,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'uid': uid,
        'email': email,
        'fullname': fullname,
        'photoUrl': photoUrl,
        'contactnumber': contactnumber,
        'latitude': latitude,
        'longitude': longitude,
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot['username'],
      email: snapshot['email'],
      photoUrl: snapshot['photoUrl'],
      uid: snapshot['uid'],
      fullname: snapshot['fullname'],
      contactnumber: snapshot['contactnumber'],
      latitude: snapshot['latitude']?.toDouble(),
      longitude: snapshot['longitude']?.toDouble(),
    );
  }

  // Method to create a copy of User with updated location
  User copyWithLocation(double lat, double lng) {
    return User(
      username: username,
      email: email,
      photoUrl: photoUrl,
      fullname: fullname,
      uid: uid,
      contactnumber: contactnumber,
      latitude: lat,
      longitude: lng,
    );
  }
}