import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tts_provider.dart';
import '../themes/theme_extension.dart';

class EngineButton extends StatelessWidget {
  final String engineName;

  const EngineButton({super.key, required this.engineName});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TtsProvider>(context);
    final bool isActive = provider.engine == engineName;
    final themeExt = Theme.of(context).extension<KiniteThemeExtension>()!;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: provider.isReady && !isActive ? () => provider.loadEngine(engineName) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          gradient: isActive ? themeExt.primaryGradient : null,
          color: isActive ? null : Colors.transparent,
          border: Border.all(
            color: isActive ? Colors.transparent : themeExt.glassBorder,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: isActive
              ? [BoxShadow(color: themeExt.buttonShadow, blurRadius: 10)]
              : [],
        ),
        child: Text(
          engineName,
          style: textTheme.bodyMedium?.copyWith(
            color: isActive
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87), // ← Darker on light theme
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}