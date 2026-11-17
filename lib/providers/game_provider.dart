import 'package:flutter/foundation.dart';
import '../models/card_model.dart';
import '../models/player_model.dart';
import '../models/game_state.dart';
import '../models/trick_model.dart';
import '../game/game_engine.dart';
import '../game/ai_player.dart';

/// Provider that manages game state and notifies UI of changes
class GameProvider extends ChangeNotifier {
  late GameEngine engine;
  late AIPlayer ai;

  bool _isProcessing = false;
  String _statusMessage = '';
  String? _rotationWinnerName;
  int? _humanLifeLoss; // Track life loss for animation
  PlayingCard?
  _excuseCardPendingValue; // Card waiting for excuse value selection

  // Callback for when round ends (UI should show animations then call continueToNextRound)
  VoidCallback? onRoundEnd;

  GameProvider();

  // ========== Getters ==========

  GameState get gameState => engine.gameState;
  GamePhase get phase => gameState.phase;
  int get roundNumber => gameState.roundNumber;
  int get cardsPerPlayer => gameState.cardsPerPlayer;
  bool get isProcessing => _isProcessing;
  String get statusMessage => _statusMessage;
  String? get rotationWinnerName => _rotationWinnerName;
  int? get humanLifeLoss => _humanLifeLoss;
  PlayingCard? get excuseCardPendingValue => _excuseCardPendingValue;

  Player get humanPlayer => gameState.players.firstWhere((p) => p.isHuman);
  List<Player> get aiPlayers =>
      gameState.players.where((p) => !p.isHuman).toList();
  Player get currentPlayer => gameState.currentPlayer;
  Player get dealer => gameState.players[gameState.dealerIndex];

  bool get isHumanTurn {
    if (phase == GamePhase.bidding) {
      return gameState.biddingPlayer.isHuman;
    } else {
      return currentPlayer.isHuman;
    }
  }

  bool get isAITurn => !isHumanTurn;

  List<PlayingCard> get myHand => humanPlayer.hand;
  int get myLives => humanPlayer.remainingLives;
  int get myBid => humanPlayer.currentBid;
  int get myWins => humanPlayer.rotationsWon;

  List<int> get validBids => engine.getValidBids();
  String get roundSummary => engine.getRoundSummary();
  String get gameSummary => engine.getGameSummary();

  // Gets the current bidding player (for UI display)
  Player get currentBiddingPlayer => gameState.biddingPlayer;

  // Gets bidding order for display
  List<Player> get biddingOrder {
    List<Player> order = [];
    for (int i = 0; i < gameState.playerCount; i++) {
      int playerIndex = (gameState.dealerIndex + 2 + i) % gameState.playerCount;
      order.add(gameState.players[playerIndex]);
    }
    return order;
  }

  // ========== Initialization ==========

  void initializeGame({
    String difficulty = 'medium',
    int startingLives = 14,
    int playerCount = 4,
  }) {
    assert(playerCount == 3 || playerCount == 4, 'Must have 3 or 4 players');

    // Create players based on player count
    List<Player> players = [
      Player(
        id: '0',
        name: 'You',
        familySuit: FamilySuit.hearts,
        isHuman: true,
        startingLives: startingLives,
      ),
      Player(
        id: '1',
        name: 'BOT-1',
        familySuit: FamilySuit.clubs,
        startingLives: startingLives,
      ),
      Player(
        id: '2',
        name: 'BOT-2',
        familySuit: FamilySuit.diamonds,
        startingLives: startingLives,
      ),
    ];

    // Add 4th player only if playerCount is 4
    if (playerCount == 4) {
      players.add(
        Player(
          id: '3',
          name: 'BOT-3',
          familySuit: FamilySuit.spades,
          startingLives: startingLives,
        ),
      );
    }

    // Create game state and engine
    GameState state = GameState(players: players);
    engine = GameEngine(gameState: state);

    // Set AI difficulty based on selection
    AIDifficulty aiDifficulty;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        aiDifficulty = AIDifficulty.easy;
        break;
      case 'hard':
        aiDifficulty = AIDifficulty.hard;
        break;
      case 'medium':
      default:
        aiDifficulty = AIDifficulty.medium;
        break;
    }

    ai = AIPlayer(difficulty: aiDifficulty);

    // Initialize game
    engine.initializeGame();

