import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/human_bidding_widget.dart';
import '../utils/app_localizations.dart';

/// Widget that manages the entire bidding phase
class BiddingPhaseWidget extends StatelessWidget {
  final VoidCallback onBiddingComplete;

  const BiddingPhaseWidget({super.key, required this.onBiddingComplete});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        // Check if bidding is complete
        if (game.gameState.allBidsComplete) {
          // Notify parent that bidding is done
          Future.microtask(() => onBiddingComplete());
          return const SizedBox.shrink();
        }

        // Show human bidding widget if it's human's turn
        if (game.isHumanTurn) {
          return HumanBiddingWidget(
            cardsPerPlayer: game.gameState.cardsPerPlayer,
            validBids: game.validBids,
            onBidSubmitted: (bid) async {
              await game.submitBid(bid);
            },
          );
        }

        // Show waiting indicator for AI turn
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(200),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade700, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${game.currentBiddingPlayer.name} ${AppLocalizations.of(context).translate('is_bidding')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                CircularProgressIndicator(color: Colors.amber.shade700),
              ],
            ),
          ),
        );
      },
    );
  }
}
