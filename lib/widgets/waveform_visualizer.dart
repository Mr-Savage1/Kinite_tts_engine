import 'package:flutter/material.dart';

class WaveformVisualizer extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final double height;
  final int barCount;

  const WaveformVisualizer({
    super.key,
    required this.controller,
    required this.color,
    this.height = 40,
    this.barCount = 30,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(barCount, (index) {
              // Create varying heights based on animation value and index
              double barHeight = height * (0.3 + (controller.value * 0.7));

              // Add some variation based on index for natural look
              double variation = (index % 5) * 0.1;
              if (index % 3 == 0) barHeight *= 0.8;
              if (index % 7 == 0) barHeight *= 1.2;

              // Ensure minimum height
              barHeight = barHeight.clamp(height * 0.2, height * 0.9);

              return Container(
                width: 4,
                height: barHeight,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.5),
                      color,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}