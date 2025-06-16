import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../questionnaire/questionnaire_page.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> register({
    required String email,
    required String password,
    required String carModel,
    required String kilometrage,
    required String fuelType,
    required String nom,
    required String prenom,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'password':
            password, // Attention : stocker les mots de passe en clair n'est pas sécurisé
        'carModel': [carModel],
        'kilometrage': kilometrage,
        'fuelType': fuelType,
        'nom': nom,
        'prenom': prenom,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (carModel.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .collection(carModel)
            .doc('details')
            .set({
          'initialKilometrage': kilometrage,
          'fuelType': fuelType,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuestionnairePage(
            userId: userCredential.user!.uid,
            carModel: carModel,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Erreur d\'inscription')),
      );
    }
  }
}
