import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:investgame/telas/login_screen.dart';
import 'package:investgame/telas/principal.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseAuth _user = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FacebookLogin _facebookLogin = FacebookLogin();
  FirebaseUser _seeUser;

  Future<String> seeUser() async {
    FirebaseUser seeUser = await _auth.currentUser();
    return seeUser.toString();
  }

  bool checkIfLogged() {
    if (_user.currentUser() == null)
      return false;
    else
      return true;
  }

  Future<bool> singUpWithEmail(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      if (user != null)
        return true;
      else
        return false;
    } catch (e) {
      print(e.message);
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      if (user != null)
        return true;
      else
        return false;
    } catch (e) {
      print(e.message);
      return false;
    }
  }

  Future<void> logOut(context) async {
    try {
      _auth.signOut();
      _googleSignIn.signOut();
      _facebookLogin.logOut();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
      print('logout');
    } catch (e) {
      print("Error logging out.");
    }
  }

  Future<bool> loginWithGoogle(context) async {
    try {
      GoogleSignInAccount account = await _googleSignIn.signIn();
      if (account == null) return false;
      AuthResult res = await _auth.signInWithCredential(
        GoogleAuthProvider.getCredential(
          idToken: (await account.authentication).idToken,
          accessToken: (await account.authentication).accessToken,
        ),
      );
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Principal()));
      if (res.user == null) return false;
      return true;
    } catch (e) {
      print(e.message);
      print("Error logging with Google.");
      return false;
    }
  }

  Future<bool> loginWithFacebook(context) async {
    try {
      await _facebookLogin.logIn(['email', 'public_profile']).then((result) {
        switch (result.status) {
          case FacebookLoginStatus.loggedIn:
            FirebaseAuth.instance
                .signInWithCredential(FacebookAuthProvider.getCredential(
                    accessToken: result.accessToken.token))
                .then((signedUser) {
              print('signed in as ${signedUser.user.displayName}');
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Principal()));
            }).catchError((e) {
              print(e);
            });
            break;
          default:
        }
      }).catchError((a) {});
    } catch (e) {
      print(e.message);
      print("Error logging with Google.");
      return false;
    }
  }

  Future<bool> sendForgotPasswordEmail(context) async {
    try {
      _seeUser = await _auth.currentUser();
      _user.sendPasswordResetEmail(email: _seeUser.email);
    } catch (e) {
      print(e.message);
      print("error on forgotPassword");
      return false;
    }
  }
}
