import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/constants.dart';
import '../widgets/loading_widget.dart';
import 'package:uuid/uuid.dart';

class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final playersProvider = Provider.of<PlayersProvider>(context, listen: false);
    final trainingProvider = Provider.of<TrainingProvider>(context, listen: false);
    
    await Future.wait([
      playersProvider.loadPlayers(),
      trainingProvider.loadTrainingSessions(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          AppStrings.appTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () => authProvider.logout(),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.people),
              text: AppStrings.players,
            ),
            Tab(
              icon: Icon(Icons.event),
              text: AppStrings.trainingSessions,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlayersTab(),
          _buildTrainingTab(),
        ],
      ),
    );
  }

  Widget _buildPlayersTab() {
    return Consumer<PlayersProvider>(
      builder: (context, playersProvider, child) {
        if (playersProvider.isLoading) {
          return const LoadingWidget(message: 'Загрузка игроков...');
        }

        return Column(
          children: [
            _buildStatsHeader(playersProvider.players),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => playersProvider.loadPlayers(),
                child: playersProvider.players.isEmpty
                    ? _buildEmptyState(
                        icon: Icons.people,
                        title: 'Нет игроков',
                        subtitle: 'Добавьте первого игрока в команду',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: playersProvider.players.length,
                        itemBuilder: (context, index) {
                          final player = playersProvider.players[index];
                          return _buildPlayerCard(player);
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrainingTab() {
    return Consumer<TrainingProvider>(
      builder: (context, trainingProvider, child) {
        if (trainingProvider.isLoading) {
          return const LoadingWidget(message: 'Загрузка тренировок...');
        }

        return RefreshIndicator(
          onRefresh: () => trainingProvider.loadTrainingSessions(),
          child: trainingProvider.sessions.isEmpty
              ? _buildEmptyState(
                  icon: Icons.event,
                  title: 'Нет тренировок',
                  subtitle: 'Создайте первую тренировку',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trainingProvider.sessions.length,
                  itemBuilder: (context, index) {
                    final session = trainingProvider.sessions[index];
                    return _buildTrainingCard(session);
                  },
                ),
        );
      },
    );
  }

  Widget _buildStatsHeader(List<Player> players) {
    final totalPoints = players.fold<int>(0, (sum, player) => sum + player.totalPoints);
    final avgAttendance = players.isEmpty 
        ? 0 
        : players.fold<int>(0, (sum, player) => sum + player.attendanceCount) / players.length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              title: 'Всего игроков',
              value: players.length.toString(),
              icon: Icons.people,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              title: 'Всего очков',
              value: totalPoints.toString(),
              icon: Icons.stars,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              title: 'Ср. посещения',
              value: avgAttendance.toStringAsFixed(1),
              icon: Icons.trending_up,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPlayerCard(Player player) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: AppConstants.levelColors[player.level],
          child: Text(
            player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          player.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (player.position != null) ...[
              const SizedBox(height: 4),
              Text(player.position!),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppConstants.levelColors[player.level],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppConstants.levelNames[player.level] ?? 'Неизвестно',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${player.totalPoints} очков',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditPlayerDialog(player);
            } else if (value == 'delete') {
              _deletePlayer(player);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Редактировать'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Удалить', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingCard(TrainingSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.sports_basketball,
            color: Color(0xFF1E3A8A),
            size: 24,
          ),
        ),
        title: Text(
          session.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '${session.date.day}.${session.date.month}.${session.date.year}',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: () => _markAttendance(session),
              tooltip: 'Отметить посещаемость',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteTrainingSession(session);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Удалить', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPlayerDialog(Player player) {
    // TODO: Implement edit player dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Редактирование игрока в разработке')),
    );
  }

  Future<void> _deletePlayer(Player player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить игрока'),
        content: Text('Вы уверены, что хотите удалить игрока ${player.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final playersProvider = Provider.of<PlayersProvider>(context, listen: false);
      await playersProvider.deletePlayer(player.id);
    }
  }

  Future<void> _deleteTrainingSession(TrainingSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить тренировку'),
        content: Text('Вы уверены, что хотите удалить тренировку "${session.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final trainingProvider = Provider.of<TrainingProvider>(context, listen: false);
      await trainingProvider.deleteTrainingSession(session.id);
    }
  }

  void _markAttendance(TrainingSession session) {
    // TODO: Implement attendance marking
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Отметка посещаемости в разработке')),
    );
  }
}