import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase Configuration
const String supabaseUrl = 'https://sgswqrzrsrzpezjxeotl.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNnc3dxcnpyc3J6cGV6anhlb3RsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxMDAyMjQsImV4cCI6MjA5NDY3NjIyNH0.soYA8h0n70EEthATY-F6d8JvLKq0ti0ELbegqJ6VQ-I';

final supabase = Supabase.instance.client;

// Theme Colors
class AppColors {
  static const Color background = Color(0xFF0F0C29); // Deep dark
  static const Color surface = Color(0xFF1E1B4B); // Dark purple
  static const Color primary = Color(0xFF8B5CF6); // Vibrant purple
  static const Color accent = Color(0xFFC4B5FD); // Light purple
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color error = Color(0xFFEF4444);
}
