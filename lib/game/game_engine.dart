import 'dart:math';
import '../models/card_model.dart';
import '../models/player_model.dart';
import '../models/game_state.dart';

/// Core game engine that manages game logic and flow
class GameEngine {
  final GameState gameState;
  final Random _random = Random();

  GameEngine({required this.gameState});

  // Initializes the game - sets up family decks
  void initializeGame() {
    for (var player in gameState.players) {
      player.initializeFamilyDeck();
    }

    // Start first round
    startNewRound();
  }

  // Builds the playing deck (Trump 1-21 + Excuse = 22 cards)
  List<PlayingCard> buildPlayingDeck() {
    List<PlayingCard> deck = [];

    // Add trump cards 1-21
    for (int i = 1; i <= 21; i++) {
      deck.add(PlayingCard.trump(i));
    }

    // Add the Excuse
    deck.add(PlayingCard.excuse());

    return deck;
  }

  // Shuffles the playing deck
  void shuffleDeck() {
    for (int i = gameState.playingDeck.length - 1; i > 0; i--) {
      int j = _random.nextInt(i + 1);
      var temp = gameState.playingDeck[i];
      gameState.playingDeck[i] = gameState.playingDeck[j];
      gameState.playingDeck[j] = temp;
    }
  }

  // Deals cards to all players for the current round
  void dealCards() {
    // Build and shuffle deck
    gameState.playingDeck = buildPlayingDeck();
    shuffleDeck();

    int cardsPerPlayer = gameState.cardsPerPlayer;
    int cardIndex = 0;

    // Deal cards to each player
    for (int i = 0; i < gameState.players.length; i++) {
      gameState.players[i].hand.clear();

      for (int j = 0; j < cardsPerPlayer; j++) {
        if (cardIndex < gameState.playingDeck.length) {
          gameState.players[i].addCard(gameState.playingDeck[cardIndex]);
          cardIndex++;
        }
      }

      // Sort the hand for easier viewing
      gameState.players[i].sortHand();
    }
  }

  // Starts a new round
  void startNewRound() {
    // Check if any players are eliminated before starting
    if (gameState.players.any((p) => !p.isAlive)) {
      gameState.phase = GamePhase.gameEnd;
      return;
    }

    gameState.startNewRound();
    dealCards();

    // Set up bidding phase
    gameState.phase = GamePhase.bidding;

    // // First bidder is 1st player after dealer
    // int firstBidderIndex =
    //     (gameState.dealerIndex + 1) % gameState.players.length;
    // gameState.currentPlayerIndex = firstBidderIndex;
    // gameState.biddingPlayerIndex = 0;
  }

  // Submits a bid for the current bidding player
  // Returns true if bid was accepted, false if invalid
  bool submitBid(int bid) {
    if (gameState.phase != GamePhase.bidding) return false;
    if (gameState.allBidsComplete) return false;

    int playerIndex =
        (gameState.dealerIndex + 1 + gameState.biddingPlayerIndex) %
        gameState.players.length;

    // Validate bid
    if (!gameState.isBidValid(bid, playerIndex)) {
      return false;
    }

    // Record the bid
    gameState.bids[playerIndex] = bid;
    gameState.players[playerIndex].currentBid = bid;

    // Move to next bidder
    gameState.nextBiddingPlayer();

    // Check if bidding is complete
    if (gameState.allBidsComplete) {
      startPlayingPhase();
    }

    return true;
  }

  // Starts the playing phase after bidding completes
  void startPlayingPhase() {
    gameState.phase = GamePhase.playing;

    // First player is 2nd after dealer
    int firstPlayerIndex =
        (gameState.dealerIndex + 1) % gameState.players.length;
    gameState.startNewRotation(firstPlayerIndex);
  }

  // Plays a card for the current player
  // Returns true if card was played successfully
  bool playCard(PlayingCard card) {
    if (gameState.phase != GamePhase.playing) return false;
    if (gameState.currentRotation == null) return false;

    Player currentPlayer = gameState.currentPlayer;

    // Check if player has this card
    if (!currentPlayer.hand.contains(card)) {
      return false;
    }

    // If it's the Excuse and value not set, we need to handle that in UI first
    if (card.isExcuse && card.excuseChosenValue == null) {
      // This should be handled by UI before calling playCard
      return false;
    }

    // Play the card
    currentPlayer.playCard(card);
    gameState.currentRotation!.addCard(currentPlayer, card);

    if (!gameState.currentRotation!.isComplete()) {
      gameState.nextPlayer();
    }

    return true;
  }

