import 'dart:ui'; // Tetap dipertahankan, meskipun filter blur dihapus
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dashboard_page.dart';

class SplashScreen extends StatefulWidget {
  final String username;
  final String password;
  final String role;
  final String expiredDate;
  final String sessionKey;
  final List<Map<String, dynamic>> listBug;
  final List<Map<String, dynamic>> listDoos;
  final List<dynamic> news;

  const SplashScreen({
    super.key,
    required this.username,
    required this.password,
    required this.role,
    required this.expiredDate,
    required this.sessionKey,
    required this.listBug,
    required this.listDoos,
    required this.news,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _fadeController;
  bool _fadeOutStarted = false;

  // --- Warna Abu-Abu Silver ---
  final Color primarySilver = const Color(0xFF757575);
  final Color accentSilver = const Color(0xFFBDBDBD);
  final Color primaryWhite = Colors.white;
  final Color primaryBlack = Colors.black;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset("assets/videos/splash.mp4")
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(false);
        _videoController.play();

        _fadeController = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 1),
        );

        _videoController.addListener(() {
          final position = _videoController.value.position;
          final duration = _videoController.value.duration;

          if (duration != null &&
              position >= duration - const Duration(seconds: 1) &&
              !_fadeOutStarted) {
            _fadeOutStarted = true;
            _fadeController.forward();
          }

          if (position >= duration) {
            _navigateToDashboard();
          }
        });
      });
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DashboardPage(
          username: widget.username,
          password: widget.password,
          role: widget.role,
          expiredDate: widget.expiredDate,
          sessionKey: widget.sessionKey,
          listBug: widget.listBug,
          listDoos: widget.listDoos,
          news: widget.news,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlack,
      body: Stack(
        children: [
          // --- VIDEO BACKGROUND FULL SCREEN ---
          // Menggunakan Positioned.fill agar video memenuhi layar
          if (_videoController.value.isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover, // Memastikan video menutupi layar tanpa distorsi
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // --- TEKS "Vorlexz Stars" ---
          // Teks melayang di atas video background
          Positioned(
            bottom: 80, // Jarak dari bawah layar
            left: 0,   // Mulai dari sisi kiri layar
            right: 0,  // Sampai sisi kanan layar
            child: Center( // Widget Center agar teks berada di tengah horizontal
              child: Text(
                "Vorlexz Stars",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: primaryWhite,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(
                      color: accentSilver.withOpacity(0.9), // Diubah dari merah ke silver
                      blurRadius: 15,
                      offset: const Offset(2, 2),
                    ),
                    Shadow(
                      color: primaryBlack.withOpacity(0.8),
                      blurRadius: 15,
                      offset: const Offset(-2, -2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- FADE OUT OVERLAY ---
          // Efek transisi hitam saat video hampir selesai
          if (_fadeOutStarted)
            FadeTransition(
              opacity: _fadeController.drive(Tween(begin: 1.0, end: 0.0)),
              child: Container(color: primaryBlack),
            ),
        ],
      ),
    );
  }
}
