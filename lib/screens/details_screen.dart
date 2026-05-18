import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';
import '../widgets/custom_button.dart';

class DetailsScreen extends StatefulWidget {
  final int id;
  final String title;
  final String description;
  final String coverUrl;
  final String videoUrl;

  const DetailsScreen({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.coverUrl,
    required this.videoUrl,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool _isFavoriting = false;
  bool _isWatching = false;

  Future<void> _addToFavorites() async {
    setState(() => _isFavoriting = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('favorites').insert({
        'user_id': userId,
        'video_id': widget.id,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adicionado aos favoritos!'), backgroundColor: Colors.green),
        );
      }
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Já está nos favoritos!'), backgroundColor: AppColors.accent),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao favoritar'), backgroundColor: AppColors.error),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isFavoriting = false);
    }
  }

  Future<void> _watchVideo() async {
    setState(() => _isWatching = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('history').insert({
        'user_id': userId,
        'video_id': widget.id,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assistindo agora! (Adicionado ao Histórico)'), backgroundColor: AppColors.primary),
        );
      }
      final uri = Uri.parse(widget.videoUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível abrir o vídeo.'), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao registrar histórico'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isWatching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800]),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Assistir',
                    icon: Icons.play_arrow,
                    onPressed: _watchVideo,
                    isLoading: _isWatching,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Favoritar',
                    icon: Icons.favorite_border,
                    color: AppColors.surface,
                    onPressed: _addToFavorites,
                    isLoading: _isFavoriting,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
