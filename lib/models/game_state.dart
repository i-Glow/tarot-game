import 'card_model.dart';
import 'player_model.dart';
import 'trick_model.dart';

// Represents the current phase of the game
enum GamePhase {
  bidding, // Players are announcing their bids
  playing, // Players are playing cards in rotations
  roundEnd, // Round is over, showing results
  gameEnd, // Game is completely over (player eliminated)
}

// Represents the complete state of a game
class GameState {
  final List<Player> players;
  final int playerCount;
  List<PlayingCard> playingDeck = [];

  GamePhase phase = GamePhase.bidding;
  int roundNumber = 0; // Round 1=5 cards, Round 2=4 cards, ..., Round 5=1 card
  int dealerIndex =
      -1; // start from -1 because we have a function that sets dealer to 0 on each new round
  int currentPlayerIndex = 0;

  // Bidding state
  late List<int> bids; // -1 means player hasn't bid yet
  int biddingPlayerIndex = 0;

  // Playing state
  Rotation? currentRotation;
  List<Rotation> completedRotations = [];
  int rotationsPlayed = 0;

  // Last round special rule (1 card, hidden from owner)
  bool isLastRound = false;
  Map<String, bool> cardVisibility = {}; // playerId -> canSeeOwnCard

  GameState({required this.players}) : playerCount = players.length {
    assert(
      players.length == 3 || players.length == 4,
      'Must have exactly 3 or 4 players',
    );
    bids = List.filled(playerCount, -1);
  }

  // Gets the current active player
  Player get currentPlayer => players[currentPlayerIndex];

  // Gets the player who is currently bidding
  Player get biddingPlayer {
    int actualPlayerIndex =
        (dealerIndex + 1 + biddingPlayerIndex) % players.length;
    return players[actualPlayerIndex];
  }

  // Checks if all players have made their bids
  bool get allBidsComplete => biddingPlayerIndex >= players.length;

  // Gets the total number of bids announced
  int get totalBids => bids.where((bid) => bid >= 0).fold(0, (a, b) => a + b);

  // Gets the number of cards dealt this round (5, 4, 3, 2, 1)
  int get cardsPerPlayer {
    return 6 - roundNumber.clamp(1, 5);
  }

  // Checks if a bid is valid (total bids can't equal cards dealt)
  bool isBidValid(int bid, int playerIndex) {
    if (bid < 0 || bid > cardsPerPlayer) return false;

    // If this is the last bidder, check restriction
    if (biddingPlayerIndex == playerCount - 1) {
      int currentTotal = bids.where((b) => b >= 0).fold(0, (a, b) => a + b);
      return (currentTotal + bid) != cardsPerPlayer;
    }

    return true;
  }

  // Moves to the next player
  void nextPlayer() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
  }

  // Moves to the next bidding player
  void nextBiddingPlayer() {
    biddingPlayerIndex++;
  }

  // Starts a new rotation
  void startNewRotation(int leadPlayerIndex) {
    currentRotation = Rotation(
      leadPlayerIndex: leadPlayerIndex,
      expectedPlayers: playerCount,
    );
    currentPlayerIndex = leadPlayerIndex;
  }

  // Completes the current rotation and determines winner
  Player? completeRotation() {
    if (currentRotation == null || !currentRotation!.isComplete()) {
      return null;
    }

    Player winner = currentRotation!.determineWinner();
    winner.rotationsWon++;

    completedRotations.add(currentRotation!);
    rotationsPlayed++;

    currentRotation = null;
    return winner;
  }

  // Checks if the round is over (all rotations played)
  bool get isRoundComplete {
    return rotationsPlayed >= cardsPerPlayer && currentRotation == null;
  }

  // Applies penalties for players who didn't meet their bid
  void applyRoundPenalties() {
    for (int i = 0; i < players.length; i++) {
      Player player = players[i];
      int bid = bids[i];
      int won = player.rotationsWon;

      if (won != bid) {
        int difference = (won - bid).abs();
        player.loseLife(difference);
        player.totalScore -= difference;
      }
    }

    // Check if any player is eliminated
    if (players.any((p) => !p.isAlive)) {
      phase = GamePhase.gameEnd;
    }
  }

  // Resets state for a new round
  void startNewRound() {
    roundNumber++;

    if (roundNumber > 5) {
      // After round 5, cycle back to round 1
      roundNumber = 1;
    }

    dealerIndex = (dealerIndex + 1) % players.length;

    // First bidder is 2nd player after dealer
    int firstBidderIndex = (dealerIndex + 1) % players.length;
    currentPlayerIndex = firstBidderIndex;
    biddingPlayerIndex = 0;

    phase = GamePhase.bidding;
    bids = List.filled(playerCount, -1); // Reset to -1 (no bids yet)
    currentRotation = null;
    completedRotations.clear();
    rotationsPlayed = 0;

    // Check if this will be the last round (1 card)
    isLastRound = (cardsPerPlayer == 1);

    if (isLastRound) {
      // In last round, players can't see their own card
      for (var player in players) {
        cardVisibility[player.id] = false;
      }
    }

    for (var player in players) {
      player.resetForNewRound();
    }
  }

  // Gets active (non-eliminated) players
  List<Player> get activePlayers {
    return players.where((p) => p.isAlive).toList();
  }

  // Gets the winner (if game is over)
  Player? get winner {
    var alive = activePlayers;
    if (alive.length == 1) return alive[0];
    if (alive.isEmpty) return null; // All eliminated (tie)?

    // If game ended by rounds, highest score wins
    alive.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return alive[0];
  }

  @override
  String toString() {
    return 'GameState(phase: $phase, round: $roundNumber, '
        'currentPlayer: ${currentPlayer.name}, rotationsPlayed: $rotationsPlayed)';
  }
}
