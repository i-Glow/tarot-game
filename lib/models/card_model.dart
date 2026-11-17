/// Represents the type of card deck
enum DeckType {
  playing, // Trump cards 1-21 + Excuse (used for gameplay)
  family, // Family deck cards 1-10, V, C, Q, K (used for scoring/lives)
}

/// Represents the suit of a family deck card
enum FamilySuit {
  clubs, // Clubs (C) - Trèfles
  diamonds, // Diamonds (K) - Carreaux
  spades, // Spades (P) - Piques
  hearts, // Hearts (T) - Coeurs
}

/// Represents a playing card (Trump 1-21 or Excuse)
class PlayingCard {
  final int value; // 1-21, or 0 for Excuse
  final bool isExcuse;

  // For Excuse, the player chooses its value (0 or 22)
  int? excuseChosenValue;

  PlayingCard({required this.value, this.isExcuse = false})
    : assert(value >= 0 && value <= 21, 'Playing card value must be 0-21');

  /// Creates the Excuse card
  factory PlayingCard.excuse() {
    return PlayingCard(value: 0, isExcuse: true);
  }

  /// Creates a trump card (1-21)
  factory PlayingCard.trump(int value) {
    assert(value >= 1 && value <= 21, 'Trump value must be 1-21');
    return PlayingCard(value: value);
  }

  /// Gets the effective value for comparison (handles Excuse choice)
  int get effectiveValue {
    if (isExcuse) {
      return excuseChosenValue ?? 0; // Default to 0 if not chosen yet
    }
    return value;
  }

  /// Sets the Excuse value (0 or 22)
  void setExcuseValue(int chosenValue) {
    assert(isExcuse, 'Can only set value for Excuse card');
    assert(
      chosenValue == 0 || chosenValue == 22,
      'Excuse value must be 0 or 22',
    );
    excuseChosenValue = chosenValue;
  }

  /// Gets asset path for card image
  String get assetPath {
    if (isExcuse) return 'assets/cards/CaJ-TaroTv1-Exc.png';
    return 'assets/cards/CaJ-TaroTv1-${value}AT.png';
  }

  @override
  String toString() {
    if (isExcuse) {
      return 'Excuse${excuseChosenValue != null ? "($excuseChosenValue)" : ""}';
    }
    return 'Trump-$value';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayingCard &&
        other.value == value &&
        other.isExcuse == isExcuse;
  }

  @override
  int get hashCode => Object.hash(value, isExcuse);
}

/// Represents a family deck card (used for player life/score)
class FamilyCard {
  final FamilySuit suit;
  final int rank; // 1-10 for numbers, 11=Valet, 12=Cavalier, 13=Queen, 14=King

  FamilyCard({required this.suit, required this.rank})
    : assert(rank >= 1 && rank <= 14, 'Family card rank must be 1-14');

  // Gets the display name for face cards
  String get rankName {
    switch (rank) {
      case 11:
        return 'Valet';
      case 12:
        return 'Cavalier';
      case 13:
        return 'Queen';
      case 14:
        return 'King';
      default:
        return '$rank';
    }
  }

  // Gets asset path for family card image
  String get assetPath {
    String suitCode = _getSuitCode();
    String rankCode = _getRankCode();
    return 'assets/cards/CaJ-TaroTv1-$rankCode$suitCode.png';
  }

  String _getSuitCode() {
    switch (suit) {
      case FamilySuit.clubs:
        return 'P';
      case FamilySuit.diamonds:
        return 'K';
      case FamilySuit.spades:
        return 'T';
      case FamilySuit.hearts:
        return 'C';
    }
  }

  String _getRankCode() {
    // A, 2-10, V(alet), C(avalier), D(ame), R(oi)
    if (rank == 1) return 'A';
    if (rank <= 10) return '$rank';
    if (rank == 11) return 'V';
    if (rank == 12) return 'C';
    if (rank == 13) return 'D';
    if (rank == 14) return 'R';
    return '?';
  }

  @override
  String toString() => '${suit.name}-$rankName';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FamilyCard && other.suit == suit && other.rank == rank;
  }

  @override
  int get hashCode => Object.hash(suit, rank);
}
