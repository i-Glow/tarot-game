import 'card_model.dart';
import 'player_model.dart';

// Represents a single rotation (one round where all players play a card)
class Rotation {
  final List<PlayedCard> cardsPlayed = [];
  int leadPlayerIndex;
  final int expectedPlayers; // Number of players in the game

  Rotation({required this.leadPlayerIndex, required this.expectedPlayers});

  // Adds a card played by a player
  void addCard(Player player, PlayingCard card) {
    cardsPlayed.add(PlayedCard(player: player, card: card));
  }

  // Returns true if all players have played
  bool isComplete() => cardsPlayed.length == expectedPlayers;

  // Determines the winner of this rotation (highest card value wins)
  Player determineWinner() {
    if (!isComplete()) {
      throw StateError('Rotation is not complete');
    }

    PlayedCard winningCard = cardsPlayed[0];

    for (var played in cardsPlayed.skip(1)) {
      if (played.card.effectiveValue > winningCard.card.effectiveValue) {
        winningCard = played;
      }
    }

    return winningCard.player;
  }

  // Returns all cards in the rotation
  List<PlayingCard> getAllCards() {
    return cardsPlayed.map((p) => p.card).toList();
  }

  @override
  String toString() {
    return 'Rotation: ${cardsPlayed.map((p) => '${p.player.name}:${p.card}').join(', ')}';
  }
}

// Represents a card played by a specific player
class PlayedCard {
  final Player player;
  final PlayingCard card;

  PlayedCard({required this.player, required this.card});
}
