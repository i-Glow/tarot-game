import 'package:flutter/material.dart';

/// Returns the size for bid tokens based on screen size
double getTokenSize(Size screenSize) => screenSize.width * 0.04;

/// Returns the size for family deck cards based on screen size
Map<String, double> getDeckCardSize(Size screenSize) => {
  'width': screenSize.width * 0.05,
  'height': screenSize.width * 0.05 * 1.8,
};

/// Returns the size for player cards based on screen size
Map<String, double> getPlayerCardSize(Size screenSize) => {
  'width': screenSize.width * 0.055,
  'height': screenSize.width * 0.055 * 1.84,
};
