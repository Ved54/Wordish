// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/words.dart';
import '../widgets/keyboard.dart';
import '../popups/how_to_play_popup.dart';
import '../services/sound_service.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final List<List<String>> _guesses = List.generate(
    6,
    (_) => List.filled(5, ''),
  );
  final List<List<LetterStatus>> _letterStatuses = List.generate(
    6,
    (_) => List.filled(5, LetterStatus.initial),
  );
  final TextEditingController _guessController = TextEditingController();
  final _soundService = SoundService();
  int _currentRow = 0;
  int _currentCol = 0;
  String _targetWord = '';
  bool _gameOver = false;
  bool _gameWon = false;
  Map<String, dynamic>? _userData;
  static const int _skipWordCost = 20;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _selectNewWord();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      _userData = doc.data();
    });
  }

  void _selectNewWord() {
    final solvedWords = _userData?['solvedWords'] as List<dynamic>? ?? [];
    final availableWords =
        words.where((word) => !solvedWords.contains(word)).toList();

    if (availableWords.isEmpty) {
      // If all words are solved, reset the solved words list
      _resetSolvedWords();
      _selectNewWord();
      return;
    }

    setState(() {
      _targetWord =
          availableWords[DateTime.now().millisecondsSinceEpoch %
              availableWords.length];
    });

    print("Target Word is : ${_targetWord}");
  }

  Future<void> _resetSolvedWords() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'solvedWords': [],
    });
  }

  void _handleKeyPress(String key) {
    if (_gameOver) return;

    if (key == 'BACKSPACE') {
      if (_currentCol > 0) {
        setState(() {
          _currentCol--;
          _guesses[_currentRow][_currentCol] = '';
        });
      }
    } else if (key == 'ENTER') {
      if (_currentCol == 5) {
        _submitGuess();
      }
    } else if (_currentCol < 5) {
      setState(() {
        _guesses[_currentRow][_currentCol] = key;
        _currentCol++;
      });
    }
  }

  void _submitGuess() {
    final guess = _guesses[_currentRow].join().toUpperCase();

    if (!words.contains(guess)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Not a valid word!')));
      return;
    }

    final statuses = List<LetterStatus>.filled(5, LetterStatus.initial);
    final targetLetters = _targetWord.split('');
    final guessLetters = guess.split('');

    // First pass: mark correct letters
    for (int i = 0; i < 5; i++) {
      if (guessLetters[i] == targetLetters[i]) {
        statuses[i] = LetterStatus.correct;
        targetLetters[i] = ''; // Mark as used
      }
    }

    // Second pass: mark present letters
    for (int i = 0; i < 5; i++) {
      if (statuses[i] == LetterStatus.initial) {
        final index = targetLetters.indexOf(guessLetters[i]);
        if (index != -1) {
          statuses[i] = LetterStatus.present;
          targetLetters[index] = ''; // Mark as used
        } else {
          statuses[i] = LetterStatus.absent;
        }
      }
    }

    setState(() {
      _letterStatuses[_currentRow] = statuses;
      _currentRow++;
      _currentCol = 0;
    });

    if (guess == _targetWord) {
      _handleWin();
    } else if (_currentRow == 6) {
      _handleLoss();
    }
  }

  Future<void> _handleWin() async {
    setState(() {
      _gameOver = true;
      _gameWon = true;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final triesLeft = 6 - _currentRow;
    final points = 5 + triesLeft;
    final coins = 10 + (triesLeft * 2);

    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final userDoc = await userRef.get();
    final data = userDoc.data()!;

    final newScore = data['score'] + points;
    final newCoins = data['coins'] + coins;
    final newCurrentStreak = data['currentStreak'] + 1;
    final newBestStreak =
        newCurrentStreak > data['bestStreak']
            ? newCurrentStreak
            : data['bestStreak'];
    final newTotalWordsGuessed = data['totalWordsGuessed'] + 1;
    final newAverageTries =
        ((data['averageTries'] * data['totalWordsGuessed']) + _currentRow) /
        newTotalWordsGuessed;
    final newWinRate =
        (data['winRate'] * data['totalWordsGuessed'] + 1) /
        newTotalWordsGuessed;

    await userRef.update({
      'score': newScore,
      'coins': newCoins,
      'currentStreak': newCurrentStreak,
      'bestStreak': newBestStreak,
      'totalWordsGuessed': newTotalWordsGuessed,
      'averageTries': newAverageTries,
      'winRate': newWinRate,
      'solvedWords': FieldValue.arrayUnion([_targetWord]),
    });

    // Refresh user data after update
    await _loadUserData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You won! +$points points, +$coins coins'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleLoss() async {
    setState(() {
      _gameOver = true;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'currentStreak': 0,
    });

    // Refresh user data after update
    await _loadUserData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Game Over! The word was $_targetWord'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _handleSkipWord() async {
    if (_userData == null) return;

    final currentCoins = _userData!['coins'] as int;
    if (currentCoins < _skipWordCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough coins! Need 20 coins to skip word.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Skip Word'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current word: $_targetWord'),
                const SizedBox(height: 16),
                Text('This will cost $_skipWordCost coins.'),
                const SizedBox(height: 8),
                const Text('Are you sure you want to skip this word?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Update coins in database
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'coins': FieldValue.increment(-_skipWordCost),
      });

      // Refresh user data
      await _loadUserData();

      // Reset game state and select new word
      setState(() {
        _guesses.clear();
        _guesses.addAll(List.generate(6, (_) => List.filled(5, '')));
        _letterStatuses.clear();
        _letterStatuses.addAll(
          List.generate(6, (_) => List.filled(5, LetterStatus.initial)),
        );
        _currentRow = 0;
        _currentCol = 0;
        _gameOver = false;
        _gameWon = false;
        _selectNewWord();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Word skipped! Starting new game...'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wordish'),
        actions: [
          if (_userData != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text('Score: ${_userData!['score']}'),
                  const SizedBox(width: 16),
                  Text('Coins: ${_userData!['coins']}'),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (!_gameOver)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _handleSkipWord,
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Skip Word (20 coins)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () {
                      _soundService.playSound('click');
                      showDialog(
                        context: context,
                        builder: (context) => const HowToPlayPopup(),
                      );
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: 30,
              itemBuilder: (context, index) {
                final row = index ~/ 5;
                final col = index % 5;
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: _getLetterColor(_letterStatuses[row][col]),
                  ),
                  child: Center(
                    child: Text(
                      _guesses[row][col],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (!_gameOver)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 5; i++)
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        color: _getLetterColor(_letterStatuses[_currentRow][i]),
                      ),
                      child: Center(
                        child: Text(
                          _guesses[_currentRow][i],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Keyboard(onKeyPressed: _handleKeyPress),
          ),
          if (_gameOver)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _guesses.clear();
                    _guesses.addAll(
                      List.generate(6, (_) => List.filled(5, '')),
                    );
                    _letterStatuses.clear();
                    _letterStatuses.addAll(
                      List.generate(
                        6,
                        (_) => List.filled(5, LetterStatus.initial),
                      ),
                    );
                    _currentRow = 0;
                    _currentCol = 0;
                    _gameOver = false;
                    _gameWon = false;
                    _selectNewWord();
                  });
                },
                child: const Text('Play Again'),
              ),
            ),
        ],
      ),
    );
  }

  Color _getLetterColor(LetterStatus status) {
    switch (status) {
      case LetterStatus.correct:
        return Colors.green;
      case LetterStatus.present:
        return Colors.amber;
      case LetterStatus.absent:
        return Colors.grey;
      case LetterStatus.initial:
        return Colors.white;
    }
  }
}

enum LetterStatus { initial, correct, present, absent }
