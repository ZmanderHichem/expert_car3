import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login/login_page.dart';
import '../questionnaire/questionnaire_page.dart';

class SignUpForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? selectedCarModel;
  final String? selectedFuelType;
  final TextEditingController kilometrageController;
  final TextEditingController nomController;
  final TextEditingController prenomController;
  final ValueChanged<String?> onCarModelChanged;
  final ValueChanged<String?> onFuelTypeChanged;

  const SignUpForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.selectedCarModel,
    required this.selectedFuelType,
    required this.kilometrageController,
    required this.nomController,
    required this.prenomController,
    required this.onCarModelChanged,
    required this.onFuelTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          decoration: InputDecoration(labelText: 'Email'),
          onChanged: (value) => print('Email field updated: $value'),
        ),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(labelText: 'Password'),
          onChanged: (value) => print('Password field updated: $value'),
        ),
        // Example dropdown for car model
        DropdownButton<String>(
          value: selectedCarModel,
          hint: Text('Select Car Model'),
          items: <String>['Model A', 'Model B', 'Model C'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            onCarModelChanged(value);
            print('Car Model selected: $value');
          },
        ),
        // Example dropdown for fuel type
        DropdownButton<String>(
          value: selectedFuelType,
          hint: Text('Select Fuel Type'),
          items: <String>['Petrol', 'Diesel', 'Electric'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            onFuelTypeChanged(value);
            print('Fuel Type selected: $value');
          },
        ),
        TextField(
          controller: kilometrageController,
          decoration: InputDecoration(labelText: 'Kilometrage'),
          onChanged: (value) => print('Kilometrage field updated: $value'),
        ),
        TextField(
          controller: nomController,
          decoration: InputDecoration(labelText: 'Nom'),
          onChanged: (value) => print('Nom field updated: $value'),
        ),
        TextField(
          controller: prenomController,
          decoration: InputDecoration(labelText: 'Prenom'),
          onChanged: (value) => print('Prenom field updated: $value'),
        ),
      ],
    );
  }
}
