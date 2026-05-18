import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';
import '../widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _watchedCount = 0;
  int _favoritesCount = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final historyRes = await supabase.from('history').select('id').eq('user_id', userId);
      final favoritesRes = await supabase.from('favorites').select('id').eq('user_id', userId);
      
      if (mounted) {
        setState(() {
          _watchedCount = historyRes.length;
          _favoritesCount = favoritesRes.length;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    await supabase.auth.signOut();
    if (context.mounted) {
      context.goNamed('auth');
    }
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) {
        final passController = TextEditingController();
        bool isUpdating = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              title: const Text('Alterar Senha', style: TextStyle(color: AppColors.textPrimary)),
              content: TextField(
                controller: passController,
                obscureText: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Nova senha',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: isUpdating ? null : () async {
                    if (passController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('A senha deve ter pelo menos 6 caracteres'), backgroundColor: AppColors.error)
                      );
                      return;
                    }
                    setDialogState(() => isUpdating = true);
                    try {
                      await supabase.auth.updateUser(UserAttributes(password: passController.text));
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Senha atualizada com sucesso!'), backgroundColor: Colors.green)
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Erro ao atualizar senha'), backgroundColor: AppColors.error)
                        );
                      }
                    } finally {
                      if (context.mounted) setDialogState(() => isUpdating = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: isUpdating 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('Salvar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final email = user?.email ?? 'Usuário desconhecido';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.surface,
              child: Icon(Icons.person_outline, size: 60, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              email,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Estudante',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 40),
            
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Assistidos', _isLoadingStats ? '-' : _watchedCount.toString(), Icons.history),
                _buildStatCard('Favoritos', _isLoadingStats ? '-' : _favoritesCount.toString(), Icons.favorite_border),
              ],
            ),
            
            const SizedBox(height: 48),
            
            // Action Buttons
            CustomButton(
              text: 'Alterar Senha',
              icon: Icons.lock_outline,
              color: AppColors.surface,
              onPressed: _changePassword,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Fazer Logout',
              icon: Icons.logout,
              color: AppColors.error.withOpacity(0.8),
              onPressed: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