    // Start AI turns if AI goes first
    _checkAndExecuteAITurns();
  }

  // ========== Game Actions ==========

  /// Submit a bid (human player)
  Future<void> submitBid(int bid) async {
    // Check if it's actually the human's turn to bid
    if (phase != GamePhase.bidding) {
      return;
    }

    if (!isHumanTurn) {
      return;
    }

    _setStatus('You bid: $bid');

    if (engine.submitBid(bid)) {
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));
      await _checkAndExecuteAITurns();
    } else {
      _setStatus('Invalid bid!');
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    _clearStatus();
  }

  /// Play a card (human player)
  Future<void> playCard(PlayingCard card) async {
    if (!isHumanTurn || phase != GamePhase.playing) return;
    if (_isProcessing) return;

    _setStatus('Playing $card');

    // Handle Excuse value selection
    if (card.isExcuse && card.excuseChosenValue == null) {
      // Store the card and wait for UI to show picker
      _excuseCardPendingValue = card;
      notifyListeners();
      return;
    }

    // Check if this will complete the rotation before playing
    // We check if cards played equals playerCount - 1 (before this card is added)
    bool willCompleteRotation =
        gameState.currentRotation != null &&
        gameState.currentRotation!.cardsPlayed.length ==
            gameState.playerCount - 1;

    if (engine.playCard(card)) {
      notifyListeners();

      // Small delay to show card animation
      await Future.delayed(const Duration(milliseconds: 500));

      // If rotation was just completed, show winner and handle round end
      if (willCompleteRotation) {
        // Extra delay to view all 4 cards on the table
        // await Future.delayed(const Duration(milliseconds: 2000));

        await _handleRotationComplete();
      }

      await _checkAndExecuteAITurns();
    }

    _clearStatus();
  }

  /// Sets the excuse value and continues playing
  Future<void> setExcuseValueAndPlay(int value) async {
    if (_excuseCardPendingValue == null) return;

    _excuseCardPendingValue!.setExcuseValue(value);
    PlayingCard cardToPlay = _excuseCardPendingValue!;
    _excuseCardPendingValue = null;
    notifyListeners();

    // Now play the card with the chosen value
    await playCard(cardToPlay);
  }

  /// Continue to next round after round end
  Future<void> continueToNextRound() async {
    if (phase != GamePhase.roundEnd) return;

    _setStatus('Starting new round...');

    // Clear life loss animation
    _humanLifeLoss = null;

    engine.startNewRound();
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    await _checkAndExecuteAITurns();

    _clearStatus();
  }

  /// Reset the game
  void resetGame() {
    _setStatus('Resetting game...');
    engine.resetGame();
    notifyListeners();
    _checkAndExecuteAITurns();
    _clearStatus();
  }

  // ========== AI Management ==========

  /// Check if it's AI turn and execute AI actions
  Future<void> _checkAndExecuteAITurns() async {
    while (isAITurn && !_isProcessing) {
      if (phase == GamePhase.bidding) {
        await _executeAIBid();
      } else if (phase == GamePhase.playing) {
        await _executeAIPlay();
      } else {
        break;
      }
    }
  }

  /// Execute AI bid
  Future<void> _executeAIBid() async {
    if (phase != GamePhase.bidding) return;

    _isProcessing = true;
    notifyListeners();

    // AI thinking delay
    // await Future.delayed(const Duration(milliseconds: 500));

    Player aiPlayer = currentBiddingPlayer;
    List<int> valid = engine.getValidBids();
    int bid = ai.chooseBid(aiPlayer, gameState, valid);

    _setStatus('${aiPlayer.name} bids: $bid');

    engine.submitBid(bid);
    notifyListeners();

    _isProcessing = false;
    _clearStatus();
    notifyListeners();
  }

  /// Execute AI card play
  Future<void> _executeAIPlay() async {
    if (phase != GamePhase.playing) return;

    _isProcessing = true;
    notifyListeners();

    // AI thinking delay
    await Future.delayed(const Duration(milliseconds: 1000));

    Player aiPlayer = currentPlayer;
    PlayingCard card = ai.chooseCard(aiPlayer, gameState);

    // Handle Excuse
    if (card.isExcuse && card.excuseChosenValue == null) {
      int value = ai.chooseExcuseValue(
        aiPlayer,
        gameState,
        gameState.currentRotation?.cardsPlayed ?? [],
      );
      card.setExcuseValue(value);
    }

    _setStatus('${aiPlayer.name} plays $card');

    // Check if this will complete the rotation before playing
    // We check if cards played equals playerCount - 1 (before this card is added)
    bool willCompleteRotation =
        gameState.currentRotation != null &&
        gameState.currentRotation!.cardsPlayed.length ==
            gameState.playerCount - 1;

    engine.playCard(card);
    // If rotation was just completed, show winner and handle round end
    if (willCompleteRotation) {
      // Extra delay to view all 4 cards on the table
      await Future.delayed(const Duration(milliseconds: 1000));

      await _handleRotationComplete();
    }
    notifyListeners();

    _isProcessing = false;
    _clearStatus();
    notifyListeners();
  }

  /// Handle rotation completion - show winner and check for round end
  Future<void> _handleRotationComplete() async {
    engine.completeRotation();

    Rotation lastRotation = gameState.completedRotations.last;
    Player winner = lastRotation.determineWinner();

    // Set winner name to trigger animation
    _rotationWinnerName = winner.name;

    _setStatus('${winner.name} wins the rotation!');
    notifyListeners();

    // prev: 1500, we can use this delay to show winner
    await Future.delayed(const Duration(milliseconds: 2500));

    // Clear the winner name
    _rotationWinnerName = null;

    // Check if round is over (engine.completeRotation already handled the logic)
    if (gameState.phase == GamePhase.roundEnd) {
      // Calculate life loss for human player
      final human = humanPlayer;
      final difference = (human.currentBid - human.rotationsWon).abs();
      _humanLifeLoss = difference;

      _setStatus('Round ${gameState.roundNumber} complete!');
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));

      // Trigger UI callback to show animations
      if (onRoundEnd != null) {
        onRoundEnd!();
      }
      return; // Don't clear status or continue, let UI handle next steps
    }

    _clearStatus();
    notifyListeners();
  }

  // ========== Helpers ==========
  void _setStatus(String message) {
    _statusMessage = message;
    notifyListeners();
  }

  void _clearStatus() {
    _statusMessage = '';
    notifyListeners();
  }

  /// Change AI difficulty
  void setAIDifficulty(AIDifficulty difficulty) {
    ai = AIPlayer(difficulty: difficulty);
    notifyListeners();
  }

  /// Get player by index
  Player getPlayer(int index) => gameState.players[index];

  /// Get player position for UI (0=bottom, 1=left, 2=top, 3=right)
  int getPlayerPosition(int playerIndex) {
    int humanIndex = gameState.players.indexWhere((p) => p.isHuman);
    return (playerIndex - humanIndex + 4) % 4;
  }
}
