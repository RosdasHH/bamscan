import 'package:flutter/material.dart';

class NfcAnimation extends StatefulWidget {
  const NfcAnimation({super.key});

  @override
  State<NfcAnimation> createState() => _NfcAnimationState();
}

class _NfcAnimationState extends State<NfcAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest.shortestSide * 0.8;

          return SizedBox(
            width: size,
            height: size,
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final t = _c.value;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    _glow(),

                    _wave(size * 0.9, t),
                    _wave(size * 0.7, (t + 0.33) % 1),
                    _wave(size * 0.5, (t + 0.66) % 1),

                    _core(),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _wave(double size, double t) {
    final scale = 0.4 + (t * 0.8);

    return Opacity(
      opacity: (1 - t).clamp(0.0, 1.0),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.blueAccent.withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _core() {
    return Container(
      width: 100,
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.blue.withOpacity(0.25),
            Colors.blue.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.blue.withOpacity(0.4), width: 1),
      ),
      child: const Icon(Icons.contactless, size: 44, color: Colors.blue),
    );
  }

  Widget _glow() {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.25),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}
