import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for HapticFeedback
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false; // Add this state variable

  late AnimationController _controller;
  final List<Color> _backgroundColors = [
    Colors.deepPurple,
    Colors.indigo,
    Colors.teal,
    Colors.blueGrey,
    Colors.deepOrange,
  ];
  final List<Color> _textColors = [
    Colors.white,
    Colors.amberAccent,
    Colors.lightGreenAccent,
    Colors.pinkAccent,
    Colors.cyanAccent,
  ];
  int _currentColorIndex = 0;

  final List<String> _streamTexts = [
    'Start something new',
    'Explore the possibilities',
    'Unlock your potential',
    'Create something amazing',
    'Innovate and inspire',
  ];
  int _currentTextIndex = 0;
  String _displayText = '';
  int _currentLetterIndex = 0;
  bool _isTyping = true;

  // Animation speed (milliseconds per letter)
  final int _typingSpeed = 50; // Adjust this value to control typing speed
  final int _deletingSpeed = 50; // Adjust this value to control deleting speed

  // Padding for the text and circle
  final EdgeInsets _textPadding = const EdgeInsets.only(right: 16); // Adjust this value

  // Position of the text and button
  final Alignment _textPosition = Alignment(0.0, -0.31); // Adjust this value
  final Alignment _buttonPosition = Alignment(0.0, 1); // Adjust this value (lifted up)

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // Start text stream
    _startTextStream();
  }

  void _startTextStream() {
    Future.delayed(Duration(milliseconds: _isTyping ? _typingSpeed : _deletingSpeed), () {
      if (mounted) {
        if (_isTyping) {
          // Typing animation: Add one letter at a time
          if (_currentLetterIndex < _streamTexts[_currentTextIndex].length) {
            setState(() {
              _displayText += _streamTexts[_currentTextIndex][_currentLetterIndex];
              _currentLetterIndex++;
            });
            _startTextStream();
          } else {
            // Wait for a moment before starting to delete
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _isTyping = false;
                });
                _startTextStream();
              }
            });
          }
        } else {
          // Deleting animation: Remove one letter at a time
          if (_displayText.isNotEmpty) {
            setState(() {
              _displayText = _displayText.substring(0, _displayText.length - 1);
            });
            _startTextStream();
          } else {
            // Move to the next text and cycle colors
            setState(() {
              _currentTextIndex = (_currentTextIndex + 1) % _streamTexts.length;
              _currentLetterIndex = 0;
              _isTyping = true;
              _currentColorIndex = (_currentColorIndex + 1) % _backgroundColors.length;
            });
            _startTextStream();
          }
        }
      }
    });
  }

  Future<bool> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        print('Login successful! User: ${userCredential.user?.email}');
        HapticFeedback.lightImpact();
        return true; // Success
      } on FirebaseAuthException catch (e) {
        print('Login failed: ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Login failed'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        HapticFeedback.heavyImpact();
        return false; // Failure
      } finally {
        setState(() => _isLoading = false);
      }
    }
    return false; // Validation failed
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _backgroundColors[_currentColorIndex],
                      _backgroundColors[_currentColorIndex].withOpacity(0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),

          // Center of y: Text Stream and Circle
          Align(
            alignment: _textPosition, // Use the position you control
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Text Stream
                Padding(
                  padding: _textPadding, // Use the padding you control
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    child: Text(
                      _displayText,
                      key: ValueKey<String>(_displayText),
                      style: TextStyle(
                        color: _textColors[_currentColorIndex], // Cycle text colors
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Circle (same color as text)
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _textColors[_currentColorIndex], // Match text color
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          // Bottom Login Container (lifted up)
          Align(
            alignment: _buttonPosition, // Use the position you control
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF141414),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.white),
                      obscureText: !_isPasswordVisible, // Control visibility
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible; // Toggle password visibility
                            });
                          },
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter password' : null,
                    ),
                    const SizedBox(height: 24),
                    ActionSlider.standard(
                      sliderBehavior: SliderBehavior.stretch,
                      backgroundColor: Colors.blueGrey.shade900, // Dark elegant base color
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                      loadingIcon: const CircularProgressIndicator(color: Colors.white),
                      successIcon: const Icon(Icons.check_circle, color: Colors.lightGreenAccent), // Success icon
                      failureIcon: const Icon(Icons.close_rounded, color: Colors.redAccent), // Failure icon
                      height: 60,
                      width: double.infinity,
                      toggleColor: Colors.tealAccent.shade400, // Vibrant contrast for the toggle
                      child: Center(
                        child: Text(
                          'Slide to Log In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      action: (controller) async {
                        controller.loading(); // Start loading animation
                        bool loginSuccessful = await _login(); // Check login result

                        if (loginSuccessful) {
                          controller.success(); // Show success animation
                        } else {
                          controller.failure(); // Show failure animation
                          await Future.delayed(const Duration(milliseconds: 1200)); // Short delay before reset
                          controller.reset(); // Reset the slider position
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact(); // Haptic feedback when navigating to sign-up
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text(
                        'Don’t have an account? Sign Up',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}