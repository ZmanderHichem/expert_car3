import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_card.dart';
import '../widgets/gradient_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          var data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _emailController.text = data['email'] ?? '';
            _nomController.text = data['nom'] ?? '';
            _prenomController.text = data['prenom'] ?? '';
          });
        }
      } catch (e) {
        debugPrint("Erreur lors du chargement des données : $e");
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      // Mettre à jour les informations de base
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'nom': _nomController.text,
        'prenom': _prenomController.text,
      });

      // Si un mot de passe est entré, le mettre à jour
      if (_passwordController.text.isNotEmpty) {
        await user.updatePassword(_passwordController.text);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'password': _passwordController.text,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: AppTheme.success,
        ),
      );

      setState(() {
        _isEditing = false;
        _passwordController.clear();
        _confirmPasswordController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mon Profil', style: AppTextStyles.h2),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                  icon: Icon(_isEditing ? Icons.close : Icons.edit),
                  label: Text(_isEditing ? 'Annuler' : 'Modifier'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Photo de profil
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Email (non modifiable)
                  AnimatedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email', style: AppTextStyles.h3),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          enabled: false,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            fillColor: AppTheme.background,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Prénom
                  AnimatedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Prénom', style: AppTextStyles.h3),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _prenomController,
                          enabled: _isEditing,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre prénom';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Nom
                  AnimatedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nom', style: AppTextStyles.h3),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nomController,
                          enabled: _isEditing,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre nom';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  if (_isEditing) ...[
                    const SizedBox(height: 16),
                    
                    // Nouveau mot de passe
                    AnimatedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nouveau mot de passe', style: AppTextStyles.h3),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline),
                              hintText: 'Laisser vide pour ne pas changer',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Confirmer mot de passe
                    AnimatedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Confirmer le mot de passe', style: AppTextStyles.h3),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                            ),
                            validator: (value) {
                              if (_passwordController.text.isNotEmpty &&
                                  value != _passwordController.text) {
                                return 'Les mots de passe ne correspondent pas';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Bouton de sauvegarde
                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        text: 'Sauvegarder les modifications',
                        icon: Icons.save,
                        isLoading: _isLoading,
                        onPressed: _updateProfile,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Statistiques
            AnimatedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Statistiques', style: AppTextStyles.h3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Voitures', '2', Icons.directions_car),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Services', '15', Icons.build),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Km Total', '125k', Icons.speed),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Économies', '2.5k€', Icons.savings),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h3),
          Text(title, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}