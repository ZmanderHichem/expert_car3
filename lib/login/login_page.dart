import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart'; // Import du fichier principal pour accéder à BottomNavBar
import 'register_page.dart'; // Import de la page d'inscription
import '../questionnaire/questionnaire_page.dart'; // Import de la page de questionnaire

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Connexion de l'utilisateur avec Firebase Auth
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // FORCER l'actualisation depuis le serveur
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get(GetOptions(source: Source.server));

        if (!userDoc.exists) {
          throw FirebaseAuthException(
            code: 'missing-data',
            message: 'Profil utilisateur introuvable',
          );
        }

        // CONVERSION EXPLICITE ET NULL-SAFE
        final userData = userDoc.data() as Map<String, dynamic>;
        final questionnaireProgress =
            (userData['questionnaireProgress'] as int?) ?? 0;
        final questionnaireCompleted =
            (userData['questionnaireCompleted'] as bool?) ?? false;
        final carModels = (userData['carModel'] as List<dynamic>?) ?? [];
        final carModel =
            carModels.isNotEmpty ? carModels.first.toString() : null;

        // DEBUG DÉTAILLÉ
        debugPrint('''
        État questionnaire:
        - Progrès: $questionnaireProgress/6
        - Complété: $questionnaireCompleted
        - Modèle voiture: $carModel
        ''');

        // VÉRIFICATION FINALE STRICTE
        final shouldRedirect = !questionnaireCompleted ||
            questionnaireProgress < 6 ||
            carModel == null;

        if (shouldRedirect) {
          debugPrint('Redirection vers le questionnaire');
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => QuestionnairePage(
                  userId: userCredential.user!.uid,
                  carModel: carModel ?? 'Modèle inconnu',
                  initialQuestionIndex: questionnaireProgress,
                ),
              ),
            );
            return; // EMPÊCHER LA SUITE DE L'EXÉCUTION
          }
        } else {
          // SEULEMENT SI TOUT EST VALIDE
          // SEULEMENT SI TOUT EST VALIDE
          debugPrint('Accès autorisé à l\'app principale');
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => BottomNavBar(carModel: carModel),
              ),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        // Gérer les erreurs de connexion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Erreur de connexion')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Champ pour l'email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  return null;
                },
              ),
              // Champ pour le mot de passe
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Bouton de connexion
              ElevatedButton(
                onPressed: _login,
                child: const Text('Se connecter'),
              ),
              const SizedBox(height: 10),
              // Lien vers la page d'inscription
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text('Créer un compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
