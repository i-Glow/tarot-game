import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';

/// Widget for human player to choose Excuse card value (0 or 22)
class ExcuseValuePicker extends StatefulWidget {
  final Function(int) onValueSelected;

  const ExcuseValuePicker({super.key, required this.onValueSelected});

  @override
  State<ExcuseValuePicker> createState() => _ExcuseValuePickerState();
}

class _ExcuseValuePickerState extends State<ExcuseValuePicker> {
  int? _selectedValue;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final loc = AppLocalizations.of(context);

    return Container(
      color: Colors.black.withAlpha(200),
      child: Center(
        child: Container(
          width: size.width * 0.5,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(230),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.shade700, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.shade700.withAlpha(100),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                loc.translate('choose_excuse_value'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                loc.translate('excuse_value_description'),
                style: TextStyle(color: Colors.grey.shade300, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Value options
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildValueOption(0),
                  const SizedBox(width: 40),
                  _buildValueOption(22),
                ],
              ),
              const SizedBox(height: 24),

              // Confirm button
              if (_selectedValue != null)
                ElevatedButton(
                  onPressed: () {
                    widget.onValueSelected(_selectedValue!);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    loc.translate(
                      'confirm_value',
                      params: {'value': '$_selectedValue'},
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
      ),
    );
  }

  Widget _buildValueOption(int value) {
    final isSelected = _selectedValue == value;
    final loc = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedValue = value;
        });
      },
      child: Container(
        width: 80,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.shade700 : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.amber.shade900 : Colors.amber.shade700,
            width: isSelected ? 4 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.amber.withAlpha(150),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Value number
            Text(
              '$value',
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Label
            Text(
              value == 0 ? loc.translate('lowest') : loc.translate('highest'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.black87 : Colors.grey.shade400,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
