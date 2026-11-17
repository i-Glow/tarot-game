import 'package:flutter/material.dart';
import 'package:tarot/utils/constants.dart';
import '../utils/app_localizations.dart';

/// Animation that shows bidding tokens moving to players
/// Supports 3 or 4 players
class BiddingAnimation extends StatefulWidget {
  final int cardsPerPlayer; // Number of cards this round
  final List<int> bids; // Bids made by each player (3 or 4 players)
  final VoidCallback onComplete;

  const BiddingAnimation({
    super.key,
    required this.cardsPerPlayer,
    required this.bids,
    required this.onComplete,
  });

  @override
  State<BiddingAnimation> createState() => _BiddingAnimationState();
}

class _BiddingAnimationState extends State<BiddingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  int get playerCount => widget.bids.length;

  @override
  void initState() {
    super.initState();

    // Duration: 800ms to show tokens in center, then 1200ms to move them
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Render tokens for each player (3 or 4 players)
            for (int playerIndex = 0; playerIndex < playerCount; playerIndex++)
              _buildPlayerBidTokens(playerIndex, size),
          ],
        );
      },
    );
  }

  Widget _buildPlayerBidTokens(int playerIndex, Size screenSize) {
    final bid = widget.bids[playerIndex];

    // Calculate positions
    final centerPos = Offset(screenSize.width * 0.5, screenSize.height * 0.5);
    final targetPos = _getPlayerTokenPosition(playerIndex, screenSize);

    // Animation phases: 0-0.4 = appear in center, 0.4-1.0 = move to player
    final appearProgress = (_controller.value / 0.4).clamp(0.0, 1.0);
    final moveProgress = ((_controller.value - 0.4) / 0.6).clamp(0.0, 1.0);

    // Interpolate position
    final currentPos = Offset.lerp(centerPos, targetPos, moveProgress)!;

    final tokenSize = screenSize.width * 0.04;
    final showText = moveProgress >= 1.0; // Show text when animation complete

    return Stack(
      children: [
        // shows when a player has not yet bid
        if (bid == -1)
          Positioned(
            left: targetPos.dx - tokenSize / 2,
            top: targetPos.dy - tokenSize / 2,
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

        if (bid == 0)
          Positioned(
            left: targetPos.dx - tokenSize / 2,
            top: targetPos.dy - tokenSize / 2,
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

        // Tokens
        for (int i = 0; i < bid; i++)
          _buildToken(
            currentPos,
            tokenSize,
            i,
            appearProgress * moveProgress.clamp(0.5, 1.0),
          ),

        // Bid text (shown after animation completes)
        if (showText) _buildBidText(targetPos, bid, playerIndex, screenSize),
      ],
    );
  }

  Widget _buildToken(
    Offset position,
    double tokenSize,
    int index,
    double opacity,
  ) {
    // Stack tokens with slight offset
    final offset = Offset(index * tokenSize * 0.1, -index * tokenSize * 0.1);

    return Positioned(
      left: position.dx + offset.dx - tokenSize / 1.5,
      top: position.dy + offset.dy - tokenSize / 2,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: opacity * 0.5 + 0.5,
          child: Container(
            width: tokenSize,
            height: tokenSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade800,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(128),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
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
    );
  }

  Widget _buildBidText(
    Offset position,
    int bid,
    int playerIndex,
    Size screenSize,
  ) {
    // Position text below/beside tokens depending on player position
    Offset textOffset = Offset(0, screenSize.height * 0.08);
    final loc = AppLocalizations.of(context);

    return Positioned(
      left: position.dx + textOffset.dx - 30,
      top: position.dy + textOffset.dy - 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(153),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          bid == -1 ? loc.translate('to_bid') : '0/$bid',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Get target position for player's tokens (left side of player area)
  Offset _getPlayerTokenPosition(int playerIndex, Size screenSize) {
    switch (playerIndex) {
      case 0: // Bottom (human) - left side
        return Offset(
          screenSize.width * 3 / 4 - getTokenSize(screenSize) * 2,
          screenSize.height * 0.90,
        );
      case 1: // Left - left side (closer to edge)
        return Offset(screenSize.width * 0.10, screenSize.height * 3 / 4 + 48);
      case 2: // Top - left side
        return Offset(
          screenSize.width / 4 + getTokenSize(screenSize),
          screenSize.height * 0.16,
        );
      case 3: // Right - left side (from their perspective = left of right area)
        return Offset(screenSize.width * 0.90, screenSize.height / 4 + 48);
      default:
        return Offset(screenSize.width * 0.5, screenSize.height * 0.5);
    }
  }
}
