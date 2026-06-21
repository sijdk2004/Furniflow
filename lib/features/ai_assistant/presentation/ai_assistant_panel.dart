import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AiAssistantPanel extends StatefulWidget {
  final VoidCallback onClose;
  const AiAssistantPanel({super.key, required this.onClose});

  @override
  State<AiAssistantPanel> createState() => _AiAssistantPanelState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final Widget? customWidget;

  _ChatMessage({required this.text, required this.isUser, this.customWidget});
}

class _AiAssistantPanelState extends State<AiAssistantPanel> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(text: 'Hi there! I am FurniFlow AI. How can I assist you with your operations today?', isUser: false),
  ];
  bool _isTyping = false;

  final List<String> _suggestions = [
    'Show delayed orders',
    'Show inventory shortages',
    'Predict production bottlenecks',
  ];

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
      _controller.clear();
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    Widget? customWidget;
    String responseText = "I found some information for you.";

    if (text.toLowerCase().contains('delayed')) {
      responseText = "Here are the currently delayed production orders:";
      customWidget = _buildDelayedOrdersWidget();
    } else if (text.toLowerCase().contains('shortage')) {
      responseText = "I detected 2 critical inventory shortages that might impact production:";
      customWidget = _buildShortagesWidget();
    } else if (text.toLowerCase().contains('predict') || text.toLowerCase().contains('bottleneck')) {
      responseText = "Based on current loads, the Finishing department will become a bottleneck by Thursday.";
      customWidget = _buildBottleneckWidget();
    } else {
      responseText = "I'm a demo AI. Try asking about delayed orders, inventory shortages, or production bottlenecks!";
    }

    setState(() {
      _isTyping = false;
      _messages.add(_ChatMessage(text: responseText, isUser: false, customWidget: customWidget));
    });
  }

  Widget _buildDelayedOrdersWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [Icon(LucideIcons.alertCircle, color: Colors.red, size: 16), SizedBox(width: 8), Text('High Priority', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12))]),
          const SizedBox(height: 8),
          const Text('SO-1029: Executive Desk Set', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('Delayed by 2 days in Sanding', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          const Text('SO-1045: Custom Cabinet', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('Material shortage: Oak Wood', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildShortagesWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('• Oak Wood Panels: 12 units (Min: 50)', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('• Premium Varnish: 5 liters (Min: 20)', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottleneckWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Finishing Capacity: 95%', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: 0.95, color: Colors.orange, backgroundColor: Colors.grey.shade200),
          const SizedBox(height: 8),
          const Text('Recommendation: Shift 2 workers from Assembly to Finishing to prevent backlog.', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 450,
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index], theme);
                },
              ),
            ),
            if (_isTyping)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 12),
                    Text('FurniFlow AI is thinking...', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
            _buildSuggestions(theme),
            _buildInputArea(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.surface]),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FurniFlow AI', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Enterprise Assistant', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ],
          ),
          IconButton(icon: const Icon(LucideIcons.x), onPressed: widget.onClose),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(LucideIcons.bot, size: 16, color: theme.colorScheme.primary),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser ? theme.colorScheme.primary : theme.colorScheme.surface,
                border: message.isUser ? null : Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
                boxShadow: message.isUser ? [] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : theme.colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                  if (message.customWidget != null) message.customWidget!,
                ],
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 24), // Offset for symmetry
        ],
      ),
    );
  }

  Widget _buildSuggestions(ThemeData theme) {
    if (_messages.length > 1) return const SizedBox.shrink(); // Only show on empty state
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _suggestions.map((s) => InkWell(
          onTap: () => _handleSubmitted(s),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2))),
            child: Text(s, style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration(
                hintText: 'Ask anything about operations...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: theme.colorScheme.primary)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(LucideIcons.send, color: Colors.white, size: 18),
              onPressed: () => _handleSubmitted(_controller.text),
            ),
          ),
        ],
      ),
    );
  }
}
