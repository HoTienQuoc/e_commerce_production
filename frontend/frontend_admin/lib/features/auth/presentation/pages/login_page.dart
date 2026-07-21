import 'dart:math';

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ParticleSystem {
  final List<Particle> _particles = List.generate(100, (index) => Particle());
}

class Particle {
  late double x;
  late double y;
  late double radius;
  late Color color;
  final double speed;

  Particle() : speed = Random().nextDouble() * 0.5 + 0.1 {
    reset();
  }

  void reset() {
    final random = Random();
    x = random.nextDouble();
    y = random.nextDouble();
    radius = random.nextDouble() * 3 + 1;
    color = Color.fromRGBO(
      random.nextInt(100) + 100,
      random.nextInt(100) + 100,
      random.nextInt(200) + 50,
      random.nextDouble() * 0.3 + 0.1,
    );
  }

  void update(double progress) {
    x += (sin(progress * 2 * pi + x * 10) * 0.001 * speed);
    y += (sin(progress * 2 * pi + x * 10) * 0.001 * speed);

    // wrap around
    x = x % 1;
    y = y % 1;
  }
}
