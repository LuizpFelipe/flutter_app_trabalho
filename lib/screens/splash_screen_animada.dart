import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreenAnimada extends StatefulWidget {
  const SplashScreenAnimada({super.key});

  @override
  State<SplashScreenAnimada> createState() => _SplashScreenAnimadaState();
}

class _SplashScreenAnimadaState extends State<SplashScreenAnimada>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/animations/list_animation.json',
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward().whenComplete(() {
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              });
          },
        ),
      ),
    );
  }
}
