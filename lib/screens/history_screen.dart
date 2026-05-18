import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Future<void> _removeHistory(int historyId) async {
    try {
      await supabase.from('history').delete().eq('id', historyId);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removido do histórico')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao remover'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = supabase.auth.currentUser!.id;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabase.from('history').select('id, watched_at, videos(*)').eq('user_id', userId).order('watched_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final history = snapshot.data ?? [];
          if (history.isEmpty) {
            return const Center(
              child: Text('Nenhum histórico encontrado.', style: TextStyle(color: AppColors.textSecondary)),
            );
          }
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              final video = item['videos'];
              final historyId = item['id'];
              return ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    video['cover_url'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 80, color: Colors.grey),
                  ),
                ),
                title: Text(video['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                subtitle: Text(
                  'Assistido em: ${DateTime.parse(item['watched_at']).toLocal().toString().substring(0, 16)}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => _removeHistory(historyId),
                ),
                onTap: () {
                   context.pushNamed(
                    'details',
                    pathParameters: {'id': video['id'].toString()},
                    queryParameters: {
                      'title': video['title'],
                      'description': video['description'],
                      'cover_url': video['cover_url'],
                      'video_url': video['video_url'] ?? '',
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
