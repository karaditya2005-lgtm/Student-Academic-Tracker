// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_app/screens/auth_service.dart';
import 'package:student_app/screens/theme.dart';
import 'package:student_app/screens/user_model.dart';

import 'dashboard_tab.dart';
import 'input_performance_tab.dart';
import 'digital_id_screen.dart';
import 'chatbot_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late UserModel _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  List<Widget> get _tabs => [
        DashboardTab(user: _user),
        InputPerformanceTab(user: _user, onSaved: _refreshUser),
        DigitalIdScreen(user: _user),
        ChatbotScreen(user: _user),
      ];

  Future<void> _refreshUser() async {
    final u = await AuthService.getCurrentUser();
    if (u != null && mounted) setState(() => _user = u);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.dashboard_rounded, Icons.dashboard_outlined,
                  'Dashboard'),
              _navItem(1, Icons.bar_chart_rounded, Icons.bar_chart_outlined,
                  'Performance'),
              _navItem(2, Icons.badge_rounded, Icons.badge_outlined, 'My ID'),
              _navItem(3, Icons.smart_toy_rounded, Icons.smart_toy_outlined,
                  'AI Tutor'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData active, IconData inactive, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? active : inactive,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
