import 'package:aura_techwizard/models/user.dart' as ModelUser;
import 'package:aura_techwizard/resources/user_provider.dart';
import 'package:aura_techwizard/views/auth_screens/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'dart:io';


import 'package:aura_techwizard/models/user.dart' as ModelUser;
import 'package:aura_techwizard/resources/user_provider.dart';
import 'package:aura_techwizard/views/auth_screens/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class PastelColors {
  static const Color pastelGreen = Color(0xFFB8E3A7);
  static const Color pastelBlue = Color(0xFFA7D8EA);
  static const Color pastelPink = Color(0xFFF2C6C2);
  static const Color pastelPurple = Color(0xFFD8BFD8);
  static const Color pastelYellow = Color(0xFFFFF5BA);
}

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}

class UserScreen extends StatelessWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ModelUser.User? user = Provider.of<UserProvider>(context).getUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        backgroundColor: PastelColors.pastelBlue,
        actions: [
          GestureDetector(
            onTap: () async {
              await AuthMethods().signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen())
              );
            },
            child: Icon(Icons.logout, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 90,
                        backgroundImage: NetworkImage(user!.photoUrl),
                        backgroundColor: PastelColors.pastelPink,
                      ),
                      Positioned(
                        bottom: 20,
                        right: 0,
                        child: Icon(Icons.add_a_photo, size: 30, color: PastelColors.pastelPurple),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              userProfDisplay(context, 'Name', user.fullname),
              SizedBox(height: 10),
              userProfDisplay(context, 'Email', user.email),
              SizedBox(height: 10),
              userProfDisplay(context, 'Username', user.username),
              SizedBox(height: 10),
              userProfDisplay(context, 'Contact No.', user.contactnumber),
              SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        currentUser: user,
                      ),
                    ),
                  );
                },
                child: circularGradientContainer("Edit Profile", context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final ModelUser.User currentUser;

  const EditProfileScreen({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullnameController;
  late TextEditingController _usernameController;
  late TextEditingController _contactNumberController;
  bool _isLoading = false;
  String _profileImageUrl = '';
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _fullnameController = TextEditingController(text: widget.currentUser.fullname);
    _usernameController = TextEditingController(text: widget.currentUser.username);
    _contactNumberController = TextEditingController(text: widget.currentUser.contactnumber);
    _profileImageUrl = widget.currentUser.photoUrl;
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<String> _uploadImage() async {
    if (_imageFile == null) return _profileImageUrl;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${widget.currentUser.uid}.jpg');
      
      await storageRef.putFile(_imageFile!);
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return _profileImageUrl;
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = await _uploadImage();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUser.uid)
          .update({
        'fullname': _fullnameController.text,
        'username': _usernameController.text,
        'contactnumber': _contactNumberController.text,
        'photoUrl': imageUrl,
      });

      DocumentSnapshot userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUser.uid)
          .get();
      
      ModelUser.User updatedUser = ModelUser.User.fromSnap(userSnap);
      
      Provider.of<UserProvider>(context, listen: false).refreshUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: PastelColors.pastelPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 64,
                    backgroundImage: _imageFile != null 
                        ? FileImage(_imageFile!) as ImageProvider
                        : NetworkImage(_profileImageUrl),
                    backgroundColor: PastelColors.pastelYellow,
                  ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: _selectImage,
                      icon: Icon(Icons.add_a_photo, color: PastelColors.pastelBlue),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _fullnameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  fillColor: PastelColors.pastelPink.withOpacity(0.3),
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  fillColor: PastelColors.pastelYellow.withOpacity(0.3),
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contactNumberController,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                  fillColor: PastelColors.pastelGreen.withOpacity(0.3),
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your contact number';
                  }
                  return null;
                },
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PastelColors.pastelBlue,
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Update Profile', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget userProfDisplay(BuildContext context, String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black)),
      SizedBox(height: 5),
      Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: PastelColors.pastelYellow.withOpacity(0.2),
          border: Border.all(color: PastelColors.pastelBlue),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value, style: TextStyle(fontSize: 20, color: Colors.black)),
        ),
      ),
    ],
  );
}

Widget circularGradientContainer(String text, BuildContext context) {
  return Container(
    height: 50,
    width: MediaQuery.of(context).size.width * 0.4,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [PastelColors.pastelPurple, PastelColors.pastelBlue]),
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: PastelColors.pastelPink),
    ),
    child: Text(
      text,
      style: TextStyle(color: Colors.black),
    ),
  );
}
