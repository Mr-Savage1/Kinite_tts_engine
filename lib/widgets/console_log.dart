import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tts_provider.dart';
import 'glass_card.dart';

class ConsoleLog extends StatefulWidget {
  final bool isDark;

  const ConsoleLog({super.key, required this.isDark});

  @override
  State<ConsoleLog> createState() => _ConsoleLogState();
}

class _ConsoleLogState extends State<ConsoleLog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TtsProvider>(context);
    final logs = provider.consoleLogs;

    // Auto-scroll when new logs are added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return GlassCard(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: logs.length,
        itemBuilder: (context, i) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '> ${logs[i]}',
              style: TextStyle(
                color: widget.isDark
                    ? const Color(0xFF00FF9D)  // Bright green for dark mode
                    : const Color(0xFF008F5D), // Darker green for light mode
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
}