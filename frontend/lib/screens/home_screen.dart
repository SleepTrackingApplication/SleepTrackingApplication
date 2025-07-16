import 'dart:math';
import 'package:flutter/material.dart';
import 'registration_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final gradientColors = Theme.of(context).brightness == Brightness.dark
        ? [Color(0xFF1A1032), Color(0xFF2C1A64)]
        : [Colors.purple.shade100, Colors.blue.shade100];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: gradientColors,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile ? screenWidth * 0.9 : 500,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Text(
                    'Sleep Tracking',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black45,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                ),
                LevitationAnimation(
                  child: GentleRotationAnimation(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'images/home_icon2.png',
                        width: isMobile ? 300 : 400,
                        height: isMobile ? 300 : 400,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                Column(
                  children: [
                    _buildAnimatedButton(context, 'Register', Colors.white, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistrationScreen(),
                        ),
                      );
                    }),
                    const SizedBox(height: 15),
                    _buildAnimatedButton(context, 'Log in', Colors.white, () {
                      Navigator.pushNamed(context, '/login');
                    }),
                    const SizedBox(height: 15),
                    _buildAnimatedButton(context, 'Exit', Colors.white, () {
                      _showExitDialog(context);
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Animated button with hover effect
  Widget _buildAnimatedButton(BuildContext context, String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 300,
      height: 55,
      child: HoverScaleAnimation(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.8),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(60),
            ),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.5),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white.withOpacity(0.9),
      title: const Text(
        'Exit from Sleep Tracking',
        textAlign: TextAlign.center,
      ),
      content: const Text(
        'Are you sure you want to exit?',
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: null,
              child: const Text('Exit'),
            ),
          ],
        ),
      ],
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),
  );
}
}

// The movement for the icon is down-up
class LevitationAnimation extends StatefulWidget {
  final Widget child;

  const LevitationAnimation({super.key, required this.child});

  @override
  State<LevitationAnimation> createState() => _LevitationAnimationState();
}

class _LevitationAnimationState extends State<LevitationAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Widget (in our case - icon) goes on the path of a sine wave with an amplitude of 10
        final offset = 10.0 * sin(_controller.value * 2 * pi);
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// Widget wobble animation
class GentleRotationAnimation extends StatefulWidget {
  final Widget child;

  const GentleRotationAnimation({super.key, required this.child});

  @override
  State<GentleRotationAnimation> createState() => _GentleRotationAnimationState();
}

class _GentleRotationAnimationState extends State<GentleRotationAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // The formula for cyclic wobbling of the widget
        final rotation = 0.02 * sin(_controller.value * 2 * 3.1416);
        return Transform.rotate(
          angle: rotation,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// Zoom in on hover (for buttons)
class HoverScaleAnimation extends StatefulWidget {
  final Widget child;
  const HoverScaleAnimation({super.key, required this.child});

  @override
  State<HoverScaleAnimation> createState() => _HoverScaleAnimationState();
}

class _HoverScaleAnimationState extends State<HoverScaleAnimation> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _isHovered ? 1.05 : 1.0,
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}