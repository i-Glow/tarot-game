import 'package:flutter/material.dart';
import '../models/card_model.dart';

/// Widget to display a single card (playing or family card)
class CardWidget extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final bool faceDown;
  final VoidCallback? onTap;

  const CardWidget({
    super.key,
    required this.assetPath,
    this.width = 80,
    this.height = 120,
    this.faceDown = false,
    this.onTap,
  });

  /// Factory for displaying a playing card
  factory CardWidget.playing({
    required PlayingCard card,
    double width = 80,
    double height = 120,
    bool faceDown = false,
    VoidCallback? onTap,
  }) {
    return CardWidget(
      assetPath: card.assetPath,
      width: width,
      height: height,
      faceDown: faceDown,
      onTap: onTap,
    );
  }

  /// Factory for displaying a family card
  factory CardWidget.family({
    required FamilyCard card,
    double width = 80,
    double height = 120,
    bool faceDown = false,
    VoidCallback? onTap,
  }) {
    return CardWidget(
      assetPath: card.assetPath,
      width: width,
      height: height,
      faceDown: faceDown,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(76),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: faceDown
              ? Container(
                  color: Colors.red.shade900,
                  child: Center(
                    child: Icon(
                      Icons.style,
                      size: width * 0.5,
                      color: Colors.white.withAlpha(76),
                    ),
                  ),
                )
              : Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          size: width * 0.5,
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
