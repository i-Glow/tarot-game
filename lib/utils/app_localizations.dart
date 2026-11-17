import 'package:flutter/material.dart';

/// Localization class for managing app translations
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Home Screen
      'app_title': 'TAROT',
      'app_subtitle': 'Card Game',
      'play': 'PLAY',
      'how_to_play': 'HOW TO PLAY',
      'about': 'ABOUT',

      // Difficulty Selection
      'choose_difficulty': 'Choose Difficulty',
      'easy': 'EASY',
      'easy_desc': 'Bots make random moves',
      'medium': 'MEDIUM',
      'medium_desc': 'Bots use basic strategy',
      'hard': 'HARD',
      'hard_desc': 'Bots play optimally',
      'cancel': 'CANCEL',
      'starting_lives': 'Starting Lives',
      'number_of_players': 'Number of Players',

      // How to Play
      'how_to_play_title': 'How to Play',
      'how_to_play_content':
          'TAROT CARD GAME RULES:\n\n'
          '• Each round, players bid how many tricks they think they\'ll win\n'
          '• Play cards to win tricks - highest card wins\n'
          '• Score based on accuracy of your bid\n'
          '• Lose lives equal to the difference between bid and actual tricks won\n'
          '• Last player standing wins!\n\n'
          'ROUNDS:\n'
          '• Round 1: 5 cards each\n'
          '• Round 2: 4 cards each\n'
          '• Round 3: 3 cards each\n'
          '• Round 4: 2 cards each\n'
          '• Round 5: 1 card each (all cards face-up except yours!)',
      'got_it': 'GOT IT',

      // About
      'about_title': 'About',
      'about_content':
          'AFRICAN TAROT CARD GAME\n\n'
          'A strategic bidding and trick-taking card game.\n\n'
          'Developed with Flutter\n'
          'By BOUHALASSA Abdelmalek\n\n'
          'In the context of a Mobile Development course project.\n'
          'Marie and Louis Pasteur University.',
      'close': 'CLOSE',

      // Quit Dialog
      'quit_title': 'Quit Game?',
      'quit_message': 'Are you sure you want to exit the game?',
      'quit_button': 'QUIT',

      // Settings Dialog
      'settings': 'Settings',
      'language': 'Language',
      'exit_to_home': 'Exit to Home Screen',
      'exit_game': 'Exit Game?',
      'exit_game_message':
          'Are you sure you want to exit to the home screen? Your current game will be lost.',
      'exit': 'EXIT',

      // Game Screen
      'game_setup': 'Game Setup',
      'game_started': 'Game Started',
      'round': 'Round',
      'bidding': 'Bidding',
      'playing': 'Playing',
      'you': 'You',
      'bid': 'Bid',
      'wins_rotation': 'wins the rotation!',
      'got_trick': 'got the trick',
      'got_trick_human': 'got the trick',
      'perfect': 'Perfect! No lives lost!',
      'lost_one_life': 'Lost 1 life',
      'lost_lives': 'Lost {count} lives',
      'victory': 'VICTORY!',
      'defeat': 'DEFEAT!',
      'game_over': 'Game Over',
      'survived_all_rounds': 'You survived all rounds!',
      'ran_out_of_lives': 'You ran out of lives',
      'final_score': 'Final Score: {score}',
      'back_to_home': 'Back to Home',

      // Bidding Widget
      'is_bidding': 'is bidding...',
      'make_your_bid': 'Make Your Bid',
      'select_tricks': 'Select how many tricks you will win',
      'confirm_bid': 'Confirm Bid: {bid} trick',
      'confirm_bid_plural': 'Confirm Bid: {bid} tricks',
      'to_bid': 'To Bid',

      // Excuse Value Picker
      'choose_excuse_value': 'Choose Excuse Value',
      'excuse_value_description':
          'The Excuse can be played as either the lowest (0) or highest (22) card',
      'confirm_value': 'Confirm: {value}',
      'lowest': 'Lowest',
      'highest': 'Highest',
    },
    'fr': {
      // Home Screen
      'app_title': 'TAROT',
      'app_subtitle': 'Jeu de Cartes',
      'play': 'JOUER',
      'how_to_play': 'COMMENT JOUER',
      'about': 'À PROPOS',

      // Difficulty Selection
      'choose_difficulty': 'Choisir la Difficulté',
      'easy': 'FACILE',
      'easy_desc': 'Les bots jouent au hasard',
      'medium': 'MOYEN',
      'medium_desc': 'Les bots utilisent une stratégie de base',
      'hard': 'DIFFICILE',
      'hard_desc': 'Les bots jouent de manière optimale',
      'starting_lives': 'Vies de Départ',
      'number_of_players': 'Nombre de Joueurs',
      'cancel': 'ANNULER',

      // How to Play
      'how_to_play_title': 'Comment Jouer',
      'how_to_play_content':
          'RÈGLES DU JEU DE TAROT:\n\n'
          '• Chaque tour, les joueurs parient combien de plis ils pensent gagner\n'
          '• Jouez des cartes pour gagner des plis - la carte la plus haute gagne\n'
          '• Score basé sur la précision de votre pari\n'
          '• Perdez des vies égales à la différence entre pari et plis gagnés\n'
          '• Le dernier joueur debout gagne!\n\n'
          'TOURS:\n'
          '• Tour 1: 5 cartes chacun\n'
          '• Tour 2: 4 cartes chacun\n'
          '• Tour 3: 3 cartes chacun\n'
          '• Tour 4: 2 cartes chacun\n'
          '• Tour 5: 1 carte chacun (toutes les cartes face visible sauf la vôtre!)',
      'got_it': 'COMPRIS',

      // About
      'about_title': 'À Propos',
      'about_content':
          'JEU DU TAROT AFRICAIN\n\n'
          'Un jeu de cartes stratégique de paris et de plis.\n\n'
          'Développé avec Flutter\n'
          'Par BOUHALASSA Abdelmalek\n\n'
          'Dans le cadre d\'un projet du cours de Développement Mobile.\n'
          'Université Marie et Louis Pasteur.',
      'close': 'FERMER',

      // Quit Dialog
      'quit_title': 'Quitter le Jeu?',
      'quit_message': 'Êtes-vous sûr de vouloir quitter le jeu?',
      'quit_button': 'QUITTER',

      // Settings Dialog
      'settings': 'Paramètres',
      'language': 'Langue',
      'exit_to_home': 'Retour à l\'Accueil',
      'exit_game': 'Quitter la Partie?',
      'exit_game_message':
          'Êtes-vous sûr de vouloir retourner à l\'écran d\'accueil? Votre partie en cours sera perdue.',
      'exit': 'QUITTER',

      // Game Screen
      'game_setup': 'Configuration de la Partie',
      'game_started': 'Partie Commencée',
      'round': 'Tour',
      'bidding': 'Enchères',
      'playing': 'En jeu',
      'you': 'Vous',
      'bid': 'Pari',
      'wins_rotation': 'gagne la rotation!',
      'got_trick': 'a pris le pli',
      'got_trick_human': 'avez pris le pli',
      'perfect': 'Parfait! Aucune vie perdue! ✨',
      'lost_one_life': 'Perdu 1 vie 💔',
      'lost_lives': 'Perdu {count} vies 💔💔',
      'victory': 'VICTOIRE!',
      'defeat': 'DÉFAITE!',
      'game_over': 'Fin de Partie',
      'survived_all_rounds': 'Vous avez survécu à tous les tours!',
      'ran_out_of_lives': 'Vous n\'avez plus de vies',
      'final_score': 'Score Final: {score}',
      'back_to_home': 'Retour à l\'Accueil',

      // Bidding Widget
      'is_bidding': 'enchérit...',
      'make_your_bid': 'Faites Votre Pari',
      'select_tricks': 'Sélectionnez combien de plis vous gagnerez',
      'confirm_bid': 'Confirmer le Pari: {bid} pli',
      'confirm_bid_plural': 'Confirmer le Pari: {bid} plis',
      'to_bid': 'À Parier',

      // Excuse Value Picker
      'choose_excuse_value': 'Choisir la Valeur de l\'Excuse',
      'excuse_value_description':
          'L\'Excuse peut être jouée comme la carte la plus faible (0) ou la plus forte (22)',
      'confirm_value': 'Confirmer: {value}',
      'lowest': 'Plus Faible',
      'highest': 'Plus Forte',
    },
  };

  String translate(String key, {Map<String, String>? params}) {
    String translation = _localizedValues[locale.languageCode]?[key] ?? key;

    // Replace parameters if provided
    if (params != null) {
      params.forEach((key, value) {
        translation = translation.replaceAll('{$key}', value);
      });
    }

    return translation;
  }

  // Convenience getters for common translations
  String get appTitle => translate('app_title');
  String get appSubtitle => translate('app_subtitle');
  String get play => translate('play');
  String get howToPlay => translate('how_to_play');
  String get about => translate('about');
  String get chooseDifficulty => translate('choose_difficulty');
  String get easy => translate('easy');
  String get easyDesc => translate('easy_desc');
  String get medium => translate('medium');
  String get mediumDesc => translate('medium_desc');
  String get hard => translate('hard');
  String get hardDesc => translate('hard_desc');
  String get cancel => translate('cancel');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
