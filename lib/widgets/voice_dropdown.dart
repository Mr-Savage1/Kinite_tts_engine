import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tts_provider.dart';
import '../services/speaker_data.dart';
import '../themes/app_theme.dart';

class VoiceDropdown extends StatelessWidget {
  const VoiceDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TtsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            key: ValueKey(provider.engine),
            value: provider.voice,
            isExpanded: true,
            dropdownColor: isDark ? Colors.grey[850] : Colors.white,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            items: SpeakerData.getVoices(provider.engine).map((v) {
              final isSelected = v == provider.voice;
              return DropdownMenuItem(
                value: v,
                child: Container(
                  color: isSelected
                      ? (isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.1))
                      : Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Row(
                    children: [
                      if (isSelected)
                        Container(
                          width: 3,
                          height: 20,
                          color: AppTheme.brandMain,
                        ),
                      if (isSelected) const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          v,
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.brandMain
                                : (isDark ? Colors.grey[300] : Colors.grey[800]),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) provider.selectVoice(v);
            },
          ),
        ),
      ),
    );
  }
}