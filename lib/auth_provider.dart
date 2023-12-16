// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:assignment/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? user;
  String name = "";
  String error = "";
  String? verificationId;
  //for disabling actions while sending otp.
  bool isLoading = false;

  void addException(String e) {
    isLoading = false;
    error = e;
    notifyListeners();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void addUser(String name, String id, [String? avatar]) {
    isLoading = false;
    user = UserModel(
      id: id,
      name: name,
    );
    notifyListeners();
  }

  addVerificationId(String verification) {
    isLoading = false;
    verificationId = verification;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        addUser(
          user.displayName ?? "",
          user.email ?? "",
          user.photoURL,
        );
      }
    }
  }

  void addName(String Name) {
    name = Name;
    notifyListeners();
  }

  Future<void> phoneSignIn({
    required String phoneNumber,
    required String name,
  }) async {
    isLoading = true;
    notifyListeners();
    addName(name);
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: _onVerificationCompleted,
        verificationFailed: _onVerificationFailed,
        codeSent: _onCodeSent,
        codeAutoRetrievalTimeout: _onCodeTimeout);
  }

  void verifyPhone(String otpCode) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otpCode,
      );

      final User? user = (await _auth.signInWithCredential(credential)).user;
      if (user != null) {
        addUser(name, user.phoneNumber!);
      }
    } catch (e) {
      verificationId = null;
      addException("verification failed");
    }
  }

  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    // User? user = FirebaseAuth.instance.currentUser;

    // if (authCredential.smsCode != null) {
    //   try {
    //     UserCredential credential =
    //         await user!.linkWithCredential(authCredential);
    //   } on FirebaseAuthException catch (e) {
    //     if (e.code == 'provider-already-linked') {
    //       await _auth.signInWithCredential(authCredential);
    //     }
    //   }
    // }
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    addException(exception.code);
  }

  _onCodeSent(String verificationId, int? forceResendingToken) {
    addVerificationId(verificationId);
  }

  _onCodeTimeout(String timeout) {
    addException(timeout);
    return null;
  }

  // ... rest of the methods here
}
