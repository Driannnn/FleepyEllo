import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'game_page.dart';
import 'login_page.dart';
import '../models/game_config.dart';
import 'challenge_settings_page.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  String? _email;
  String? _name;
  Timer? _minuteTicker;

  // ===== Private state: challenges (contoh default)
  List<GameConfig> _challenges = const [
    GameConfig(
      name: 'Easy Breeze',
      description: 'Gap lebih lebar, pipa agak lambat.',
      pipeGapH: 200,
      pipeSpeed: 2.6,
    ),
    GameConfig(
      name: 'Hardcore',
      description: 'Gap sempit dan pipa cepat.',
      pipeGapH: 150,
      pipeSpeed: 3.6,
    ),
    GameConfig(
      name: 'Night Owl',
      description: 'Tema gelap, gap sedang, pipa cepat.',
      pipeGapH: 180,
      pipeSpeed: 3.2,
    ),
  ];

  // Getter–setter aman & reaktif
  List<GameConfig> get challenges => List.unmodifiable(_challenges);
  set challenges(List<GameConfig> value) {
    setState(() => _challenges = List<GameConfig>.from(value));
  }

  Future<void> _openChallengeSettings() async {
    final result = await Navigator.of(context).push<List<GameConfig>>(
      MaterialPageRoute(
        builder: (_) => ChallengeSettingsPage(initial: challenges),
      ),
    );
    if (result != null && mounted) {
      challenges = result;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _minuteTicker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;

    if (user == null) {
      // Jika belum login, balik ke LoginPage (tanpa autologin apa pun)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      setState(() {
        _email = user.email;
        _name = user.displayName;
      });
    }
  }

  @override
  void dispose() {
    _minuteTicker?.cancel();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h >= 4 && h < 11) return 'Selamat pagi';
    if (h >= 11 && h < 15) return 'Selamat siang';
    if (h >= 15 && h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String _displayName() {
    if (_name != null && _name!.trim().isNotEmpty) return _name!;
    final email = _email ?? '';
    if (email.contains('@')) {
      final n = email.split('@').first;
      if (n.isEmpty) return email;
      return n[0].toUpperCase() + n.substring(1);
    }
    return email.isEmpty ? 'Player' : email;
  }

  Future<void> _logout() async {
    try {
      // Sign-out dari Google (jika login via Google)
      await GoogleSignIn().signOut();
    } catch (_) {}
    // Sign-out dari Firebase
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (r) => false,
    );
  }

  void _play() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GamePage()),
    );
  }

  void _playWithConfig(GameConfig c) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GamePage(config: c)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    return Scaffold(
      // TANPA GetWidget: murni Material + “liquid glass”
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            children: [
              // Logo kotak “liquid”
              _GlassBox(
                radius: 20,
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: SvgPicture.asset('assets/bird.svg', fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Fleppy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black54)],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${_greeting()}, ${_displayName()}!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),

              // Play Button (Material)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoggedIn ? _play : null,
                  icon: const Icon(Icons.play_arrow_rounded, size: 26),
                  label: const Text(
                    'Play',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Logout Button (Material)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout'),
                ),
              ),

              // Kelola Tantangan
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: _openChallengeSettings,
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('Kelola Tantangan'),
                ),
              ),
              const SizedBox(height: 8),

              const SizedBox(height: 28),
              const Text(
                'Tantangan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Expansion list tantangan (Material)
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: challenges.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final c = challenges[i];
                  return Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: _GlassBox(
                      radius: 14,
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                        collapsedIconColor: Colors.white70,
                        iconColor: Colors.white,
                        leading: _GlassCircle(
                          child: const Icon(Icons.flag_rounded, color: Colors.white),
                        ),
                        title: Text(
                          c.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          c.description,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _glassStat(label: 'Gap', value: '${c.pipeGapH.toStringAsFixed(0)} px'),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _glassStat(label: 'Speed', value: '${c.pipeSpeed.toStringAsFixed(1)} px/tick'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.22),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => _playWithConfig(c),
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Mainkan tantangan ini'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====== small liquid glass helpers ======
  Widget _glassStat({required String label, required String value}) {
    return _GlassBox(
      radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _GlassBox extends StatelessWidget {
  final double radius;
  final EdgeInsetsGeometry? padding;
  final Widget child;

  const _GlassBox({
    required this.child,
    this.radius = 14,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white30, width: 1.2),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassCircle extends StatelessWidget {
  final Widget child;
  const _GlassCircle({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white30),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
