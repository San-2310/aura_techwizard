
import 'dart:typed_data';

import 'package:aura_techwizard/models/user.dart' as model;
import 'package:aura_techwizard/resources/storage_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthMethods{
 final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap = await _firestore.collection('users').doc(currentUser.uid!).get();

    return model.User.fromSnap(snap);
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String fullname,
    required String contactnumber,
    required Uint8List file,    
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty && fullname.isNotEmpty && contactnumber.isNotEmpty && file != null) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        
        String photoUrl = await StorageMethods().uploadImageToStorage('profilePics', file, false);

        model.User user = model.User(
          uid: cred.user!.uid,
          username: username,
          email: email,
          fullname: fullname,
          photoUrl: photoUrl,
          contactnumber: contactnumber,
        );

        await _firestore.collection('users').doc(cred.user!.uid).set(user.toJson());
        res = 'success';
      } 
    } on FirebaseAuthException catch(err) {
      if (err.code == 'invalid-email') {
        res = 'The email is invalid';
      }
      if (err.code == 'weak-password') {
        res = 'Password is weak';
      }
    } catch(err) {
      res = err.toString();
    }
    return res;
  }

  //logging in
  Future<String> loginUser({
    required String email,
    required String password
  })async{
    String res = 'Some error occured';
    try{
      if(email.isNotEmpty || password.isNotEmpty)
      {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res = 'success';
      }
      else{
        res = 'Please enter all details';
      }
    }
    catch(err){
      res = err.toString();
    }
    return res;
  }
  
  Future<void> signOut() async {
  try {
    await FirebaseAuth.instance.signOut();
    print('User signed out successfully');
  } catch (e) {
    print('Error signing out: $e');
  }
}


}