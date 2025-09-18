import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rive Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFD6E2EA),
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  StateMachineController? _controller;
  SMIBool? isChecking;
  SMIBool? isHandsUp;
  SMITrigger? trigSuccess;
  SMITrigger? trigFail;

  void _onRiveInit(Artboard artboard) {
    _controller = StateMachineController.fromArtboard(artboard, "LoginMachine");
    if (_controller != null) {
      artboard.addController(_controller!);

      isChecking = _controller!.findSMI<SMIBool>("isChecking");
      isHandsUp = _controller!.findSMI<SMIBool>("isHandsUp");
      trigSuccess = _controller!.findSMI<SMITrigger>("trigSuccess");
      trigFail = _controller!.findSMI<SMITrigger>("trigFail");

      debugPrint("✅ Rive inputs loaded");
    } else {
      debugPrint("⚠️ LoginMachine not found in Rive file!");
    }
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      if (_emailController.text == "test" &&
          _passwordController.text == "1234") {
        trigSuccess?.fire();
      } else {
        trigFail?.fire();
      }
    } else {
      trigFail?.fire();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // UI la scrollable banavnyasathi SingleChildScrollView vapraycha,
        // jeणेकरून keyboard alyavar UI overflow honar nahi.
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              children: [
                /// Animated Character
                // Animation la Expanded madhun kadhun SizedBox madhe thevle ahe
                // aani tyala ek fixed height (250) dili ahe.
                // Tumhi hi height tumchya avdipramane kami-jast karu shakta.
                SizedBox(
                  height: 250,
                  child: RiveAnimation.asset(
                    'assets/login_animation.riv',
                    fit: BoxFit.contain,
                    onInit: _onRiveInit,
                  ),
                ),
                const SizedBox(
                  height: 0,
                ), // Animation aani form madhe thodi jaga
                /// Login Form
                // Animation, Email, Password, aani Button sarv ekach Column madhe aale ahet.
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      /// Email Field
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6E2EA),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.7),
                              offset: const Offset(-6, -6),
                              blurRadius: 10,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(6, 6),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            hintText: "Email",
                            border: InputBorder.none,
                          ),
                          onTap: () {
                            isChecking?.value = true;
                            isHandsUp?.value = false;
                          },
                          onChanged: (value) {
                            isChecking?.value = true;
                          },
                          validator: (value) =>
                              value!.isEmpty ? "Enter email" : null,
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Password Field
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6E2EA),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.7),
                              offset: const Offset(-6, -6),
                              blurRadius: 10,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(6, 6),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: "Password",
                            border: InputBorder.none,
                          ),
                          onTap: () {
                            isHandsUp?.value = true;
                            isChecking?.value = false;
                          },
                          onChanged: (value) {
                            isHandsUp?.value = true;
                          },
                          onFieldSubmitted: (_) {
                            isHandsUp?.value = false;
                          },
                          validator: (value) =>
                              value!.isEmpty ? "Enter password" : null,
                        ),
                      ),
                      const SizedBox(height: 30),

                      /// Login Button
                      GestureDetector(
                        onTap: () {
                          isHandsUp?.value = false;
                          isChecking?.value = false;
                          _login();
                        },
                        child: Container(
                          width: double.infinity,
                          height: 55,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6E2EA),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(6, 6),
                                blurRadius: 10,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.7),
                                offset: const Offset(-6, -6),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
