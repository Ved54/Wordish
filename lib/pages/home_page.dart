import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wordish/pages/game_page.dart';
import 'package:wordish/pages/leaderboard_page.dart';
import 'package:wordish/pages/stats_page.dart';
import 'package:wordish/constants/theme.dart';
import 'package:wordish/services/sound_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Map<String, dynamic>?>? _userDataFuture;
  final _soundService = SoundService();

  @override
  void initState() {
    super.initState();
    _refreshUserData();
  }

  void _refreshUserData() {
    setState(() {
      _userDataFuture = getUserData();
    });
  }

  void signUserOut() async {
    _soundService.playSound('click');
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.gameColors['background'],
            title: const Text('Logout', style: TextStyle(color: Colors.white)),
            content: const Text(
              'Are you sure you want to logout?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      FirebaseAuth.instance.signOut();
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.gameColors['background']!,
              AppTheme.gameColors['background']!.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _userDataFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                );
              }

              final userData = snapshot.data!;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 120,
                    ).animate().fadeIn().scale(),
                    const SizedBox(height: 32),
                    Text(
                      'Welcome, ${userData['username']}!',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.textColors['primary'],
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn().slideY(begin: -0.2),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatItem(
                            'Score',
                            userData['score'].toString(),
                            Icons.star,
                            AppTheme.buttonColors['play']!,
                          ),
                          const SizedBox(width: 24),
                          _buildStatItem(
                            'Coins',
                            userData['coins'].toString(),
                            Icons.monetization_on,
                            AppTheme.buttonColors['leaderboard']!,
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: () async {
                        _soundService.playSound('click');
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GamePage(),
                          ),
                        );
                        _refreshUserData();
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Play Wordish'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.buttonColors['play'],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 50),
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _soundService.playSound('click');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LeaderboardPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.leaderboard),
                      label: const Text('Leaderboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.buttonColors['leaderboard'],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 50),
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _soundService.playSound('click');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StatsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bar_chart),
                      label: const Text('Stats'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.buttonColors['stats'],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 50),
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: signUserOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.buttonColors['logout'],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 50),
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textColors['secondary'],
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textColors['secondary']?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
