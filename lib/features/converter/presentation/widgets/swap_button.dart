import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Floating circular swap button with smooth 180-degree rotation animation,
/// 38x38 size, active theme gradient (Neon Pink to Bright Violet), radiant glow, and white swap_vert icon.
class SwapButton extends StatefulWidget {
  final VoidCallback onTap;
  final double size;

  const SwapButton({
    super.key,
    required this.onTap,
    this.size = 38.0,
  });

  @override
  State<SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<SwapButton> {
  double _turns = 0.0;

  void _handleTap() {
    HapticFeedback.lightImpact();
    setState(() {
      _turns += 0.5;
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: _turns,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEC4899), // Neon Pink
              Color(0xFF8B5CF6), // Bright Violet / Purple
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC4899).withValues(alpha: 0.4),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleTap,
            customBorder: const CircleBorder(),
            child: const Center(
              child: Icon(
                Icons.swap_vert_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
