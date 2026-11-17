import 'package:flutter/material.dart';
import 'package:tarot/utils/constants.dart';
import '../models/player_model.dart';
import '../models/card_model.dart';
import '../widgets/card_widget.dart';

/// Widget representing a player's area (deck, tokens, hand)
class PlayerAreaWidget extends StatefulWidget {
  final Player player;
  final int playerIndex; // 0=bottom, 1=left, 2=top, 3=right
  final bool isActive; // Is this player's turn?
  final int? bidTokens; // Number of bid tokens to show
  final int? tricksWon; // Number of tricks won
  final Function(PlayingCard)? onCardPlayed; // Callback when card is played
  final List<Offset> playerPositions; // Positions matching CardShuffleAnimation
  final int roundNumber; // Current round number

  const PlayerAreaWidget({
    super.key,
    required this.player,
    required this.playerIndex,
    required this.playerPositions,
    this.isActive = false,
    this.bidTokens,
    this.tricksWon,
    required this.roundNumber,
    this.onCardPlayed,
  });

  @override
  State<PlayerAreaWidget> createState() => _PlayerAreaWidgetState();
}

class _PlayerAreaWidgetState extends State<PlayerAreaWidget> {
  PlayingCard? _selectedCard;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Lives deck (left side of player area)
        _buildLivesDeck(size),

        // Bid tokens (if bidding phase)
        _buildBidTokens(size),

        // Player hand (cards)
        _buildHand(size),

