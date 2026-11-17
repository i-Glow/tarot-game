import 'dart:math';
import '../models/card_model.dart';
import '../models/player_model.dart';
import '../models/game_state.dart';
import '../models/trick_model.dart';

/// AI difficulty levels
enum AIDifficulty {
  easy, // Random-ish play
  medium, // Basic strategy
  hard, // Advanced strategy
}

/// AI player logic for bidding and card selection
class AIPlayer {
  final Random _random = Random();
  final AIDifficulty difficulty;

  AIPlayer({this.difficulty = AIDifficulty.medium});

  /// Estimates how many rotations the AI can win with current hand
  int estimateBid(Player player, GameState gameState) {
    List<PlayingCard> hand = player.hand;
    int cardsInRound = gameState.cardsPerPlayer;

    switch (difficulty) {
      case AIDifficulty.easy:
        return _estimateBidEasy(hand, cardsInRound);
      case AIDifficulty.medium:
        return _estimateBidMedium(hand, cardsInRound);
      case AIDifficulty.hard:
        return _estimateBidHard(hand, cardsInRound, gameState);
    }
  }

  /// Easy AI: Random-ish bidding
  int _estimateBidEasy(List<PlayingCard> hand, int cardsInRound) {
    // Count high cards (15+) and Excuse
    int highCards = hand.where((c) => c.effectiveValue >= 15).length;

    // Add some randomness
    int bid = highCards + _random.nextInt(2);
    return bid.clamp(0, cardsInRound);
  }

  /// Medium AI: Count strong cards
  int _estimateBidMedium(List<PlayingCard> hand, int cardsInRound) {
    int estimatedWins = 0;

    // Count very high cards (18-21) - likely to win
    estimatedWins += hand.where((c) => c.effectiveValue >= 18).length;

    // Count high cards (14-17) - 50% chance
    int highCards = hand
        .where((c) => c.effectiveValue >= 14 && c.effectiveValue < 18)
        .length;
    estimatedWins += (highCards / 2).round();

    // Excuse is unpredictable - count as 0.5 if set to 22, 0 if set to 0
    bool hasExcuse = hand.any((c) => c.isExcuse);
    if (hasExcuse) {
      estimatedWins += _random.nextBool() ? 1 : 0;
    }

    return estimatedWins.clamp(0, cardsInRound);
  }

  /// Hard AI: Advanced estimation considering opponents
  int _estimateBidHard(
    List<PlayingCard> hand,
    int cardsInRound,
    GameState gameState,
  ) {
    int estimatedWins = 0;

    // Analyze hand strength
    List<int> values = hand.map((c) => c.effectiveValue).toList()..sort();

    // Top 21 and 20 are very likely winners
    if (values.contains(21)) estimatedWins++;
    if (values.contains(20)) estimatedWins++;

    // Cards 17-19 are strong
    int strongCards = values.where((v) => v >= 17 && v <= 19).length;
    estimatedWins += (strongCards * 0.7).round();

    // Cards 13-16 are medium
    int mediumCards = values.where((v) => v >= 13 && v <= 16).length;
    estimatedWins += (mediumCards * 0.4).round();

    // Consider the round number - fewer cards = more predictable
    if (cardsInRound <= 2) {
      // In short rounds, be more conservative
      estimatedWins = (estimatedWins * 0.9).round();
    }

    return estimatedWins.clamp(0, cardsInRound);
  }

  /// Chooses a valid bid for the AI player
  int chooseBid(Player player, GameState gameState, List<int> validBids) {
    if (validBids.isEmpty) return 0;

    int estimatedBid = estimateBid(player, gameState);

    // If estimated bid is valid, use it
    if (validBids.contains(estimatedBid)) {
      return estimatedBid;
    }

    // Otherwise, find closest valid bid
    validBids.sort();
    int closest = validBids[0];
    int minDiff = (estimatedBid - closest).abs();

    for (int bid in validBids) {
      int diff = (estimatedBid - bid).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = bid;
      }
    }

