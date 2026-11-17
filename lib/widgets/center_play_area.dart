import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../models/player_model.dart';
import '../models/trick_model.dart';
import '../widgets/card_widget.dart';

/// Widget for the center play area where cards are played
class CenterPlayArea extends StatelessWidget {
  final Rotation? currentRotation;
  final List<Player> players;

  const CenterPlayArea({
    super.key,
    required this.currentRotation,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    if (currentRotation == null || currentRotation!.cardsPlayed.isEmpty) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;

    return Stack(
      children: [
        // Show each played card
        for (var playedCard in currentRotation!.cardsPlayed)
          _buildPlayedCard(
            playedCard.player,
            playedCard.card,
            centerX,
            centerY,
            size,
          ),
      ],
    );
  }

  Widget _buildPlayedCard(
    Player player,
    PlayingCard card,
    double centerX,
    double centerY,
    Size screenSize,
  ) {
    final playerIndex = players.indexWhere((p) => p.id == player.id);
    final position = _getCardPosition(
      playerIndex,
      centerX,
      centerY,
      screenSize,
    );
    final cardWidth = screenSize.width * 0.055;
    final cardHeight = cardWidth * 1.84;

    return Positioned(
      left: position.dx - cardWidth / 2,
      top: position.dy - cardHeight / 2,
      child: CardWidget.playing(
        card: card,
        width: cardWidth,
        height: cardHeight,
      ),
    );
  }

  Offset _getCardPosition(
    int playerIndex,
    double centerX,
    double centerY,
    Size screenSize,
  ) {
    final offset = screenSize.width * 0.04;

    switch (playerIndex) {
      case 0: // Bottom (human)
        return Offset(centerX, centerY + offset);
      case 1: // Left
        return Offset(centerX - offset, centerY);
      case 2: // Top
        return Offset(centerX, centerY - offset);
      case 3: // Right
        return Offset(centerX + offset, centerY);
      default:
        return Offset(centerX, centerY);
    }
  }
}
