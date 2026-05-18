import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String password;
  final String sessionKey;
  final List<Map<String, dynamic>> listBug;
  final String role;
  final String expiredDate;

  const HomePage({
    super.key,
    required this.username,
    required this.password,
    required this.sessionKey,
    required this.listBug,
    required this.role,
    required this.expiredDate,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final targetController = TextEditingController();
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  String selectedBugId = "";

  // --- State Baru: Mode Target ---
  // 'number' untuk nomor HP, 'group' untuk Link Group
  String _selectedBugMode = "number";

  bool _isSending = false;
  String? _responseMessage;

  // --- Tema Warna Abu-Abu Silver (Cyber Silver) ---
  final Color primaryBg = const Color(0xFF1A1A1A); // Dark background
  final Color cardBg = const Color(0xFF2C2C2C); // Dark silver card
  final Color primarySilver = const Color(0xFF757575); // Primary silver
  final Color accentSilver = const Color(0xFFBDBDBD); // Bright accent silver
  final Color deepSilver = const Color(0xFF424242); // Deep silver
  final Color textWhite = Colors.white;
  final Color textGrey = Colors.grey.shade400;

  // Gradients
  final LinearGradient silverGradient = const LinearGradient(
    colors: [Color(0xFF757575), Color(0xFFBDBDBD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Video Player Variables
  late VideoPlayerController _videoController;
  late ChewieController _chewieController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    if (widget.listBug.isNotEmpty) {
      selectedBugId = widget.listBug[0]['bug_id'];
    }

    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _videoController = VideoPlayerController.asset('assets/videos/banner.mp4');

    _videoController.initialize().then((_) {
      setState(() {
        _videoController.setVolume(0.1);
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: true,
          looping: true,
          showControls: false,
          autoInitialize: true,
        );
        _isVideoInitialized = true;
      });
    }).catchError((error) {
      print("Video initialization error: $error");
      setState(() {
        _isVideoInitialized = false;
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    targetController.dispose();
    _videoController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  String? formatPhoneNumber(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleaned.startsWith('+') || cleaned.length < 8) return null;
    return cleaned;
  }

  bool isValidGroupLink(String input) {
    // Validasi sederhana untuk link chat.whatsapp.com
    return input.contains('chat.whatsapp.com') && input.contains('https://');
  }

  Future<void> _sendBug() async {
    final rawInput = targetController.text.trim();
    final key = widget.sessionKey;

    // --- Validasi berdasarkan Mode ---
    if (_selectedBugMode == "number") {
      final target = formatPhoneNumber(rawInput);
      if (target == null || key.isEmpty) {
        _showAlert("❌ Invalid Number", "Gunakan nomor internasional (misal: +62, 1, 44), bukan 08xxx.");
        return;
      }
    } else {
      // Mode Group
      if (!isValidGroupLink(rawInput)) {
        _showAlert("❌ Invalid Link", "Masukkan link group WA yang valid (contoh: https://chat.whatsapp.com/...).");
        return;
      }
    }

    setState(() {
      _isSending = true;
      _responseMessage = null;
    });

    try {
      final res = await http.get(Uri.parse(
          "http://zanzzstorecsmurmerpanel.lightsecret.my.id:2024/sendBug?key=$key&target=$rawInput&bug=$selectedBugId")); // Mengirim rawInput
      final data = jsonDecode(res.body);

      if (data["cooldown"] == true) {
        setState(() => _responseMessage = "⏳ Cooldown: Tunggu kontol jan spam.");
      } else if (data["valid"] == false) {
        setState(() => _responseMessage = "❌ Key Invalid: Silakan login ulang.");
      } else if (data["sended"] == false) {
        setState(() => _responseMessage = "⚠️ Gagal: Server sedang maintenance.");
      } else {
        setState(() => _responseMessage = "✅ Berhasil mengirim bug!");
        targetController.clear();
      }
    } catch (_) {
      setState(() => _responseMessage = "❌ Error: Terjadi kesalahan. Coba lagi.");
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _showAlert(String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primarySilver.withOpacity(0.5)),
        ),
        title: Text(title,
            style: TextStyle(
              color: accentSilver,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.bold,
            )),
        content: Text(msg,
            style: const TextStyle(
                color: Colors.grey,
                fontFamily: 'ShareTechMono'
            )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK",
                style: TextStyle(
                  color: primarySilver,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primarySilver.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primarySilver.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo Container
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: silverGradient,
              boxShadow: [
                BoxShadow(
                  color: accentSilver.withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage('assets/images/logo.png'),
            ),
          ),
          const SizedBox(width: 20),
          // User Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primarySilver.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primarySilver.withOpacity(0.3)),
                  ),
                  child: Text(
                    "Role: ${widget.role.toUpperCase()} • Exp: ${widget.expiredDate}",
                    style: TextStyle(
                      color: accentSilver,
                      fontFamily: 'ShareTechMono',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized) {
      return Container(
        width: double.infinity,
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: accentSilver,
            strokeWidth: 3,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primarySilver.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: accentSilver.withOpacity(0.3), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: _videoController.value.aspectRatio,
          child: Stack(
            children: [
              Chewie(controller: _chewieController),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      primarySilver.withOpacity(0.2),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedBugMode = "number";
                targetController.clear();
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _selectedBugMode == "number"
                    ? accentSilver.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedBugMode == "number" ? accentSilver : primarySilver.withOpacity(0.3),
                  width: _selectedBugMode == "number" ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_android_rounded,
                    color: _selectedBugMode == "number" ? accentSilver : textGrey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "BUG NOMOR",
                    style: TextStyle(
                      color: _selectedBugMode == "number" ? accentSilver : textGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedBugMode = "group";
                targetController.clear();
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _selectedBugMode == "group"
                    ? accentSilver.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedBugMode == "group" ? accentSilver : primarySilver.withOpacity(0.3),
                  width: _selectedBugMode == "group" ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_add,
                    color: _selectedBugMode == "group" ? accentSilver : textGrey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "BUG GROUP",
                    style: TextStyle(
                      color: _selectedBugMode == "group" ? accentSilver : textGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. MODE SELECTOR (BARU)
        _buildModeSelector(),

        const SizedBox(height: 30),

        // 2. INPUT TARGET (DINAMIS)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Text(
            _selectedBugMode == "number" ? "NOMOR TARGET" : "LINK GROUP WA",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              fontFamily: 'Orbitron',
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: targetController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            cursorColor: accentSilver,
            keyboardType: _selectedBugMode == "number" ? TextInputType.phone : TextInputType.url,
            decoration: InputDecoration(
              hintText: _selectedBugMode == "number"
                  ? "Contoh: +62xxxxxxxxxx"
                  : "Contoh: https://chat.whatsapp.com/...",
              hintStyle: TextStyle(color: textGrey.withOpacity(0.5)),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: primarySilver.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: accentSilver, width: 2),
              ),
              prefixIcon: Icon(
                _selectedBugMode == "number" ? Icons.phone_android_rounded : Icons.link,
                color: accentSilver,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // 3. PILIH BUG
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: const Text(
            "PILIH BUG",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              fontFamily: 'Orbitron',
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primarySilver.withOpacity(0.3), width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: cardBg,
              value: selectedBugId,
              isExpanded: true,
              iconEnabledColor: accentSilver,
              iconSize: 28,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'ShareTechMono'),
              items: widget.listBug.map((bug) {
                return DropdownMenuItem<String>(
                  value: bug['bug_id'],
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      bug['bug_name'],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBugId = value ?? "";
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: silverGradient,
            boxShadow: [
              BoxShadow(
                color: accentSilver.withOpacity(0.4),
                blurRadius: _pulseController.value * 25,
                spreadRadius: _pulseController.value * 2,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isSending ? null : _sendBug,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: _isSending
                ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Text(
                  "SEND BUG ATTACK",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 2,
                    fontFamily: 'Orbitron',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponseMessage() {
    if (_responseMessage == null) return const SizedBox.shrink();

    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData icon;

    if (_responseMessage!.startsWith('✅')) {
      bgColor = Colors.green.withOpacity(0.15);
      borderColor = Colors.greenAccent;
      textColor = Colors.greenAccent;
      icon = Icons.check_circle_outline_rounded;
    } else if (_responseMessage!.startsWith('❌')) {
      bgColor = Colors.red.withOpacity(0.15);
      borderColor = Colors.redAccent;
      textColor = Colors.redAccent;
      icon = Icons.error_outline_rounded;
    } else {
      bgColor = primarySilver.withOpacity(0.15);
      borderColor = accentSilver;
      textColor = accentSilver;
      icon = Icons.info_outline_rounded;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _responseMessage!,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'ShareTechMono',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Sejajar
              _buildHeaderPanel(),
              const SizedBox(height: 20),
              // Video Player
              _buildVideoPlayer(),
              const SizedBox(height: 20),
              // Input Panel (Mode + Input + Dropdown)
              _buildInputPanel(),
              const SizedBox(height: 40),
              // Send Button
              _buildSendButton(),
              _buildResponseMessage(),
            ],
          ),
        ),
      ),
    );
  }
}
