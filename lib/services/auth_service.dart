import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> register(String email, String password, String username) async {
    try {
      final taken = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

        if (taken.docs.isNotEmpty) {
      return 'Username already taken';
    }

      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document
      await _db.collection('users').doc(userCred.user!.uid).set({
        'username': username,
        'score': 0,
        'coins': 0,
        'winRate': 0.0,
        'bestStreak': 0,
        'currentStreak': 0,
        'totalWordsGuessed': 0,
        'averageTries': 0.0,
        'solvedWords': [],
        'email': email,
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> logout() => _auth.signOut();
}
