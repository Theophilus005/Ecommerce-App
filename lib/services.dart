import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;

  //Sign Up With Email and Password
  Future registerInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult _register = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _user = _register.user;
      return _register.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future userInfo(String fname, String lname) async {
    if (_user != null) {
      Firestore.instance.collection("Users").document(_user.uid).setData({
        'fname': fname,
        'lname': lname,
        'uid': _user.uid,
        'email': _user.email
      });
    }
  }

  //Login
  Future loginInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult _result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser _user = _result.user;
      print(_user.uid);
      return _user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //SignOut
  Future signOut() async {
    await _auth.signOut();
    return null;
  }

  //Auth Stream
  Stream<FirebaseUser> get status {
    return _auth.onAuthStateChanged;
  }
}
