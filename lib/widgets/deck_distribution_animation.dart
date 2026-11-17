import 'package:flutter/material.dart';
import 'package:tarot/utils/constants.dart';
import '../models/card_model.dart';
import '../widgets/card_widget.dart';

/// Animation that shows family decks in center, then moves each to player positions
/// Supports 3 or 4 players
class DeckDistributionAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  final List<Map<String, FamilySuit>>
  playerSuits; // Order: bottom, left, top, (right if 4 players)
  final List<int> playerLives; // Current lives for each player
  final int roundNumber; // Current round number

  const DeckDistributionAnimation({
    super.key,
    this.onComplete,
    required this.playerSuits,
    required this.playerLives,
    required this.roundNumber,
  });

  @override
  State<DeckDistributionAnimation> createState() =>
      _DeckDistributionAnimationState();
}

class _DeckDistributionAnimationState extends State<DeckDistributionAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _deckAnimations;
  bool _animationComplete = false;

  int get playerCount => widget.playerSuits.length;

  @override
  void initState() {
    super.initState();

    // If not round 1, skip animation and complete immediately
    if (widget.roundNumber != 1) {
      _animationComplete = true;
      Future.delayed(const Duration(milliseconds: 100), () {
        widget.onComplete?.call();
      });
      return;
    }

    // Main controller for the entire sequence
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Create progress animations (one per deck) - from 0.0 to 1.0
    _deckAnimations = List.generate(playerCount, (index) {
      // Each deck animates in sequence with stagger
      double startTime =
          0.1 + (index * 0.2); // Stagger: 0.1, 0.3, 0.5, (0.7 if 4 players)
      double endTime = startTime + 0.3; // 300ms per deck movement

      return Tween<double>(
        begin: 0.0, // Start at center (0% progress)
        end: 1.0, // End at target (100% progress)
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            startTime,
            endTime.clamp(0.0, 1.0),
            curve: Curves.easeInOutCubic,
          ),
        ),
      );
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _animationComplete = true;
        });
        // Wait a bit before calling onComplete
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.onComplete?.call();
        });
      }
    });

    // Start animation after a brief delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    if (widget.roundNumber == 1) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deckCardSize = getDeckCardSize(size);
    final cardWidth = deckCardSize['width']!;
    final cardHeight = deckCardSize['height']!;
    const scaleFactor = 0.8;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // If not round 1, just show decks in final position without animation
    if (widget.roundNumber != 1) {
      return SizedBox.expand(
        child: Stack(
          children: [
            // Build decks in final position (3 or 4 players)
            for (int deckIndex = 0; deckIndex < playerCount; deckIndex++)
              _buildDeck(
                deckIndex,
                widget.playerSuits
                    .where((i) => i.containsKey(deckIndex.toString()))
                    .first
                    .entries
                    .first
                    .value,
                widget.playerLives[deckIndex],
                cardWidth,
                cardHeight,
                centerX,
                centerY,
                size,
                scaleFactor,
              ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox.expand(
          child: Stack(
            children: [
              // Build decks (3 or 4 players)
              for (int deckIndex = 0; deckIndex < playerCount; deckIndex++)
                _buildDeck(
                  deckIndex,
                  widget.playerSuits
                      .where((i) => i.containsKey(deckIndex.toString()))
                      .first
                      .entries
                      .first
                      .value,
                  widget.playerLives[deckIndex],
                  cardWidth,
                  cardHeight,
                  centerX,
                  centerY,
                  size,
                  scaleFactor,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeck(
    int deckIndex,
    FamilySuit suit,
    int playerLives,
    double cardWidth,
    double cardHeight,
    double centerX,
    double centerY,
    Size screenSize,
    double scaleFactor,
  ) {
    // Use animation value if animating, otherwise stay at final position (1.0)
    final progress = _animationComplete
        ? 1.0
        : _deckAnimations[deckIndex].value;

    // Only render the card corresponding to current lives
    // Lives range from 1-14, which maps directly to card rank
    final cardRank = playerLives.clamp(1, 14);

    // Calculate actual positions
    final centerPosition = Offset(centerX, centerY);
    final targetPosition = _getTargetPosition(deckIndex, screenSize);

    // Interpolate between center and target based on progress (0.0 to 1.0)
    final currentPosition = Offset.lerp(
      centerPosition,
      targetPosition,
      progress,
    )!;

    // Interpolate scale: start at 1.0, end at scaleFactor (0.8)
    // final currentScale = 1.0 - (progress * (1.0 - scaleFactor));

    // Position deck at interpolated position
    return Positioned(
      // left: currentPosition.dx - (totalStackWidth * currentScale / 2),
      // top: currentPosition.dy - (totalStackHeight * currentScale / 2),
      left: currentPosition.dx - (cardWidth / 2),
      top: currentPosition.dy - (cardHeight / 2),
      // child: Transform.scale(
      // scale: currentScale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CardWidget.family(
            card: FamilyCard(suit: suit, rank: cardRank),
            width: cardWidth,
            height: cardHeight,
          ),
          const SizedBox(height: 4),
          if (_animationComplete)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(153),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$playerLives/14',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      // ),
    );
  }

  // Get actual target position in pixels for each player
  // 3 players: Bottom (0), Left (1), Top (2)
  // 4 players: Bottom (0), Left (1), Top (2), Right (3)
  Offset _getTargetPosition(int playerIndex, Size screenSize) {
    final cardSize = getDeckCardSize(screenSize);
    final cardWidth = cardSize['width']!;
    final cardHeight = cardSize['height']!;

    const edgeMargin = 24.0;

    switch (playerIndex) {
      case 0: // Bottom (human) - same for 3 or 4 players
        return Offset(
          screenSize.width * 3 / 4,
          screenSize.height - cardHeight / 2 - edgeMargin * 2,
        );
      case 1: // Left - same for 3 or 4 players
        return Offset(edgeMargin * 2, screenSize.height * 3 / 4);
      case 2: // Top - same for 3 or 4 players
        return Offset(screenSize.width / 4, cardHeight / 2 + edgeMargin);
      case 3: // Right - only for 4 players
        return Offset(
          screenSize.width - cardWidth / 2 - edgeMargin,
          screenSize.height / 4,
        );
      default:
        return Offset(screenSize.width / 2, screenSize.height / 2);
    }
  }
}
