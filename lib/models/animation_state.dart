/// Represents the current animation state in the game screen
/// Each state indicates what animations have been completed
enum AnimationState {
  /// Initial state - showing "Game Started" overlay
  showingGameStarted,

  /// Showing "Round X" overlay
  showingRoundNumber,

  /// Lives deck distribution animation is playing
  playingLivesDeckDistribution,

  /// Lives decks are visible, card shuffle animation is playing
  playingCardShuffle,

  /// Card dealing animation is playing
  playingCardDealing,

  /// AI players are placing their bid tokens
  playingBiddingAnimation,

  /// Waiting for human player to make their bid
  waitingForHumanBid,

  /// All intro animations complete, ready for gameplay
  animationsComplete,

  // Add future states here as needed
  // playingCards,
  // etc.
}
