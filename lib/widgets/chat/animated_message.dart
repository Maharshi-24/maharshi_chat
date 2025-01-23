import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import '../../../utils/message_parser.dart';

class AnimatedMessage extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isFirstMessage; // For user messages only

  const AnimatedMessage({
    super.key,
    required this.message,
    required this.isUser,
    required this.isFirstMessage,
  });

  void _showMessageOptions(BuildContext context, Offset tapPosition) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final messagePosition = renderBox.localToGlobal(Offset.zero);

    // Declare the overlayEntry variable
    late OverlayEntry overlayEntry;

    // Initialize the overlayEntry
    overlayEntry = OverlayEntry(
      builder: (context) =>
          GestureDetector(
            // Close the overlay when tapping anywhere on the screen
            onTap: () {
              overlayEntry.remove();
            },
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  // Transparent background to capture taps
                  Positioned.fill(
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                  // Floating container with options
                  Positioned(
                    right: isUser ? 16 : null,
                    // Align to the right for user messages
                    left: isUser ? null : 16,
                    // Align to the left for AI messages
                    top: isUser
                        ? (isFirstMessage
                        ? messagePosition.dy + renderBox.size.height +
                        10 // Below the bubble for the first user message
                        : messagePosition.dy -
                        100) // Above the bubble for other user messages
                        : tapPosition.dy - 50,
                    // Near the long press location for AI messages
                    child: Material(
                      color: Colors.transparent,
                      // Ensure the Material widget is transparent
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF141414),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isUser) // Show all options for user messages
                              _buildOptionButton(
                                icon: Icons.content_copy_outlined,
                                label: 'Copy',
                                onTap: () {
                                  // Copy the message to clipboard
                                  Clipboard.setData(
                                      ClipboardData(text: message));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Copied to clipboard')),
                                  );
                                  overlayEntry.remove(); // Close the overlay
                                },
                              ),
                            if (isUser) // Show all options for user messages
                              const SizedBox(height: 12),
                            if (isUser) // Show all options for user messages
                              _buildOptionButton(
                                icon: Icons.text_snippet_outlined,
                                label: 'Select Text',
                                onTap: () {
                                  // Implement text selection logic
                                  overlayEntry.remove(); // Close the overlay
                                },
                              ),
                            if (isUser) // Show all options for user messages
                              const SizedBox(height: 12),
                            if (isUser) // Show all options for user messages
                              _buildOptionButton(
                                icon: Icons.edit_outlined,
                                label: 'Edit Message',
                                onTap: () {
                                  // Implement message editing logic
                                  overlayEntry.remove(); // Close the overlay
                                },
                              ),
                            if (!isUser) // Show only Copy and Select Text for AI messages
                              _buildOptionButton(
                                icon: Icons.content_copy_outlined,
                                label: 'Copy',
                                onTap: () {
                                  // Copy the message to clipboard
                                  Clipboard.setData(
                                      ClipboardData(text: message));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Copied to clipboard')),
                                  );
                                  overlayEntry.remove(); // Close the overlay
                                },
                              ),
                            if (!isUser) // Show only Copy and Select Text for AI messages
                              const SizedBox(height: 12),
                            if (!isUser) // Show only Copy and Select Text for AI messages
                              _buildOptionButton(
                                icon: Icons.text_snippet_outlined,
                                label: 'Select Text',
                                onTap: () {
                                  // Implement text selection logic
                                  overlayEntry.remove(); // Close the overlay
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    // Insert the overlay into the overlay stack
    Overlay.of(context).insert(overlayEntry);
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent, // Ensure the Material widget is transparent
      child: InkWell(
        onTap: onTap, // Handle the tap event
        splashColor: Colors.grey.withOpacity(1),
        borderRadius: BorderRadius.circular(8), // Ripple effect boundary
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: isUser ? 1.0 : -1.0,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onLongPress: () {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final tapPosition = renderBox.localToGlobal(Offset.zero);
          _showMessageOptions(context, tapPosition);
        },
        child: Padding(
          key: ValueKey(message),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                // Handle the tap event here
                print("Message tapped: $message");
              },
              borderRadius: BorderRadius.circular(16), // Ripple effect boundary
              splashColor: Colors.grey.withOpacity(0.5), // Ripple color
              child: isUser
                  ? Container(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: MessageParser.parse(message, context),
              )
                  : Container(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(
                      16), // Match the borderRadius
                ),
                child: MessageParser.parse(message, context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}