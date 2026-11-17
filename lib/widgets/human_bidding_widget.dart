import 'package:flutter/material.dart';
import 'package:tarot/utils/constants.dart';
import '../utils/app_localizations.dart';

/// Widget for human player to make their bid
class HumanBiddingWidget extends StatefulWidget {
  final int cardsPerPlayer;
  final List<int> validBids;
  final Function(int) onBidSubmitted;

  const HumanBiddingWidget({
    super.key,
    required this.cardsPerPlayer,
    required this.validBids,
    required this.onBidSubmitted,
  });

  @override
  State<HumanBiddingWidget> createState() => _HumanBiddingWidgetState();
}

class _HumanBiddingWidgetState extends State<HumanBiddingWidget> {
  int? _selectedBid;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final loc = AppLocalizations.of(context);

    return Center(
      child: Container(
        width: size.width * 0.6,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(200),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.shade700, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loc.translate('make_your_bid'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.translate('select_tricks'),
              style: TextStyle(color: Colors.grey.shade300, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              children: [
                for (int bid = 0; bid <= widget.cardsPerPlayer; bid++)
                  _buildBidButton(bid),
              ],
            ),
            const SizedBox(height: 8),
            if (_selectedBid != null)
              ElevatedButton(
                onPressed: () {
                  widget.onBidSubmitted(_selectedBid!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  loc.translate(
                    _selectedBid == 1 ? 'confirm_bid' : 'confirm_bid_plural',
                    params: {'bid': '$_selectedBid'},
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBidButton(int bid) {
    final isValid = widget.validBids.contains(bid);
    final isSelected = _selectedBid == bid;
    final tokenSize = getTokenSize(MediaQuery.of(context).size);

    return GestureDetector(
      onTap: isValid
          ? () {
              setState(() {
                _selectedBid = bid;
              });
            }
          : null,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.amber.shade700
                  : (isValid ? Colors.grey.shade800 : Colors.grey.shade900),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colors.amber.shade900
                    : (isValid ? Colors.amber.shade700 : Colors.grey.shade700),
                width: isSelected ? 3 : 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.amber.withAlpha(128),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/token.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.amber.shade700,
                      child: Center(
                        child: Icon(
                          Icons.circle,
                          size: tokenSize,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$bid',
            style: TextStyle(
              color: isValid
                  ? (isSelected ? Colors.amber.shade900 : Colors.white)
                  : Colors.grey.shade600,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