    return closest;
  }

  /// Chooses which card to play
  PlayingCard chooseCard(Player player, GameState gameState) {
    Rotation? currentRotation = gameState.currentRotation;
    if (currentRotation == null || player.hand.isEmpty) {
      return player.hand[0]; // Fallback
    }

    List<PlayingCard> hand = List.from(player.hand);
    List<PlayedCard> cardsPlayed = currentRotation.cardsPlayed;

    switch (difficulty) {
      case AIDifficulty.easy:
        return _chooseCardEasy(hand, cardsPlayed, player);
      case AIDifficulty.medium:
        return _chooseCardMedium(hand, cardsPlayed, player, gameState);
      case AIDifficulty.hard:
        return _chooseCardHard(hand, cardsPlayed, player, gameState);
    }
  }

  /// Easy AI: Random or simple logic
  PlayingCard _chooseCardEasy(
    List<PlayingCard> hand,
    List<PlayedCard> cardsPlayed,
    Player player,
  ) {
    // If first to play, play a random card
    if (cardsPlayed.isEmpty) {
      return hand[_random.nextInt(hand.length)];
    }

    // Find highest card played so far
    int highestValue = cardsPlayed
        .map((p) => p.card.effectiveValue)
        .reduce((a, b) => a > b ? a : b);

    // Try to beat it with lowest winning card
    var winningCards = hand
        .where((c) => c.effectiveValue > highestValue)
        .toList();
    if (winningCards.isNotEmpty) {
      winningCards.sort((a, b) => a.effectiveValue.compareTo(b.effectiveValue));
      return winningCards[0];
    }

    // Can't win, play lowest card
    hand.sort((a, b) => a.effectiveValue.compareTo(b.effectiveValue));
    return hand[0];
  }

  /// Medium AI: Consider bid and current wins
  PlayingCard _chooseCardMedium(
    List<PlayingCard> hand,
    List<PlayedCard> cardsPlayed,
    Player player,
    GameState gameState,
  ) {
    int rotationsNeeded = player.currentBid - player.rotationsWon;
    int rotationsRemaining =
        gameState.cardsPerPlayer - gameState.rotationsPlayed;
    bool needToWin =
        rotationsNeeded > 0 && rotationsNeeded >= rotationsRemaining;

    // If first to play
    if (cardsPlayed.isEmpty) {
      if (needToWin) {
        // Play highest card to secure win
        hand.sort((a, b) => b.effectiveValue.compareTo(a.effectiveValue));
        return hand[0];
      } else {
        // Play medium card
        hand.sort((a, b) => a.effectiveValue.compareTo(b.effectiveValue));
        int midIndex = (hand.length / 2).floor();
        return hand[midIndex];
      }
    }

    // Find highest card played
    int highestValue = cardsPlayed
        .map((p) => p.card.effectiveValue)
        .reduce((a, b) => a > b ? a : b);

    if (needToWin) {
      // Try to win with lowest winning card
      var winningCards = hand
          .where((c) => c.effectiveValue > highestValue)
          .toList();
      if (winningCards.isNotEmpty) {
        winningCards.sort(
          (a, b) => a.effectiveValue.compareTo(b.effectiveValue),
        );
        return winningCards[0];
      }
      // Can't win, play lowest card
      hand.sort((a, b) => a.effectiveValue.compareTo(b.effectiveValue));
      return hand[0];
    } else {
      // Don't need to win, play low card
      hand.sort((a, b) => a.effectiveValue.compareTo(b.effectiveValue));
      return hand[0];
    }
  }

  /// Hard AI: Advanced strategy
  PlayingCard _chooseCardHard(
    List<PlayingCard> hand,
    List<PlayedCard> cardsPlayed,
    Player player,
    GameState gameState,
  ) {
    int rotationsNeeded = player.currentBid - player.rotationsWon;
    int rotationsRemaining =
        gameState.cardsPerPlayer - gameState.rotationsPlayed;
    int rotationsToSpare = rotationsRemaining - rotationsNeeded;

    bool mustWin = rotationsNeeded > 0 && rotationsToSpare <= 0;
    bool shouldWin = rotationsNeeded > 0 && rotationsToSpare <= 1;
    bool shouldLose = rotationsNeeded <= 0;

    // If first to play
    if (cardsPlayed.isEmpty) {
      hand.sort((a, b) => a.effectiveValue.compareTo(b.effectiveValue));

      if (mustWin) {
        // Play highest card
        return hand.last;
      } else if (shouldWin) {
        // Play high-medium card
        int index = ((hand.length * 3) / 4).floor();
        return hand[index];
      } else if (shouldLose) {
        // Play lowest card
        return hand[0];
      } else {
        // Play medium card
        int index = (hand.length / 2).floor();
        return hand[index];
      }
    }

    // Not first to play
    int highestValue = cardsPlayed
        .map((p) => p.card.effectiveValue)
        .reduce((a, b) => a > b ? a : b);

    var winningCards = hand
        .where((c) => c.effectiveValue > highestValue)
        .toList();
    var losingCards = hand
        .where((c) => c.effectiveValue <= highestValue)
        .toList();

    if (mustWin || shouldWin) {
      if (winningCards.isNotEmpty) {
        // Win with lowest winning card
        winningCards.sort(
          (a, b) => a.effectiveValue.compareTo(b.effectiveValue),
        );
        return winningCards[0];
      } else {
        // Can't win, play lowest card
        hand.sort((a, b) => a.effectiveValue.compareTo(b.effectiveValue));
        return hand[0];
      }
    } else if (shouldLose) {
      if (losingCards.isNotEmpty) {
        // Play highest losing card (get rid of medium cards)
        losingCards.sort(
          (a, b) => b.effectiveValue.compareTo(a.effectiveValue),
        );
        return losingCards[0];
      } else {
        // Must play winning card, use lowest
        winningCards.sort(
          (a, b) => a.effectiveValue.compareTo(b.effectiveValue),
        );
        return winningCards[0];
      }
    } else {
      // Neutral - play low card
      hand.sort((a, b) => a.effectiveValue.compareTo(b.effectiveValue));
      return hand[0];
    }
  }

  /// Chooses value for Excuse card (0 or 22)
  int chooseExcuseValue(
    Player player,
    GameState gameState,
    List<PlayedCard> cardsPlayed,
  ) {
    // If last to play, can make optimal decision
    // Check if we're the last player (all other players have played)
    if (cardsPlayed.length == gameState.playerCount - 1) {
      int highestValue = cardsPlayed
          .map((p) => p.card.effectiveValue)
          .reduce((a, b) => a > b ? a : b);

      int rotationsNeeded = player.currentBid - player.rotationsWon;

      if (rotationsNeeded > 0 && highestValue < 22) {
        // Need to win and 22 would win
        return 22;
      } else {
        // Don't need to win or can't win anyway
        return 0;
      }
    }

    // Not last to play - use strategy based on bid
    int rotationsNeeded = player.currentBid - player.rotationsWon;
    int rotationsRemaining =
        gameState.cardsPerPlayer - gameState.rotationsPlayed;

    if (rotationsNeeded > 0 && rotationsNeeded >= rotationsRemaining) {
      // Desperately need wins
      return 22;
    } else if (rotationsNeeded <= 0) {
      // Don't need more wins
      return 0;
    } else {
      // Medium situation - 50/50
      return _random.nextBool() ? 22 : 0;
    }
  }
}
