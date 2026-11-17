import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/game_provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_localizations.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _soundEnabled = true;
  int _selectedLives = 14; // Default to 14 lives
  String _selectedDifficulty = 'medium'; // Default difficulty
  int _selectedPlayerCount = 4; // Default to 4 players

  static const String _difficultyKey = 'difficulty';
  static const String _livesKey = 'starting_lives';
  static const String _playerCountKey = 'player_count';

  @override
  void initState() {
    super.initState();
    _setFullScreen();
    _loadPreferences();
  }

  /// Set fullscreen mode and hide system overlays
  void _setFullScreen() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  /// Load saved preferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedDifficulty = prefs.getString(_difficultyKey) ?? 'medium';
      _selectedLives = prefs.getInt(_livesKey) ?? 14;
      _selectedPlayerCount = prefs.getInt(_playerCountKey) ?? 4;
    });
  }

  /// Save difficulty, lives, and player count preferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_difficultyKey, _selectedDifficulty);
    await prefs.setInt(_livesKey, _selectedLives);
    await prefs.setInt(_playerCountKey, _selectedPlayerCount);
  }

  @override
  void dispose() {
    // Restore system UI when leaving this screen
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  // Show difficulty selection dialog
  void _showDifficultyDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                constraints: BoxConstraints(
                  maxWidth: 700,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loc.translate('game_setup'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Horizontal layout: Difficulty on left, Players/Lives on right
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left side - Difficulty
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.chooseDifficulty,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildCompactDifficultyButton(
                                title: loc.easy,
                                description: loc.easyDesc,
                                icon: Icons.sentiment_satisfied,
                                color: Colors.green,
                                difficulty: 'easy',
                                isSelected: _selectedDifficulty == 'easy',
                                onTap: () {
                                  setState(() {
                                    _selectedDifficulty = 'easy';
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              _buildCompactDifficultyButton(
                                title: loc.medium,
                                description: loc.mediumDesc,
                                icon: Icons.sentiment_neutral,
                                color: Colors.orange,
                                difficulty: 'medium',
                                isSelected: _selectedDifficulty == 'medium',
                                onTap: () {
                                  setState(() {
                                    _selectedDifficulty = 'medium';
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              _buildCompactDifficultyButton(
                                title: loc.hard,
                                description: loc.hardDesc,
                                icon: Icons.sentiment_very_dissatisfied,
                                color: Colors.red,
                                difficulty: 'hard',
                                isSelected: _selectedDifficulty == 'hard',
                                onTap: () {
                                  setState(() {
                                    _selectedDifficulty = 'hard';
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Right side - Player count and Lives
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Player count selector
                              Text(
                                loc.translate('number_of_players'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildPlayerCountButton(
                                    playerCount: 3,
                                    isSelected: _selectedPlayerCount == 3,
                                    onTap: () {
                                      setState(() {
                                        _selectedPlayerCount = 3;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _buildPlayerCountButton(
                                    playerCount: 4,
                                    isSelected: _selectedPlayerCount == 4,
                                    onTap: () {
                                      setState(() {
                                        _selectedPlayerCount = 4;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Lives selector
                              Text(
                                loc.translate('starting_lives'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: _selectedLives > 1
                                        ? () {
                                            setState(() {
                                              _selectedLives--;
                                            });
                                          }
                                        : null,
                                    icon: const Icon(Icons.remove_circle),
                                    iconSize: 24,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.amber.shade700,
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      '$_selectedLives',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: _selectedLives < 14
                                        ? () {
                                            setState(() {
                                              _selectedLives++;
                                            });
                                          }
                                        : null,
                                    icon: const Icon(Icons.add_circle),
                                    iconSize: 24,
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Start Game button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(
                            loc.cancel,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 300,
                          child: ElevatedButton(
                            onPressed: () async {
                              // Save preferences before starting game
                              await _savePreferences();
                              if (mounted) {
                                Navigator.of(dialogContext).pop();
                                _initializeGame(context, _selectedDifficulty);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.play_arrow, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  loc.play,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCompactDifficultyButton({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String difficulty,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(230) : color.withAlpha(50),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : color.withAlpha(100),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: isSelected ? Colors.white : color),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : color.withAlpha(230),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white70 : color.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCountButton({
    required int playerCount,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? Colors.deepPurple.shade700
                : Colors.grey.shade400,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people,
              size: 28,
              color: isSelected
                  ? Colors.deepPurple.shade700
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              '$playerCount',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.deepPurple.shade900
                    : Colors.grey.shade700,
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.deepPurple.shade700,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // initialize game with difficulty, lives, and player count
  void _initializeGame(BuildContext context, String difficulty) {
    Provider.of<GameProvider>(context, listen: false).initializeGame(
      difficulty: difficulty,
      startingLives: _selectedLives,
      playerCount: _selectedPlayerCount,
    );
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const GameScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset('assets/background.jpg', fit: BoxFit.cover),
          // Dark overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(100),
                  Colors.black.withAlpha(150),
                ],
              ),
            ),
          ),
          // Main menu content
          SafeArea(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 400,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title with decorative cards
                    _buildTitle(),
                    const SizedBox(height: 16),
                    // Menu buttons
                    Consumer<GameProvider>(
                      builder: (context, game, child) {
                        final loc = AppLocalizations.of(context);
                        return Column(
                          children: [
                            _buildMenuButton(
                              context: context,
                              label: loc.play,
                              icon: Icons.play_arrow,
                              color: Colors.green.shade700,
                              onPressed: game.isProcessing
                                  ? null
                                  : () => _showDifficultyDialog(context),
                            ),
                            const SizedBox(height: 8),
                            _buildMenuButton(
                              context: context,
                              label: loc.howToPlay,
                              icon: Icons.help_outline,
                              color: Colors.blue.shade700,
                              onPressed: () => _showHowToPlay(context),
                            ),
                            const SizedBox(height: 8),
                            _buildMenuButton(
                              context: context,
                              label: loc.about,
                              icon: Icons.info_outline,
                              color: Colors.purple.shade700,
                              onPressed: () => _showAbout(context),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Top right quit button
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.red.shade400,
                    Colors.red.shade700,
                    Colors.red.shade900,
                  ],
                ),
                border: Border.all(color: Colors.red.shade900, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withAlpha(120),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.black.withAlpha(100),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () => _showQuitDialog(context),
                  customBorder: const CircleBorder(),
                  splashColor: Colors.red.shade200,
                  child: const Center(
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bottom left controls
          Positioned(
            bottom: 20,
            left: 20,
            child: Row(
              children: [
                // Sound toggle
                _buildControlIcon(
                  icon: _soundEnabled ? Icons.volume_up : Icons.volume_off,
                  onPressed: () {
                    setState(() {
                      _soundEnabled = !_soundEnabled;
                    });
                  },
                ),
                const SizedBox(width: 30),
                // Language toggles
                Consumer<LanguageProvider>(
                  builder: (context, languageProvider, child) {
                    final currentLang = languageProvider.locale.languageCode;
                    return Row(
                      children: [
                        _buildFlagIcon(
                          flagAsset: 'assets/flags/uk.png',
                          isSelected: currentLang == 'en',
                          onPressed: () {
                            languageProvider.setLocale('en');
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildFlagIcon(
                          flagAsset: 'assets/flags/france.png',
                          isSelected: currentLang == 'fr',
                          onPressed: () {
                            languageProvider.setLocale('fr');
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlIcon({
    required IconData icon,
    String? label,
    bool isSelected = false,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: label != null ? 50 : 40,
      height: label != null ? 50 : 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [
                  Colors.amber.shade300,
                  Colors.amber.shade600,
                  Colors.amber.shade800,
                ]
              : [
                  Colors.amber.shade100,
                  Colors.amber.shade200,
                  Colors.amber.shade400,
                ],
        ),
        border: Border.all(color: Colors.amber.shade900, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.shade700.withAlpha(80),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          splashColor: Colors.amber.shade100,
          child: Center(
            child: label != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        color: isSelected
                            ? Colors.white
                            : Colors.brown.shade900,
                        size: 24,
                        shadows: [
                          Shadow(
                            color: Colors.black.withAlpha(128),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.brown.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          shadows: [
                            Shadow(
                              color: Colors.black.withAlpha(128),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Icon(
                    icon,
                    color: Colors.brown.shade900,
                    size: 28,
                    shadows: [
                      Shadow(
                        color: Colors.black.withAlpha(128),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlagIcon({
    required String flagAsset,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [
                  Colors.amber.shade100,
                  Colors.amber.shade200,
                  Colors.amber.shade400,
                ]
              : [
                  Colors.amber.shade300,
                  Colors.amber.shade600,
                  Colors.amber.shade800,
                ],
        ),
        border: Border.all(
          color: isSelected ? Colors.amber.shade900 : Colors.amber.shade700,
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.shade700.withAlpha(80),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          splashColor: Colors.amber.shade100,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ClipOval(child: Image.asset(flagAsset, fit: BoxFit.cover)),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final loc = AppLocalizations.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(240),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.shade700, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(128),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                loc.appTitle,
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade900,
                  letterSpacing: 8,
                  shadows: [
                    Shadow(
                      color: Colors.amber.shade700,
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              Text(
                loc.appSubtitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple.shade700,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade600,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: BorderSide(color: Colors.amber.shade700, width: 2),
          ),
          elevation: 8,
          shadowColor: Colors.black.withAlpha(128),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // responsive
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHowToPlay(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.howToPlay),
        content: SingleChildScrollView(
          child: Text(
            loc.translate('how_to_play_content'),
            style: const TextStyle(fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('got_it')),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.about),
        content: Text(
          loc.translate('about_content'),
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('close')),
          ),
        ],
      ),
    );
  }

  void _showQuitDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('quit_title')),
        content: Text(
          loc.translate('quit_message'),
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(loc.translate('quit_button')),
          ),
        ],
      ),
    );
  }
}
