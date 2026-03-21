// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter/foundation.dart';

// class GoogleSignInResult {
//   final bool success;
//   final String? errorMessage;

//   GoogleSignInResult({required this.success, this.errorMessage});
// }

// class FirebaseServices {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     serverClientId:
//         '386639720274-4pnv1c0trktdkap5eiu239cira38037o.apps.googleusercontent.com',
//     scopes: ['email', 'profile'],
//   );

//   Future<GoogleSignInResult> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser =
//           await _googleSignIn.signIn();

//       if (googleUser == null) {
//         return GoogleSignInResult(
//           success: false,
//           errorMessage: "Sign in cancelled",
//         );
//       }

//       final googleAuth = await googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         idToken: googleAuth.idToken,
//         accessToken: googleAuth.accessToken,
//       );

//       await _auth.signInWithCredential(credential);

//       return GoogleSignInResult(success: true);
//     } catch (e) {
//       debugPrint("Google Sign-In Error: $e");
//       return GoogleSignInResult(
//         success: false,
//         errorMessage: e.toString(),
//       );
//     }
//   }

//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     await _auth.signOut();
//   }

//   User? get currentUser => _auth.currentUser;
// }
