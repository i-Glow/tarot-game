import 'card_model.dart';

// Represents a player in the game
class Player {
  final String id;
  final String name;
  final bool isHuman;
  final FamilySuit familySuit; // Each player has their own suit for family deck
  final int startingLives; // Number of lives to start with (1-14)

  // Playing hand (Trump cards dealt each round)
  List<PlayingCard> hand = [];

  // Family deck (Life points - cards 1-14 of their suit)
  List<FamilyCard> familyDeck = [];

  // Round state
  int currentBid = 0;
  int rotationsWon = 0;

  // Game state
  int totalScore = 0;
  bool isEliminated = false;

  Player({
    required this.id,
    required this.name,
    required this.familySuit,
    this.isHuman = false,
    this.startingLives = 14,
  });

  // Initializes the family deck with all cards up to startingLives
  void initializeFamilyDeck() {
    familyDeck.clear();
    for (int rank = 1; rank <= startingLives; rank++) {
      familyDeck.add(FamilyCard(suit: familySuit, rank: rank));
    }
  }

  // Gets the number of cards remaining in family deck (life points)
  int get remainingLives => familyDeck.length;

  // Checks if player is still in the game
  bool get isAlive => familyDeck.isNotEmpty;

  // Adds a card to the player's hand
  void addCard(PlayingCard card) {
    hand.add(card);
  }

  // Removes and returns a card from the player's hand
  PlayingCard playCard(PlayingCard card) {
    hand.remove(card);
    return card;
  }

  // Sorts the hand by value
  void sortHand() {
    hand.sort((a, b) => a.effectiveValue.compareTo(b.effectiveValue));
  }

  // Loses cards from family deck (when missing bid)
  void loseLife(int cardsToLose) {
    int actualLoss = cardsToLose.clamp(0, familyDeck.length);

    // Remove from the end (highest cards first: King, Queen, etc.)
    for (int i = 0; i < actualLoss; i++) {
      if (familyDeck.isNotEmpty) {
        familyDeck.removeLast();
      }
    }

    if (familyDeck.isEmpty) {
      isEliminated = true;
    }
  }

  // Calculates and applies penalty for this round
  void applyRoundPenalty() {
    int difference = (currentBid - rotationsWon).abs();

    if (difference > 0) {
      loseLife(difference);
      totalScore -= difference;
    }
  }

  // Resets player state for a new round
  void resetForNewRound() {
    hand.clear();
    currentBid = 0;
    rotationsWon = 0;
  }

  @override
  String toString() =>
      '$name (${isHuman ? "Human" : "AI"}) - Lives: $remainingLives - Suit: $familySuit';
}
