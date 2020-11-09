import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cone_drone/models/user.dart';
import 'package:cone_drone/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Duration refreshRate = Duration(seconds: 1);

  // create user object based on Firebase User
  MyUser _userFromFirebaseUser(User user) {
    return user != null
        ? MyUser(uid: user.uid, isVerified: user.emailVerified)
        : null;
  }

  // auth change user stream
  Stream<MyUser> get user {
    return _auth.userChanges().map(_userFromFirebaseUser);
  }

  // sign in Anonymously?

  // sign in email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return _userFromFirebaseUser(credential.user);
    } on FirebaseAuthException catch (e) {
      print(e.message.toString());
      return e.message.toString();
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  // register with email and password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _auth.currentUser.sendEmailVerification();
      return _userFromFirebaseUser(credential.user);
    } on FirebaseAuthException catch (e) {
      print(e.message.toString());
      return e.message.toString();
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  // check email verification
  // note: this might become redundant with the userChanges stream in a future update
  void checkVerification() {
    Timer(refreshRate, () async {
      if (_auth.currentUser != null && !_auth.currentUser.emailVerified) {
        checkVerification();
        _auth.currentUser.reload();
        print('verification: ${_auth.currentUser.emailVerified}');
      }
    });
  }

  // return current verification status
  bool isVerified() {
    return _auth.currentUser.emailVerified;
  }

  // send verification email
  void sendVerificationEmail() {
    _auth.currentUser.sendEmailVerification();
    // signOut();
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
