import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/constants.dart';
import '../widgets/loading_widget.dart';

class PlayerStatsScreen extends StatefulWidget {
  const PlayerStatsScreen({super.key});

  @override
  State<PlayerStatsScreen> createState() => _PlayerStatsScreenState();
}

class _PlayerStatsScreenState extends State<PlayerStatsScreen> {
  List<Attendance> _playerAttendance = [];

  @override
  void initState() {
    super.initState();
    _loadPlayerData();
  }

  Future<void> _loadPlayerData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final trainingProvider = Provider.of<TrainingProvider>(context, listen: false);
    
    if (authProvider.currentUser?.player != null) {
      final playerId = authProvider.currentUser!.player!.id;
      final attendance = await trainingProvider.getPlayerAttendance(playerId);
      if (mounted) {
        setState(() {
          _playerAttendance = attendance;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final player = authProvider.currentUser?.player;
          
          if (player == null) {
            return const Center(
              child: Text('Пользователь не найден'),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(player, authProvider),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildStatsCards(player),
                    const SizedBox(height: 24),
                    _buildLevelProgress(player),
                    const SizedBox(height: 24),
                    _buildRecentAttendance(),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(Player player, AuthProvider authProvider) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1E3A8A),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => authProvider.logout(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          player.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF3B82F6),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: player.avatarUrl != null 
                    ? NetworkImage(player.avatarUrl!)
                    : null,
                child: player.avatarUrl == null 
                    ? Text(
                        player.name.isNotEmpty 
                            ? player.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.levelColors[player.level],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppConstants.levelNames[player.level] ?? 'Неизвестно',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(Player player) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: AppStrings.totalPoints,
            value: player.totalPoints.toString(),
            icon: Icons.stars,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: AppStrings.attendance,
            value: player.attendanceCount.toString(),
            icon: Icons.event_available,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgress(Player player) {
    final currentLevel = player.level;
    final currentPoints = player.totalPoints;
    final nextLevelThreshold = AppConstants.levelThresholds[currentLevel + 1];
    final currentLevelThreshold = AppConstants.levelThresholds[currentLevel] ?? 0;
    
    double progress = 0.0;
    String progressText = '';
    
    if (currentLevel >= 5) {
      progress = 1.0;
      progressText = 'Максимальный уровень достигнут!';
    } else {
      final pointsForNextLevel = nextLevelThreshold! - currentPoints;
      final totalPointsNeeded = nextLevelThreshold - currentLevelThreshold;
      final pointsEarned = currentPoints - currentLevelThreshold;
      
      progress = pointsEarned / totalPointsNeeded;
      progressText = 'До следующего уровня: $pointsForNextLevel очков';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppConstants.levelColors[currentLevel],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Прогресс уровня',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              AppConstants.levelColors[currentLevel] ?? Colors.blue,
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Text(
            progressText,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAttendance() {
    if (_playerAttendance.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_note,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Посещений пока нет',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.history,
                  color: Color(0xFF1E3A8A),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'История посещений',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _playerAttendance.length > 10 
                ? 10 
                : _playerAttendance.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final attendance = _playerAttendance[index];
              return ListTile(
                leading: Icon(
                  attendance.attended 
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: attendance.attended 
                      ? Colors.green
                      : Colors.red,
                ),
                title: Text(
                  'Тренировка ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Очки: ${attendance.pointsEarned}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Text(
                  '${attendance.createdAt.day}.${attendance.createdAt.month}.${attendance.createdAt.year}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}