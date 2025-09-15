import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  Future<void> signInWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: 'nukkadfoods@gmail.com', password: 'NukkadFoods');
      _user = userCredential.user;
      notifyListeners();
    } catch (e) {
      print('Error during email sign-in: $e');
    }
  }

  bool get isSignedIn => _user != null;
}
