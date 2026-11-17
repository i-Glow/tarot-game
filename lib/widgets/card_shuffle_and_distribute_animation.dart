import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tarot/utils/constants.dart';
import '../models/card_model.dart';
import '../widgets/card_widget.dart';

/// Represents a card being dealt to a player
class _DealingCard {
  final int playerIndex;
  final int cardIndex; // Which card in the hand (0, 1, 2, etc.)
  final double delay; // Delay before starting animation

  _DealingCard({
    required this.playerIndex,
    required this.cardIndex,
    required this.delay,
  });
}

/// Animation that shows a deck of cards rising from bottom and shuffling
class CardShuffleAndDistributeAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  final int cardsPerPlayer; // Number of cards to deal to each player
  final List<Offset> playerPositions; // Target positions for each player
  final List<List<int>>?
  playerCardValues; // Optional: actual card values for each player (for showing real cards)

  const CardShuffleAndDistributeAnimation({
    super.key,
    this.onComplete,
    required this.cardsPerPlayer,
    required this.playerPositions,
    this.playerCardValues,
  });

  @override
  State<CardShuffleAndDistributeAnimation> createState() =>
      _CardShuffleAndDistributeAnimationState();
}

class _CardShuffleAndDistributeAnimationState
    extends State<CardShuffleAndDistributeAnimation>
    with TickerProviderStateMixin {
  late AnimationController _riseController;
  late AnimationController _shuffleController;
  late AnimationController _dealController;
  late Animation<double> _riseAnimation;

  final int _numCards = 9; // Number of cards to show in animation
  final List<double> _cardOffsets = [];
  final List<double> _cardRotations = [];

  // Dealing animation state
  bool _isDealing = false;
  late List<List<_DealingCard>> _dealtCards; // Cards for each player

  @override
  void initState() {
    super.initState();

    // Initialize _dealtCards based on player count
    _dealtCards = List.generate(
      widget.playerPositions.length,
      (index) => <_DealingCard>[],
    );

    // Initialize random positions for cards
    for (int i = 0; i < _numCards; i++) {
      _cardOffsets.add(0.0);
      _cardRotations.add(0.0);
    }

    // Controller for rising from bottom
    _riseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _riseAnimation =
        Tween<double>(
          begin: 1.5, // Start below screen
          end: 0.0, // End at center
        ).animate(
          CurvedAnimation(parent: _riseController, curve: Curves.easeOutCubic),
        );

    // Controller for shuffling effect
    _shuffleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Controller for dealing cards
    _dealController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 100 * widget.cardsPerPlayer * 5,
      ), // 100ms per card
    );

    _riseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Start shuffling after rise completes
        _startShuffling();
      }
    });

    _shuffleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Start dealing after shuffle completes
        _startDealing();
      }
    });

    _dealController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Animation complete
        Future.delayed(const Duration(milliseconds: 300), () {
          widget.onComplete?.call();
        });
      }
    });

    // Start the animation sequence
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _riseController.forward();
    });
  }

  void _startShuffling() {
    // Create shuffle animation with listener to update card positions
    _shuffleController.addListener(() {
      if (mounted) {
        setState(() {
          for (int i = 0; i < _numCards; i++) {
            // Create wave-like shuffle motion
            final shuffleProgress = _shuffleController.value;
            final cardPhase = (i / _numCards) * 2 * math.pi;

            // Cards spread out and come back together
            final spreadAmount = math.sin(shuffleProgress * math.pi) * 80.0;
            _cardOffsets[i] =
                math.sin(cardPhase + shuffleProgress * 4) * spreadAmount;

            // Cards rotate during shuffle
            _cardRotations[i] = math.sin(cardPhase + shuffleProgress * 6) * 0.3;
          }
        });
      }
    });

    _shuffleController.forward();
  }

  void _startDealing() {
    setState(() {
      _isDealing = true;
    });

    // Generate dealing card list - deal one card to each player in rotation
    final int playerCount = widget.playerPositions.length;
    int totalCards = widget.cardsPerPlayer * playerCount;
    double delayPerCard = 0.1; // 100ms between cards

    for (int i = 0; i < totalCards; i++) {
      int playerIndex = i % playerCount; // Rotate through players
      int cardIndex = i ~/ playerCount; // Which card in the player's hand

      _dealtCards[playerIndex].add(
        _DealingCard(
          playerIndex: playerIndex,
          cardIndex: cardIndex,
          delay: i * delayPerCard,
        ),
      );
    }

    _dealController.forward();
  }

  @override
  void dispose() {
    _riseController.dispose();
    _shuffleController.dispose();
    _dealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final playerCardSize = getPlayerCardSize(size);
    final cardWidth = playerCardSize['width']!;
    final cardHeight = playerCardSize['height']!;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _riseController,
        _shuffleController,
        _dealController,
      ]),
      builder: (context, child) {
        final riseOffset = _riseAnimation.value * size.height;

        return Stack(
          children: [
            // Build shuffle deck (visible during rise and shuffle, fades during dealing)
            if (!_isDealing || _dealController.value < 0.3)
              for (int i = 0; i < _numCards; i++)
                Positioned(
                  left: centerX - cardWidth / 2 + _cardOffsets[i],
                  top: centerY - cardHeight / 2 + riseOffset - (i * 2.0),
                  child: Transform.rotate(
                    angle: _cardRotations[i],
                    child: Opacity(
                      // Fade for depth during animation, full opacity at end
                      opacity: _isDealing
                          ? (1.0 - (_dealController.value / 0.3)).clamp(
                              0.0,
                              1.0,
                            )
                          : (_shuffleController.status ==
                                    AnimationStatus.completed
                                ? 1.0
                                : 0.9 - (i * 0.05)),
                      child: Container(
                        width: cardWidth,
                        height: cardHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.shade700,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(76),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.style,
                            size: cardWidth * 0.6,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

            // Build dealt cards
            if (_isDealing)
              for (
                int playerIndex = 0;
                playerIndex < widget.playerPositions.length;
                playerIndex++
              )
                for (var dealingCard in _dealtCards[playerIndex])
                  _buildDealingCard(
                    dealingCard,
                    centerX,
                    centerY,
                    cardWidth,
                    cardHeight,
                    size,
                    playerIndex,
                  ),
          ],
        );
      },
    );
  }

  Widget _buildDealingCard(
    _DealingCard dealingCard,
    double centerX,
    double centerY,
    double cardWidth,
    double cardHeight,
    Size screenSize,
    int playerIndex,
  ) {
    // Calculate progress for this specific card
    final cardStartTime = dealingCard.delay;
    final cardDuration = 0.5; // Each card takes 500ms to reach destination
    final totalTime = _dealController.duration!.inMilliseconds / 1000.0;

    final currentTime = _dealController.value * totalTime;
    final cardProgress = ((currentTime - cardStartTime) / cardDuration).clamp(
      0.0,
      1.0,
    );

    // Get target position for this player
    final targetPos = widget.playerPositions[dealingCard.playerIndex];

    // Add card spread offset within player's hand
    final cardSpacing = cardWidth * 0.7;
    final cardOffset =
        (dealingCard.cardIndex - (widget.cardsPerPlayer - 1) / 2) * cardSpacing;

    final targetX = targetPos.dx + cardOffset;
    final targetY = targetPos.dy;

    // Interpolate position
    final currentX = centerX + (targetX - centerX) * cardProgress;
    final currentY = centerY + (targetY - centerY) * cardProgress;

    // Check if this is the human player (index 0) and animation is complete
    final isHumanPlayer = dealingCard.playerIndex == 0;
    final isAnimationComplete = cardProgress >= 1.0;
    final shouldShowRealCard = isHumanPlayer && isAnimationComplete;
    // &&
    // widget.playerCardValues != null &&
    // widget.playerCardValues!.isNotEmpty &&
    // dealingCard.cardIndex < widget.playerCardValues![0].length;

    // Get the actual card value if available
    final cardValue =
        widget.playerCardValues![playerIndex][dealingCard.cardIndex];

    return Positioned(
      left: currentX - cardWidth / 2,
      top: currentY - cardHeight / 2,
      child: Opacity(
        opacity: cardProgress > 0.0 ? 1.0 : 0.0, // Appear when animation starts
        // shouldShowRealCard
        //     ? CardWidget.playing(
        //         card: cardValue == 0
        //             ? PlayingCard.excuse()
        //             : PlayingCard.trump(cardValue),
        //         width: cardWidth,
        //         height: cardHeight,
        //       )
        //     :
        child: CardWidget.playing(
          card: cardValue == 0
              ? PlayingCard.excuse()
              : PlayingCard.trump(cardValue),
          width: cardWidth,
          height: cardHeight,
          faceDown: widget.cardsPerPlayer == 1
              ? widget.cardsPerPlayer == 1 && isHumanPlayer
              : !shouldShowRealCard,
        ),
      ),
    );
  }
}
