import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Future<void> _removeFavorite(int favoriteId) async {
    try {
      await supabase.from('favorites').delete().eq('id', favoriteId);
      setState(() {}); // trigger rebuild to fetch again
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removido dos favoritos')),
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
        title: const Text('Meus Favoritos'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabase.from('favorites').select('id, videos(*)').eq('user_id', userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final favorites = snapshot.data ?? [];
          if (favorites.isEmpty) {
            return const Center(
              child: Text('Nenhum favorito encontrado.', style: TextStyle(color: AppColors.textSecondary)),
            );
          }
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final item = favorites[index];
              final video = item['videos'];
              final favoriteId = item['id'];
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
                  video['description'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => _removeFavorite(favoriteId),
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