  // Completes the current rotation and determines winner
  void completeRotation() {
    Player? winner = gameState.completeRotation();

    if (winner == null) return;

    // Check if round is complete
    if (gameState.isRoundComplete) {
      endRound();
    } else {
      // Winner leads next rotation
      int winnerIndex = gameState.players.indexOf(winner);
      gameState.startNewRotation(winnerIndex);
    }
  }

  // Ends the current round and calculates penalties
  void endRound() {
    gameState.phase = GamePhase.roundEnd;
    gameState.applyRoundPenalties();

    // Check if game is over (someone eliminated)
    if (!gameState.players.every((p) => p.isAlive)) {
      gameState.phase = GamePhase.gameEnd;
    }
  }

  // Gets valid bids for the current bidding player
  List<int> getValidBids() {
    if (gameState.phase != GamePhase.bidding) return [];

    int cardsThisRound = gameState.cardsPerPlayer;
    int playerIndex =
        (gameState.dealerIndex + 1 + gameState.biddingPlayerIndex) %
        gameState.players.length;

    List<int> validBids = [];

    for (int bid = 0; bid <= cardsThisRound; bid++) {
      if (gameState.isBidValid(bid, playerIndex)) {
        validBids.add(bid);
      }
    }

    return validBids;
  }

  /// Gets the current bidding order (player indices in order)
  List<int> getBiddingOrder() {
    List<int> order = [];
    for (int i = 0; i < gameState.playerCount; i++) {
      order.add((gameState.dealerIndex + 1 + i) % gameState.playerCount);
    }
    return order;
  }

  /// Gets the current playing order for this rotation
  List<int> getPlayingOrder() {
    if (gameState.currentRotation == null) return [];

    List<int> order = [];
    int leadIndex = gameState.currentRotation!.leadPlayerIndex;

    for (int i = 0; i < gameState.playerCount; i++) {
      order.add((leadIndex + i) % gameState.playerCount);
    }

    return order;
  }

  /// Gets a summary of the current round state
  String getRoundSummary() {
    StringBuffer sb = StringBuffer();
    sb.writeln(
      'Round ${gameState.roundNumber} - ${gameState.cardsPerPlayer} cards',
    );
    sb.writeln('Dealer: ${gameState.players[gameState.dealerIndex].name}');
    sb.writeln('\nBids:');

    for (int i = 0; i < gameState.players.length; i++) {
      Player player = gameState.players[i];
      sb.writeln(
        '  ${player.name}: ${gameState.bids[i]} (Won: ${player.rotationsWon})',
      );
    }

    return sb.toString();
  }

  /// Gets a summary of the game state
  String getGameSummary() {
    StringBuffer sb = StringBuffer();
    sb.writeln('=== Game Status ===');
    sb.writeln('Phase: ${gameState.phase.name}');
    sb.writeln('Round: ${gameState.roundNumber}');
    sb.writeln('\nPlayers:');

    for (var player in gameState.players) {
      String status = player.isAlive
          ? '❤️ ${player.remainingLives}'
          : '💀 ELIMINATED';
      sb.writeln('  ${player.name}: $status (Score: ${player.totalScore})');
    }

    if (gameState.phase == GamePhase.gameEnd) {
      Player? winner = gameState.winner;
      if (winner != null) {
        sb.writeln('\n🏆 WINNER: ${winner.name}');
      }
    }

    return sb.toString();
  }

  /// Resets the game to initial state
  void resetGame() {
    for (var player in gameState.players) {
      player.initializeFamilyDeck();
      player.resetForNewRound();
      player.totalScore = 0;
      player.isEliminated = false;
    }

    gameState.roundNumber = 0;
    gameState.dealerIndex = 0;
    gameState.phase = GamePhase.bidding;

    startNewRound();
  }
}
