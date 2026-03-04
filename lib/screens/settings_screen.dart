import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/tts_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/feature_card.dart';
import '../themes/app_theme.dart';
import '../themes/theme_extension.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      print('Attempting to launch: $uri');

      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        print('Launch result: $launched');

        if (!launched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $url'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } else {
        print('Cannot launch: $uri');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $url'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      print('Error launching URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<KiniteThemeExtension>()!;
    final provider = Provider.of<TtsProvider>(context);
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: textTheme.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              // Speed Slider
              GlassCard(
                borderRadius: 16,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Speed',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('0.5x', style: textTheme.bodyMedium),
                          Expanded(
                            child: Slider(
                              value: provider.speed,
                              min: 0.5,
                              max: 2.0,
                              divisions: 15,
                              activeColor: AppTheme.brandMain,
                              onChanged: (value) => provider.setSpeed(value),
                            ),
                          ),
                          Text('2.0x', style: textTheme.bodyMedium),
                        ],
                      ),
                      Center(
                        child: Text(
                          '${provider.speed.toStringAsFixed(1)}x',
                          style: textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Theme Toggle
              GlassCard(
                borderRadius: 16,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
                          ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
                          ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.settings)),
                        ],
                        selected: {provider.themeMode},
                        onSelectionChanged: (Set<ThemeMode> modes) {
                          provider.setThemeMode(modes.first);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔥 FEATURE SHOWCASE - Professional Cards Section
              GlassCard(
                borderRadius: 16,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.brandMain.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              color: AppTheme.brandMain,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Technology Stack',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Feature Cards - Now full width and stacked vertically
                      FeatureCard(
                        icon: Icons.speed,
                        label: 'Pipeline',
                        value: 'Optimized',
                        color: AppTheme.primaryBright,
                        description: 'Streaming synthesis with zero-copy optimization for minimal latency',
                      ),
                      FeatureCard(
                        icon: Icons.memory,
                        label: 'Hardware',
                        value: 'Accelerated',
                        color: Colors.green,
                        description: 'NEON/AVX instructions, GPU offload, and DSP integration',
                      ),
                      FeatureCard(
                        icon: Icons.flash_on,
                        label: 'Latency',
                        value: '<10ms',
                        color: Colors.amber,
                        description: 'First-chunk streaming with sub-10ms response time',
                      ),
                      FeatureCard(
                        icon: Icons.compare_arrows,
                        label: 'Queue',
                        value: 'Smart',
                        color: Colors.purple,
                        description: 'Priority-based audio buffer with dynamic queue management',
                      ),
                      FeatureCard(
                        icon: Icons.architecture,
                        label: 'Isolate',
                        value: 'Parallel',
                        color: Colors.orange,
                        description: 'Dart isolates for non-blocking UI thread performance',
                      ),
                      FeatureCard(
                        icon: Icons.energy_savings_leaf,
                        label: 'Power',
                        value: 'Efficient',
                        color: Colors.teal,
                        description: 'Dynamic frequency scaling and battery-aware processing',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Developer Info
              GlassCard(
                borderRadius: 16,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Developer',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildSocialButton(
                            icon: Icons.alternate_email,
                            label: 'Instagram',
                            color: const Color(0xFFE4405F),
                            url: 'https://www.instagram.com/mr.savage7871/',
                          ),
                          _buildSocialButton(
                            icon: Icons.discord,
                            label: 'Discord',
                            color: const Color(0xFF5865F2),
                            url: 'https://discord.com/users/1293253992062648376',
                          ),
                          _buildSocialButton(
                            icon: Icons.code,
                            label: 'GitHub',
                            color: isDark ? Colors.white : Colors.black,
                            url: 'https://github.com/Mr-Savage1',
                          ),
                          _buildSocialButton(
                            icon: Icons.public,
                            label: 'Portfolio',
                            color: AppTheme.brandMain,
                            url: 'https://mrsavage.42web.io/',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Version
              Center(
                child: Text(
                  'Made By Pratyush Srivastava\nKinite 1.0 Blue Crystal Edition',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required String url,
  }) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => _launchUrl(url, context),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}