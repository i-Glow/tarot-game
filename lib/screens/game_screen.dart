import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tarot/widgets/center_play_area.dart';
import 'package:tarot/widgets/player_area_widget.dart';
import '../providers/game_provider.dart';
import '../providers/language_provider.dart';
import '../models/game_state.dart';
import '../widgets/deck_distribution_animation.dart';
import '../widgets/card_shuffle_and_distribute_animation.dart';
import '../widgets/bidding_animation.dart';
import '../widgets/bidding_phase_widget.dart';
import '../widgets/vertical_text_animation.dart';
import '../widgets/excuse_value_picker.dart';
import '../models/animation_state.dart';
import '../utils/app_localizations.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  AnimationState _currentAnimationState = AnimationState.showingGameStarted;

  @override
  void initState() {
    super.initState();
    _setFullScreen();
    _startIntroSequence();

    // Set up round end callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = context.read<GameProvider>();
      gameProvider.onRoundEnd = _onRoundEnd;
    });
  }

  /// Set fullscreen mode and hide system overlays
  void _setFullScreen() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  /// Calculate player positions based on player count
  /// 3 players: Bottom (human), Left, Top
  /// 4 players: Bottom (human), Left, Top, Right
  List<Offset> _calculatePlayerPositions(Size size, int playerCount) {
    if (playerCount == 3) {
      return [
        Offset(size.width * 0.5, size.height * 0.85), // Bottom (human)
        Offset(size.width * 0.15, size.height * 0.5), // Left
        Offset(size.width * 0.5, size.height * 0.15), // Top
      ];
    } else {
      // 4 players
      return [
        Offset(size.width * 0.5, size.height * 0.85), // Bottom (human)
        Offset(size.width * 0.15, size.height * 0.5), // Left
        Offset(size.width * 0.5, size.height * 0.15), // Top
        Offset(size.width * 0.85, size.height * 0.5), // Right
      ];
    }
  }

  void _startIntroSequence() {
    // Show "Game Started" for 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentAnimationState = AnimationState.showingRoundNumber;
        });
      }
    });

    // Show "Round Number" for 2 seconds, then start deck animation
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _currentAnimationState = AnimationState.playingLivesDeckDistribution;
        });
      }
    });
  }

  void _onLivesDeckDistributionAnimationComplete() {
    setState(() {
      // Transition to card shuffle animation (decks stay visible)
      _currentAnimationState = AnimationState.playingCardShuffle;
    });
  }

  void _onCardDealingAnimationComplete() {
    // Check if human bids first
    final gameProvider = context.read<GameProvider>();

    if (gameProvider.isHumanTurn && gameProvider.phase == GamePhase.bidding) {
      // Human bids first, skip directly to human bidding
      setState(() {
        _currentAnimationState = AnimationState.waitingForHumanBid;
      });
    } else {
      // AI bids first, trigger AI bidding and show animation
      _triggerAIBidding();
    }
  }

  Future<void> _triggerAIBidding() async {
    // Simply wait for a short moment
    // The AI should bid automatically through the game provider
    // await Future.delayed(const Duration(milliseconds: 500));

    // Once AI bids are done, show the animation
    if (mounted) {
      setState(() {
        _currentAnimationState = AnimationState.playingBiddingAnimation;
      });
    }
  }

  void _onBiddingAnimationComplete() {
    setState(() {
      // Wait for human player to bid
      _currentAnimationState = AnimationState.waitingForHumanBid;
    });
  }

  void _onRoundEnd() {
    // Round has ended, start new round with animations
    if (!mounted) return;

    // After a delay for life loss animation, call continueToNextRound and show round number
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;

      final gameProvider = context.read<GameProvider>();
      gameProvider.continueToNextRound();

      setState(() {
        _currentAnimationState = AnimationState.showingRoundNumber;
      });

      // After showing round number, start card shuffle animation
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _currentAnimationState = AnimationState.playingCardShuffle;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    // Restore system UI when leaving game screen
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  void _showSettingsDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.settings),
            const SizedBox(width: 12),
            Text(loc.translate('settings')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Language selection
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(loc.translate('language')),
              subtitle: Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return Row(
                    children: [
                      _buildLanguageOption(
                        context,
                        flagAsset: 'assets/flags/uk.png',
                        label: 'English',
                        isSelected:
                            languageProvider.locale.languageCode == 'en',
                        onPressed: () {
                          languageProvider.setLocale('en');
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildLanguageOption(
                        context,
                        flagAsset: 'assets/flags/france.png',
                        label: 'Français',
                        isSelected:
                            languageProvider.locale.languageCode == 'fr',
                        onPressed: () {
                          languageProvider.setLocale('fr');
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            const Divider(),
            // Exit to home button
            ListTile(
              leading: const Icon(Icons.home, color: Colors.red),
              title: Text(
                loc.translate('exit_to_home'),
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                _showExitConfirmation(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(loc.translate('close')),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String flagAsset,
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.amber.shade700 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                flagAsset,
                width: 24,
                height: 24,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Colors.amber.shade900
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.translate('exit_game')),
        content: Text(loc.translate('exit_game_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () {
              final gameProvider = context.read<GameProvider>();
              gameProvider.resetGame();
              Navigator.of(dialogContext).pop(); // Close confirmation dialog
              Navigator.of(context).pop(); // Return to home screen
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(loc.translate('exit')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background.jpg', fit: BoxFit.cover),

          // Dark overlay
          Container(color: Colors.black.withAlpha(76)),

          // Deck distribution animation - visible from playingLivesDeckDistribution onwards
          if (_currentAnimationState.index >=
                  AnimationState.playingLivesDeckDistribution.index &&
              _currentAnimationState.index <
                  AnimationState.animationsComplete.index)
            Consumer<GameProvider>(
              builder: (context, game, child) {
                // Get player suits in order: bottom (human), left, top, right
                final playerSuits = game.gameState.players
                    .map((p) => {p.id: p.familySuit})
                    .toList();
                // Get player lives (remaining life points)
                final playerLives = game.gameState.players
                    .map((p) => p.remainingLives)
                    .toList();

                return DeckDistributionAnimation(
                  playerSuits: playerSuits,
                  playerLives: playerLives,
                  roundNumber: game.roundNumber,
                  onComplete: _onLivesDeckDistributionAnimationComplete,
                );
              },
            ),

          // Card shuffle animation - visible from playingCardShuffle onwards
          if (_currentAnimationState.index >=
                  AnimationState.playingCardShuffle.index &&
              _currentAnimationState.index <
                  AnimationState.animationsComplete.index)
            Consumer<GameProvider>(
              builder: (context, game, child) {
                final size = MediaQuery.of(context).size;

                // Calculate player positions based on player count
                final playerPositions = _calculatePlayerPositions(
                  size,
                  game.gameState.playerCount,
                );

                // Get card values for each player (for displaying human player's cards)
                final playerCardValues = game.gameState.players.map((player) {
                  return player.hand.map((card) => card.value).toList();
                }).toList();

                return CardShuffleAndDistributeAnimation(
                  cardsPerPlayer: game.gameState.cardsPerPlayer,
                  playerPositions: playerPositions,
                  playerCardValues: playerCardValues,
                  onComplete: _onCardDealingAnimationComplete,
                );
              },
            ),

          // Bidding animation - visible from playingBiddingAnimation onwards
          if (_currentAnimationState.index >=
                  AnimationState.playingBiddingAnimation.index &&
              _currentAnimationState.index <
                  AnimationState.animationsComplete.index &&
              _currentAnimationState != AnimationState.showingGameStarted &&
              _currentAnimationState != AnimationState.showingRoundNumber)
            Consumer<GameProvider>(
              builder: (context, game, child) {
                return BiddingAnimation(
                  cardsPerPlayer: game.gameState.cardsPerPlayer,
                  bids: game.gameState.bids,
                  onComplete: _onBiddingAnimationComplete,
                );
              },
            ),

          // Human bidding interface - only during waitingForHumanBid
          if (_currentAnimationState == AnimationState.waitingForHumanBid)
            BiddingPhaseWidget(
              onBiddingComplete: () {
                if (mounted) {
                  setState(() {
                    _currentAnimationState = AnimationState.animationsComplete;
                  });
                }
              },
            ),

          // "Game Started" overlay - only during showingGameStarted
          if (_currentAnimationState == AnimationState.showingGameStarted)
            Consumer<GameProvider>(
              builder: (context, game, child) {
                final loc = AppLocalizations.of(context);
                return Container(
                  color: Colors.black.withAlpha(128),
                  child: Center(
                    child: Text(
                      loc.translate('game_started'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),

          // "Round Number" overlay - only during showingRoundNumber
          if (_currentAnimationState == AnimationState.showingRoundNumber)
            Consumer<GameProvider>(
              builder: (context, game, child) {
                final loc = AppLocalizations.of(context);
                return Container(
                  color: Colors.black.withAlpha(128),
                  child: Center(
                    child: Text(
                      '${loc.translate('round')} ${game.gameState.roundNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),

          // Gameplay phase - player areas
          if (_currentAnimationState == AnimationState.animationsComplete)
            Consumer<GameProvider>(
              builder: (context, game, child) {
                final size = MediaQuery.of(context).size;

                // Calculate player positions based on player count
                final playerPositions = _calculatePlayerPositions(
                  size,
                  game.gameState.playerCount,
                );

                return Stack(
                  children: [
                    // Center play area with current trick
                    CenterPlayArea(
                      currentRotation: game.gameState.currentRotation,
                      players: game.gameState.players,
                    ),

                    // Player areas for all players (3 or 4)
                    for (var i = 0; i < game.gameState.players.length; i++)
                      PlayerAreaWidget(
                        player: game.gameState.players[i],
                        playerIndex: i,
                        playerPositions: playerPositions,
                        isActive: game.gameState.currentPlayerIndex == i,
                        bidTokens: game.gameState.players[i].currentBid,
                        tricksWon: game.gameState.players[i].rotationsWon,
                        roundNumber: game.roundNumber,
                        onCardPlayed: game.gameState.players[i].isHuman
                            ? (card) {
                                game.playCard(card);
                              }
                            : null,
                      ),
                  ],
                );
              },
            ),

          // Game End overlay - show when game is over
          Consumer<GameProvider>(
            builder: (context, game, child) {
              if (game.phase != GamePhase.gameEnd) {
                return const SizedBox.shrink();
              }

              final loc = AppLocalizations.of(context);
              // Check if human player won (is still alive)
              final humanPlayer = game.humanPlayer;
              final didWin = humanPlayer.isAlive;

              return Container(
                color: Colors.black.withAlpha(230),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: didWin
                          ? Colors.green.shade900
                          : Colors.red.shade900,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: didWin
                            ? Colors.green.shade400
                            : Colors.red.shade400,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (didWin ? Colors.green : Colors.red).withAlpha(
                            128,
                          ),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          didWin ? Icons.emoji_events : Icons.heart_broken,
                          size: 80,
                          color: didWin ? Colors.yellow : Colors.red.shade200,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          didWin
                              ? loc.translate('victory')
                              : loc.translate('game_over'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withAlpha(128),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          didWin
                              ? loc.translate('survived_all_rounds')
                              : loc.translate('ran_out_of_lives'),
                          style: TextStyle(
                            color: Colors.white.withAlpha(230),
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            game.resetGame();
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.home, size: 28),
                          label: Text(
                            loc.translate('back_to_home'),
                            style: const TextStyle(fontSize: 24),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 36,
                              vertical: 12,
                            ),
                            backgroundColor: Colors.white,
                            foregroundColor: didWin
                                ? Colors.green.shade900
                                : Colors.red.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Rotation winner animation - show who won the rotation
          Consumer<GameProvider>(
            builder: (context, game, child) {
              if (game.rotationWinnerName == null) {
                return const SizedBox.shrink();
              }

              final loc = AppLocalizations.of(context);
              final isHumanWinner = game.rotationWinnerName == 'You';

              return VerticalTextAnimation(
                text:
                    '${isHumanWinner ? loc.translate('you') : game.rotationWinnerName} ${isHumanWinner ? loc.translate('got_trick_human') : loc.translate('got_trick')}',
                textStyle: TextStyle(
                  color: isHumanWinner ? Colors.yellow : Colors.blue.shade300,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withAlpha(200),
                      offset: const Offset(3, 3),
                      blurRadius: 8,
                    ),
                    Shadow(
                      color: (isHumanWinner ? Colors.orange : Colors.blue)
                          .withAlpha(150),
                      offset: const Offset(0, 0),
                      blurRadius: 20,
                    ),
                  ],
                ),
                duration: const Duration(seconds: 2),
              );
            },
          ),

          // Life loss animation - show at end of round
          Consumer<GameProvider>(
            builder: (context, game, child) {
              final lifeLoss = game.humanLifeLoss;

              if (lifeLoss == null) {
                return const SizedBox.shrink();
              }

              final loc = AppLocalizations.of(context);
              String message;
              Color textColor;
              Color glowColor;

              if (lifeLoss == 0) {
                message = loc.translate('perfect');
                textColor = Colors.green;
                glowColor = Colors.greenAccent;
              } else if (lifeLoss == 1) {
                message = loc.translate('lost_one_life');
                textColor = Colors.orange;
                glowColor = Colors.orangeAccent;
              } else {
                message = loc.translate(
                  'lost_lives',
                  params: {'count': '$lifeLoss'},
                );
                textColor = Colors.red;
                glowColor = Colors.redAccent;
              }

              return VerticalTextAnimation(
                text: message,
                textStyle: TextStyle(
                  color: textColor,
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withAlpha(200),
                      offset: const Offset(4, 4),
                      blurRadius: 10,
                    ),
                    Shadow(
                      color: glowColor.withAlpha(200),
                      offset: const Offset(0, 0),
                      blurRadius: 30,
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 2500),
              );
            },
          ),

          // Excuse value picker - show when player plays excuse card
          Consumer<GameProvider>(
            builder: (context, game, child) {
              if (game.excuseCardPendingValue == null) {
                return const SizedBox.shrink();
              }

              return ExcuseValuePicker(
                onValueSelected: (value) {
                  game.setExcuseValueAndPlay(value);
                },
              );
            },
          ),
          // Settings icon in top-right corner
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.amber.shade300,
                    Colors.amber.shade600,
                    Colors.amber.shade800,
                  ],
                ),
                border: Border.all(color: Colors.amber.shade900, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.shade700.withAlpha(100),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.black.withAlpha(128),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () => _showSettingsDialog(context),
                  customBorder: const CircleBorder(),
                  splashColor: Colors.amber.shade100,
                  child: const Center(
                    child: Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 28,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