        // Player name and info
        _buildPlayerInfo(size),
      ],
    );
  }

  Widget _buildLivesDeck(Size screenSize) {
    final position = _getDeckPosition(screenSize);
    final cardSize = getDeckCardSize(screenSize);
    final cardWidth = cardSize['width']!;
    final cardHeight = cardSize['height']!;

    return Positioned(
      left: position.dx - (cardWidth / 2),
      top: position.dy - (cardHeight / 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Deck stack
          SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: Stack(
              children: [
                for (int i = 0; i < widget.player.remainingLives; i++)
                  Positioned(
                    child: CardWidget.family(
                      card: widget.player.familyDeck[i],
                      width: cardWidth,
                      height: cardHeight,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(153),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.player.remainingLives}/14',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidTokens(Size screenSize) {
    final position = _getTokenPosition(screenSize);
    final tokenSize = getTokenSize(screenSize);

    // Don't show anything if bidding hasn't happened yet
    if (widget.bidTokens == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Show transparent token if bid is 0
        if (widget.bidTokens == 0)
          Positioned(
            left: position.dx - tokenSize / 2,
            top: position.dy - tokenSize / 2,
            child: Opacity(
              opacity: 0.3,
              child: Container(
                width: tokenSize,
                height: tokenSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade800,
                  border: Border.all(
                    color: Colors.white.withAlpha(128),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(128),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/token.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.amber.shade700,
                        child: Center(
                          child: Icon(
                            Icons.circle,
                            size: tokenSize * 0.6,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

        // Tokens stacked (for bids > 0)
        if (widget.bidTokens! > 0)
          for (int i = 0; i < widget.bidTokens!; i++)
            Positioned(
              left: position.dx + (i * tokenSize * 0.1) - tokenSize / 2,
              top: position.dy - (i * tokenSize * 0.1) - tokenSize / 2,
              child: Container(
                width: tokenSize,
                height: tokenSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade800,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(128),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/token.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.amber.shade700,
                        child: Center(
                          child: Icon(
                            Icons.circle,
                            size: tokenSize * 0.6,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

        // Bid count text
        Positioned(
          left: position.dx - 15,
          top: position.dy + tokenSize / 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(153),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.tricksWon ?? 0}/${widget.bidTokens}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHand(Size screenSize) {
    // Only show cards for human player (bottom)
    // if (widget.playerIndex != 0 || widget.player.hand.isEmpty) {
    //   return const SizedBox.shrink();
    // }
    if (widget.player.hand.isEmpty) {
      return const SizedBox.shrink();
    }

    final cardWidth = screenSize.width * 0.055;
    final cardHeight = cardWidth * 1.84;
    final cardSpacing = cardWidth * 0.7;

    // Get target position (same as in CardShuffleAnimation)
    final targetPos = _getPlayerPosition(screenSize);

    return Stack(
      children: [
        for (int i = 0; i < widget.player.hand.length; i++)
          Positioned(
            left: widget.playerIndex % 2 == 0
                ? targetPos.dx +
                      (i - (widget.player.hand.length - 1) / 2) * cardSpacing -
                      cardWidth / 2
                : targetPos.dx - cardSpacing - cardWidth / 2,
            top: widget.playerIndex % 2 == 0
                ? targetPos.dy - cardHeight / 2
                : targetPos.dy -
                      (i - (widget.player.hand.length - 1) / 2) * cardSpacing -
                      cardHeight / 2,
            child: GestureDetector(
              onTap: widget.onCardPlayed != null && widget.isActive
                  ? () {
                      setState(() {
                        _selectedCard = widget.player.hand[i];
                      });
                      widget.onCardPlayed!(widget.player.hand[i]);
                    }
                  : null,
              child: MouseRegion(
                cursor: widget.onCardPlayed != null && widget.isActive
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: _selectedCard == widget.player.hand[i]
                      ? (Matrix4.identity()..translate(0.0, -10.0, 0.0))
                      : Matrix4.identity(),
                  child: Transform.rotate(
                    angle: _getCardRotation(i, widget.player.hand.length),
                    child: CardWidget.playing(
                      card: widget.player.hand[i],
                      width: cardWidth,
                      height: cardHeight,
                      faceDown: widget.roundNumber == 5
                          ? widget.playerIndex == 0
                          : widget.playerIndex !=
                                0, //TODO: invert this on round 5
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlayerInfo(Size screenSize) {
    final position = _getNamePosition(screenSize);

    return Positioned(
      left: position.dx - 60,
      top: position.dy - 15,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: widget.isActive
              ? Colors.amber.shade700.withAlpha(230)
              : Colors.black.withAlpha(180),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isActive
                ? Colors.amber.shade900
                : Colors.grey.shade700,
            width: 2,
          ),
        ),
        child: Text(
          widget.player.name,
          style: TextStyle(
            color: widget.isActive ? Colors.black : Colors.white,
            fontSize: 16,
            fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Offset _getPlayerPosition(Size screenSize) {
    final size = MediaQuery.of(context).size;

    // Calculate player positions (same as in CardShuffleAnimation)
    final playerPositions = [
      Offset(size.width * 0.5, size.height * 0.85), // Bottom (human)
      Offset(size.width * 0.10, size.height * 0.4), // Left
      Offset(size.width * 0.5, size.height * 0.15), // Top
      Offset(size.width * 0.98, size.height * 0.6), // Right
    ];

    return playerPositions[widget.playerIndex];
  }

  // rotates all the cards equally to face their player
  double _getCardRotation(int cardIndex, int totalCards) {
    switch (widget.playerIndex) {
      case 0: // Bottom player - no rotation
        return 0.0;
      case 1: // Left player - rotate left
        return -1.57; // -90 degrees in radians
      case 2: // Top player - upside down
        return 3.14; // 180 degrees in radians
      case 3: // Right player - rotate right
        return 1.57; // 90 degrees in radians
      default:
        return 0.0;
    }
  }

  // Position helpers
  Offset _getDeckPosition(Size screenSize) {
    final cardSize = getDeckCardSize(screenSize);
    final cardWidth = cardSize['width']!;
    final cardHeight = cardSize['height']!;

    const edgeMargin = 24.0;

    switch (widget.playerIndex) {
      case 0: // Bottom (human)
        return Offset(
          screenSize.width * 3 / 4,
          screenSize.height - cardHeight / 2 - edgeMargin * 2,
        );
      case 1: // Left
        return Offset(edgeMargin * 2, screenSize.height * 3 / 4);
      case 2: // Top
        return Offset(screenSize.width / 4, cardHeight / 2 + edgeMargin);
      case 3: // Right
        return Offset(
          screenSize.width - cardWidth / 2 - edgeMargin,
          screenSize.height / 4,
        );
      default:
        return Offset(screenSize.width / 2, screenSize.height / 2);
    }
  }

  Offset _getTokenPosition(Size screenSize) {
    final cardSize = getDeckCardSize(screenSize);
    final cardWidth = cardSize['width']!;

    switch (widget.playerIndex) {
      case 0: // Bottom (human) - left side
        return Offset(
          screenSize.width * 3 / 4 - cardWidth * 2,
          screenSize.height * 0.90,
        );
      case 1: // Left - left side (closer to edge)
        return Offset(screenSize.width * 0.10, screenSize.height * 3 / 4 + 48);
      case 2: // Top - left side
        return Offset(screenSize.width / 4 + 80, screenSize.height * 0.16);
      case 3: // Right - left side (from their perspective = left of right area)
        return Offset(screenSize.width * 0.88, screenSize.height / 4);
      default:
        return Offset(screenSize.width * 0.5, screenSize.height * 0.5);
    }
  }

  Offset _getNamePosition(Size screenSize) {
    switch (widget.playerIndex) {
      case 0: // Bottom (human)
        return Offset(screenSize.width * 0.5, screenSize.height * 0.70);
      case 1: // Left
        return Offset(screenSize.width * 0.12, screenSize.height * 0.25);
      case 2: // Top
        return Offset(screenSize.width * 0.5, screenSize.height * 0.08);
      case 3: // Right
        return Offset(screenSize.width * 0.92, screenSize.height * 0.75);
      default:
        return Offset(screenSize.width * 0.5, screenSize.height * 0.5);
    }
  }
}
