// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_app/screens/auth_service.dart';
import 'package:student_app/screens/theme.dart';

import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _uidCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _uidCtrl.dispose();
    super.dispose();
  }

  Future<void> _loginEmail() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      _showSnack('Please fill all fields');
      return;
    }
    setState(() => _loading = true);
    final res = await AuthService.login(
        email: _emailCtrl.text, password: _passCtrl.text);
    setState(() => _loading = false);
    if (!mounted) return;
    if (res['success']) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: res['user'])));
    } else {
      _showSnack(res['message']);
    }
  }

  Future<void> _loginUID() async {
    if (_uidCtrl.text.isEmpty) {
      _showSnack('Please enter your UID');
      return;
    }
    setState(() => _loading = true);
    final res = await AuthService.loginWithUID(_uidCtrl.text);
    setState(() => _loading = false);
    if (!mounted) return;
    if (res['success']) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: res['user'])));
    } else {
      _showSnack(res['message']);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins()),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 36),
              _buildCard(),
              const SizedBox(height: 24),
              _buildRegisterLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryLight]),
            borderRadius: BorderRadius.circular(16),
          ),
          child:
              const Icon(Icons.school_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 20),
        Text('Welcome Back!',
            style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 6),
        Text('Sign in to track your academic journey',
            style: GoogleFonts.poppins(
                fontSize: 14, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              labelStyle: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08), blurRadius: 8)
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Email & Password'),
                Tab(text: 'Student UID')
              ],
            ),
          ),
          SizedBox(
            height: 240,
            child: TabBarView(
              controller: _tabController,
              children: [_emailTab(), _uidTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon:
                  Icon(Icons.email_outlined, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon:
                  const Icon(Icons.lock_outline, color: AppTheme.textSecondary),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.textSecondary),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _loginEmail, child: const Text('Sign In')),
        ],
      ),
    );
  }

  Widget _uidTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter your Student UID',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          TextField(
            controller: _uidCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Student UID (e.g. STU-XXXXXXXX)',
              prefixIcon:
                  Icon(Icons.badge_outlined, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 18),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _loginUID, child: const Text('Sign In with UID')),
          const SizedBox(height: 10),
          Text(
            'Your UID was generated when you registered.',
            style: GoogleFonts.poppins(
                fontSize: 11, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? ",
            style: GoogleFonts.poppins(
                color: AppTheme.textSecondary, fontSize: 14)),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RegisterScreen())),
          child: Text('Register',
              style: GoogleFonts.poppins(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ),
      ],
    );
  }
}
