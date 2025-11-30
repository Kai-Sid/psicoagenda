import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/usuario.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<Usuario?> getUsuarioActual() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('usuarios').doc(user.uid).get();
    if (!doc.exists) return null;

    return Usuario.fromMap(doc.id, doc.data()! as Map<String, dynamic>);
  }

  Future<void> registrarUsuario({
    required String nombre,
    required String email,
    required String telefono,
    required String password,
    required String rol,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user!.uid;

    final usuario = Usuario(
      uid: uid,
      nombre: nombre,
      email: email,
      telefono: telefono,
      rol: rol,
    );

    await _db.collection('usuarios').doc(uid).set({
      ...usuario.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
