import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tts_provider.dart';
import '../widgets/engine_button.dart';
import '../widgets/voice_dropdown.dart';
import '../widgets/console_log.dart';
import '../widgets/glass_card.dart';
import '../widgets/waveform_visualizer.dart';
import '../themes/app_theme.dart';
import '../themes/theme_extension.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late AnimationController _waveformController;

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _textController.dispose();
    _waveformController.dispose();
    super.dispose();
  }

  // Professional button state methods
  Color _getButtonColor(TtsProvider provider) {
    if (!provider.isReady) {
      // Loading state - subtle grey
      return Colors.grey.withOpacity(0.1);
    } else if (provider.isSpeaking) {
      // Synthesizing state - soft blue
      return AppTheme.primaryBright.withOpacity(0.1);
    } else {
      // Ready state - solid brand blue
      return AppTheme.brandMain;
    }
  }

  Color _getButtonBorderColor(TtsProvider provider, bool isDark) {
    if (!provider.isReady) {
      // Loading state - subtle border
      return isDark ? Colors.grey[700]! : Colors.grey[300]!;
    } else if (provider.isSpeaking) {
      // Synthesizing state - glowing blue border
      return AppTheme.primaryBright.withOpacity(0.5);
    } else {
      // Ready state - brand blue border
      return AppTheme.brandMain;
    }
  }

  List<BoxShadow>? _getButtonShadow(TtsProvider provider, KiniteThemeExtension themeExt) {
    if (!provider.isReady) {
      // No shadow for loading state
      return null;
    } else if (provider.isSpeaking) {
      // Soft glow for synthesizing
      return [
        BoxShadow(
          color: AppTheme.primaryBright.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    } else {
      // Strong shadow for ready state
      return [
        BoxShadow(
          color: themeExt.buttonShadow,
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }
  }

  Color _getButtonTextColor(TtsProvider provider, bool isDark) {
    if (!provider.isReady) {
      // Loading state - subtle text
      return isDark ? Colors.grey[500]! : Colors.grey[600]!;
    } else if (provider.isSpeaking) {
      // Synthesizing state - bright blue text
      return AppTheme.primaryBright;
    } else {
      // Ready state - white text
      return Colors.white;
    }
  }

  String _getButtonText(TtsProvider provider) {
    if (!provider.isReady) {
      return 'LOADING';
    } else if (provider.isSpeaking) {
      return 'SYNTHESIZING';
    } else {
      return 'SPEAK';
    }
  }

  Widget? _buildButtonIcon(TtsProvider provider) {
    if (!provider.isReady) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.grey[600]!,
          ),
        ),
      );
    } else if (provider.isSpeaking) {
      return Icon(
        Icons.pause_circle_outline,
        color: AppTheme.primaryBright,
        size: 20,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<KiniteThemeExtension>()!;
    final provider = Provider.of<TtsProvider>(context, listen: true);
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom App Header with your icon.png
              Row(
                children: [
                  // Your custom icon - completely transparent background
                  Image.asset(
                    'assets/icon.png',
                    width: 45,
                    height: 45,
                  ),
                  const SizedBox(width: 12),
                  // App name: "Kinite Engine TTS"
                  Text(
                    'Kinite Engine TTS',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  // Settings button (gear)
                  Container(
                    decoration: BoxDecoration(
                      gradient: themeExt.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Engine Selector (horizontal)
              SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: const [
                    EngineButton(engineName: 'Kokoro'),
                    SizedBox(width: 10),
                    EngineButton(engineName: 'Piper'),
                    SizedBox(width: 10),
                    EngineButton(engineName: 'Kitten'),
                    SizedBox(width: 10),
                    EngineButton(engineName: 'Coqui'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Voice Dropdown
              const VoiceDropdown(),
              const SizedBox(height: 20),

              // Text Input (Glass Card)
              Expanded(
                flex: 3,
                child: GlassCard(
                  borderRadius: 16,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      style: textTheme.bodyLarge,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Type or paste text...',
                        hintStyle: textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Waveform Visualizer (shows when speaking)
              if (provider.isSpeaking) ...[
                WaveformVisualizer(
                  controller: _waveformController,
                  color: AppTheme.primaryBright,
                  height: 40,
                ),
                const SizedBox(height: 12),
              ],

              // Console Log (Glass Card)
              Expanded(
                flex: 1,
                child: GlassCard(
                  borderRadius: 12,
                  child: ConsoleLog(
                    isDark: isDark,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Speak & Stop Row
              Row(
                children: [
                  // Speak Button - Professional with all states
                  Expanded(
                    child: GestureDetector(
                      onTap: provider.isReady && !provider.isSpeaking
                          ? () {
                        provider.speak(_textController.text);
                        _waveformController.repeat(reverse: true);
                      }
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 56,
                        decoration: BoxDecoration(
                          color: _getButtonColor(provider),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getButtonBorderColor(provider, isDark),
                            width: 1.5,
                          ),
                          boxShadow: _getButtonShadow(provider, themeExt),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!provider.isReady || provider.isSpeaking)
                                _buildButtonIcon(provider) ?? const SizedBox(),
                              if (!provider.isReady || provider.isSpeaking)
                                const SizedBox(width: 8),
                              Text(
                                _getButtonText(provider),
                                style: TextStyle(
                                  color: _getButtonTextColor(provider, isDark),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (provider.isSpeaking) ...[
                    const SizedBox(width: 12),
                    // Stop Button - Professional design
                    GestureDetector(
                      onTap: () {
                        provider.stop();
                        _waveformController.stop();
                      },
                      child: Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.redAccent.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.stop,
                          color: Colors.redAccent,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}