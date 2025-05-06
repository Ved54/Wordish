import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/theme.dart';
import '../services/sound_service.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _soundService = SoundService();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        backgroundColor: AppTheme.gameColors['background'],
        foregroundColor: Colors.white,
      ),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child:
                    Image.asset(
                      'assets/images/logo.png',
                      height: 120,
                    ).animate().fadeIn().scale(),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Loading stats...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading stats: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(
                        child: Text(
                          'No stats available',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildStatCard(
                          'Score',
                          userData['score']?.toString() ?? '0',
                          Icons.sports_esports,
                          AppTheme.buttonColors['play']!,
                        ).animate().fadeIn().slideY(begin: 0.2),
                        // const SizedBox(height: 16),
                        // _buildStatCard(
                        //   'Win Rate',
                        //   '${(userData['winRate'] ?? 0).toStringAsFixed(1)}%',
                        //   Icons.emoji_events,
                        //   AppTheme.buttonColors['leaderboard']!,
                        // ).animate().fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          'Best Streak',
                          userData['bestStreak']?.toString() ?? '0',
                          Icons.local_fire_department,
                          AppTheme.buttonColors['stats']!,
                        ).animate().fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          'Current Streak',
                          userData['currentStreak']?.toString() ?? '0',
                          Icons.trending_up,
                          AppTheme.buttonColors['play']!,
                        ).animate().fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          'Total Words Guessed',
                          userData['totalWordsGuessed']?.toString() ?? '0',
                          Icons.check_circle,
                          AppTheme.buttonColors['leaderboard']!,
                        ).animate().fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          'Average Tries',
                          (userData['averageTries'] ?? 0).toStringAsFixed(1),
                          Icons.calculate,
                          AppTheme.buttonColors['stats']!,
                        ).animate().fadeIn().slideY(begin: 0.2),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
