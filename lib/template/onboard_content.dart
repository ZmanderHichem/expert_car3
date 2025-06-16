import 'package:flutter/material.dart';
import './landed_content.dart';
import './sing_up_form.dart';
import '../services/auth_service.dart';
import '../login/register_page.dart';

class OnboardContent extends StatefulWidget {
  const OnboardContent({super.key});

  @override
  State<OnboardContent> createState() => _OnboardContentState();
}

class _OnboardContentState extends State<OnboardContent> {
  late PageController _pageController;
  // double _progress;
  final AuthService _authService = AuthService();

  // Ajoutez des contrôleurs pour collecter les informations nécessaires
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedCarModel;
  String? _selectedFuelType;
  final _kilometrageController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();

  void _createAccount() {
    // Log filled and unfilled fields
    print(
        'Email: ${_emailController.text.isNotEmpty ? "Filled" : "Not filled"}');
    print(
        'Password: ${_passwordController.text.isNotEmpty ? "Filled" : "Not filled"}');
    print(
        'Car Model: ${_selectedCarModel != null ? "Selected" : "Not selected"}');
    print(
        'Fuel Type: ${_selectedFuelType != null ? "Selected" : "Not selected"}');
    print(
        'Kilometrage: ${_kilometrageController.text.isNotEmpty ? "Filled" : "Not filled"}');
    print('Nom: ${_nomController.text.isNotEmpty ? "Filled" : "Not filled"}');
    print(
        'Prenom: ${_prenomController.text.isNotEmpty ? "Filled" : "Not filled"}');

    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _selectedCarModel != null &&
        _selectedFuelType != null &&
        _kilometrageController.text.isNotEmpty &&
        _nomController.text.isNotEmpty &&
        _prenomController.text.isNotEmpty) {
      _authService.register(
        email: _emailController.text,
        password: _passwordController.text,
        carModel: _selectedCarModel!,
        kilometrage: _kilometrageController.text,
        fuelType: _selectedFuelType!,
        nom: _nomController.text,
        prenom: _prenomController.text,
        context: context,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
    }
  }

  @override
  void initState() {
    _pageController = PageController()
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double progress =
        _pageController.hasClients ? (_pageController.page ?? 0) : 0;

    return SizedBox(
      height: 500 + progress * 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: [
                    const LandingContent(),
                    SignUpForm(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      selectedCarModel: _selectedCarModel,
                      selectedFuelType: _selectedFuelType,
                      kilometrageController: _kilometrageController,
                      nomController: _nomController,
                      prenomController: _prenomController,
                      onCarModelChanged: (value) {
                        setState(() {
                          _selectedCarModel = value;
                        });
                      },
                      onFuelTypeChanged: (value) {
                        setState(() {
                          _selectedFuelType = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            height: 46,
            bottom: 0,
            right: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    stops: [0.4, 0.8],
                    colors: [
                      Color.fromARGB(255, 239, 104, 80),
                      Color.fromARGB(255, 139, 33, 146)
                    ],
                  ),
                ),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Allons-y"),
                      const Icon(
                        Icons.chevron_right,
                        size: 24,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
