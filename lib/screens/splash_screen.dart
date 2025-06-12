import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _textAnimation;
  final String _title = 'Todo Calendar';
  final String _subtitle = 'Organize your life';
  int _currentTitleIndex = 0;
  int _currentSubtitleIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.5, curve: Curves.easeIn),
      ),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Animate title text
    Future.doWhile(() async {
      if (_currentTitleIndex < _title.length) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _currentTitleIndex++;
        });
        return true;
      }
      return false;
    });

    // Animate subtitle text
    Future.delayed(const Duration(milliseconds: 500), () {
      Future.doWhile(() async {
        if (_currentSubtitleIndex < _subtitle.length) {
          await Future.delayed(const Duration(milliseconds: 50));
          setState(() {
            _currentSubtitleIndex++;
          });
          return true;
        }
        return false;
      });
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        final isAuthenticated = context.read<AuthProvider>().isAuthenticated;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => isAuthenticated
                ? const HomeScreen()
                : const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer rotating circle
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotateAnimation.value * 3.14159,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                // Middle rotating circle
                Transform.scale(
                  scale: _scaleAnimation.value * 0.8,
                  child: Transform.rotate(
                    angle: -_rotateAnimation.value * 3.14159,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                // Inner circle with icon
                Transform.scale(
                  scale: _scaleAnimation.value * 0.6,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: const Icon(
                        Icons.check_circle_outline,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Text content
                Positioned(
                  top: 280,
                  child: Opacity(
                    opacity: _textAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _title.substring(0, _currentTitleIndex),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _subtitle.substring(0, _currentSubtitleIndex),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            letterSpacing: 1.0,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
} 