import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

import 'nik_check.dart';
import 'admin_page.dart';
import 'owner_page.dart'; // <--- Import OwnerPage
import 'home_page.dart';
import 'seller_page.dart';
import 'change_password_page.dart';
import 'tools_gateway.dart';
import 'login_page.dart';
import 'bug_sender.dart';
import 'contact_page.dart';
import 'profile_page.dart';
import 'riwayat_page.dart';
import 'info_page.dart';


class DashboardPage extends StatefulWidget {
  final String username;
  final String password;
  final String role;
  final String expiredDate;
  final String sessionKey;
  final List<Map<String, dynamic>> listBug;
  final List<Map<String, dynamic>> listDoos;
  final List<dynamic> news;

  const DashboardPage({
    super.key,
    required this.username,
    required this.password,
    required this.role,
    required this.expiredDate,
    required this.listBug,
    required this.listDoos,
    required this.sessionKey,
    required this.news,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late WebSocketChannel channel;

  // --- State Variabel ---
  late String sessionKey;
  late String username;
  late String password;
  late String role;
  late String expiredDate;
  late List<Map<String, dynamic>> listBug;
  late List<Map<String, dynamic>> listDoos;
  late List<dynamic> newsList;

  // --- Fitur Profil & Menu Baru ---
  String androidId = "unknown";
  File? _profileImage; // Menyimpan foto profil
  VideoPlayerController? _menuVideoController; // Controller untuk video background menu

  int _bottomNavIndex = 0;
  Widget _selectedPage = const Placeholder();

  int onlineUsers = 0;
  int activeConnections = 0;

  // --- TEMA WARNA ABU-ABU SILVER ---
  final Color bgDark = const Color(0xFF1A1A1A); // Dark background
  final Color primarySilver = const Color(0xFF757575); // Primary silver
  final Color accentSilver = const Color(0xFFBDBDBD); // Bright accent silver
  final Color lightSilver = const Color(0xFFE0E0E0); // Light silver
  final Color primaryWhite = Colors.white;
  final Color accentGrey = Colors.grey.shade400;
  final Color cardGlass = Colors.white.withOpacity(0.05);
  final Color borderGlass = Colors.white.withOpacity(0.1);

  @override
  void initState() {
    super.initState();
    sessionKey = widget.sessionKey;
    username = widget.username;
    password = widget.password;
    role = widget.role;
    expiredDate = widget.expiredDate;
    listBug = widget.listBug;
    listDoos = widget.listDoos;
    newsList = widget.news;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    _selectedPage = _buildNewsPage();

    _initAndroidIdAndConnect();
    _loadProfileImage(); // Load foto profil
    _initMenuVideo();    // Init video background menu
  }

  // Load Foto Profil dari SharedPreferences
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_$username');
    if (imagePath != null && imagePath.isNotEmpty) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  // Init Video Background untuk Menu Sidebar
  void _initMenuVideo() {
    _menuVideoController = VideoPlayerController.asset('assets/videos/banner.mp4')
      ..initialize().then((_) {
        setState(() {});
        _menuVideoController?.setLooping(true);
        _menuVideoController?.play();
      });
  }

  Future<void> _initAndroidIdAndConnect() async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    androidId = deviceInfo.id;
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    channel = WebSocketChannel.connect(Uri.parse('wss://ws-dark.Vorlexz Stars.my.id'));
    channel.sink.add(jsonEncode({
      "type": "validate",
      "key": sessionKey,
      "androidId": androidId,
    }));
    channel.sink.add(jsonEncode({"type": "stats"}));

    channel.stream.listen((event) {
      final data = jsonDecode(event);
      if (data['type'] == 'myInfo') {
        if (data['valid'] == false) {
          if (data['reason'] == 'androidIdMismatch') {
            _handleInvalidSession("Your account has logged on another device.");
          } else if (data['reason'] == 'keyInvalid') {
            _handleInvalidSession("Key is not valid. Please login again.");
          }
        }
      }
      if (data['type'] == 'stats') {
        setState(() {
          onlineUsers = data['onlineUsers'] ?? 0;
          activeConnections = data['activeConnections'] ?? 0;
        });
      }
    });
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $uri");
    }
  }

  void _handleInvalidSession(String message) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: bgDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text("⚠️ Session Expired", style: TextStyle(color: accentSilver, fontWeight: FontWeight.bold)),
        content: Text(message, style: TextStyle(color: accentGrey)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
              );
            },
            child: Text("OK", style: TextStyle(color: primarySilver, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
      if (index == 0) {
        _selectedPage = _buildNewsPage();
      } else if (index == 1) {
        _selectedPage = HomePage(
          username: username,
          password: password,
          listBug: listBug,
          role: role,
          expiredDate: expiredDate,
          sessionKey: sessionKey,
        );
      } else if (index == 2) {
        _selectedPage = InfoPage(
          sessionKey: sessionKey);
      } else if (index == 3) {
        _selectedPage = ToolsPage(
            sessionKey: sessionKey, userRole: role, listDoos: listDoos);
      }
    });
  }

  void _onSidebarTabSelected(int index) {
    setState(() {
      if (index == 1) {
        _selectedPage = SellerPage(keyToken: sessionKey);
      } else if (index == 2) {
        _selectedPage = AdminPage(sessionKey: sessionKey);
      } else if (index == 3) {
        _selectedPage = OwnerPage(sessionKey: sessionKey, username: username);
      }
    });
    Navigator.pop(context);
  }

  Widget _buildNewsPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. ONLINE & CONNECTIONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardGlass,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderGlass, width: 1),
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
                  Expanded(
                    child: _buildCompactInfoItem(
                      icon: Icons.people,
                      label: "Online",
                      value: "$onlineUsers",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCompactInfoItem(
                      icon: Icons.link,
                      label: "Connections",
                      value: "$activeConnections",
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. NEWS SECTION
          Container(
            width: double.infinity,
            height: 190,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.9),
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final item = newsList[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: cardGlass,
                    border: Border.all(color: borderGlass),
                    boxShadow: [
                      BoxShadow(
                        color: primarySilver.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (item['image'] != null && item['image'].toString().isNotEmpty)
                          NewsMedia(url: item['image']),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.transparent,
                                primarySilver.withOpacity(0.1),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] ?? 'No Title',
                                style: TextStyle(
                                  color: primaryWhite,
                                  fontSize: 16,
                                  fontFamily: "Orbitron",
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: primarySilver.withOpacity(0.8),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['desc'] ?? '',
                                style: TextStyle(
                                  color: accentSilver,
                                  fontFamily: "ShareTechMono",
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // --- NEW BUTTON: JOIN TELEGRAM CHANNEL ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: cardGlass,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderGlass, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: primarySilver.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                icon: const Icon(FontAwesomeIcons.telegram, color: Colors.white, size: 22),
                label: const Text(
                  "Join Vorlexz Stars Info Channel",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Orbitron',
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  _openUrl("https://t.me/Tr4dictXTeam");
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. MANAGE BUG SENDER BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primarySilver, accentSilver],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primarySilver.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.bug_report, color: Colors.white, size: 20),
                label: const Text(
                  "MANAGE BUG SENDER",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Orbitron',
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BugSenderPage(
                        sessionKey: sessionKey,
                        username: username,
                        role: role,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

        ],
      ),
    );
  }

  Widget _buildAccessButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: cardGlass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentSilver.withOpacity(0.4)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: accentSilver, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case "owner":
        return accentSilver;
      case "vip":
        return primarySilver;
      case "reseller":
        return Colors.lightGreenAccent;
      case "premium":
        return Colors.orangeAccent;
      default:
        return lightSilver;
    }
  }

  Widget _buildCompactInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderGlass),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primarySilver.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentSilver, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: accentGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ShareTechMono',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDrawer() {
    return Drawer(
      backgroundColor: bgDark,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. BAGIAN ATAS (HEADER VIDEO & PROFIL)
          Container(
            height: 250,
            color: Colors.black,
            child: Stack(
              children: [
                if (_menuVideoController != null && _menuVideoController!.value.isInitialized)
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _menuVideoController!.value.size.width,
                        height: _menuVideoController!.value.size.height,
                        child: VideoPlayer(_menuVideoController!),
                      ),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: accentSilver, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: primarySilver.withOpacity(0.6),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: ClipOval(
                            child: _profileImage != null
                                ? Image.file(
                              _profileImage!,
                              fit: BoxFit.cover,
                            )
                                : Icon(
                              FontAwesomeIcons.userAstronaut,
                              size: 50,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Orbitron',
                          ),
                        ),
                        Text(
                          role.toUpperCase(),
                          style: TextStyle(
                            color: accentSilver,
                            fontSize: 14,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. BAGIAN BAWAH (DAFTAR MENU)
          Expanded(
            child: Container(
              color: bgDark,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  // MENU SELLER (HANYA RESELLER)
                  if (role == "reseller")
                    _buildDrawerMenuItem(
                      icon: Icons.storefront,
                      label: "Seller Page",
                      onTap: () => _onSidebarTabSelected(1),
                    ),

                  // MENU ADMIN (HANYA ADMIN)
                  if (role == "admin")
                    _buildDrawerMenuItem(
                      icon: Icons.admin_panel_settings,
                      label: "Admin Page",
                      onTap: () => _onSidebarTabSelected(2),
                    ),

                  // MENU OWNER (HANYA OWNER)
                  if (role == "owner")
                    _buildDrawerMenuItem(
                      icon: Icons.workspace_premium,
                      label: "Owner Page",
                      onTap: () => _onSidebarTabSelected(3),
                    ),

                  _buildDrawerMenuItem(
                    icon: Icons.history_rounded,
                    label: "Riwayat Aktivitas",
                    onTap: () {
                      Navigator.pop(context); // Tutup drawer dulu
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RiwayatPage(
                            sessionKey: sessionKey,
                            role: role,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  _buildDrawerMenuItem(
                    icon: Icons.logout,
                    label: "Log Out",
                    isLogout: true,
                    onTap: () async {
                      Navigator.pop(context);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (!mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                            (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isLogout
            ? Colors.red.withOpacity(0.2)
            : cardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLogout ? Colors.red.withOpacity(0.5) : borderGlass,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.redAccent : accentSilver,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isLogout ? Colors.redAccent : primaryWhite,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white38,
          size: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Hai, $username",
          style: TextStyle(
            color: primaryWhite,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            shadows: [
              Shadow(
                color: primarySilver.withOpacity(0.8),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.headset_mic_outlined, color: accentSilver),
            tooltip: 'Customer Service',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ContactPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.userCircle, color: Color(0xFFBDBDBD)),
            tooltip: 'My Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePage(
                    username: username,
                    password: password,
                    role: role,
                    expiredDate: expiredDate,
                    sessionKey: sessionKey,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildCustomDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              bgDark,
              primarySilver.withOpacity(0.1),
              bgDark,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(opacity: _animation, child: _selectedPage),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardGlass,
          border: Border(top: BorderSide(color: borderGlass)),
          boxShadow: [
            BoxShadow(
              color: primarySilver.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: accentSilver,
          unselectedItemColor: accentGrey,
          currentIndex: _bottomNavIndex,
          onTap: _onBottomNavTapped,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.whatsapp), label: "WhatsApp"),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: "Info",),
            BottomNavigationBarItem(icon: Icon(Icons.build_circle_outlined), label: "Tools"),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    _controller.dispose();
    _menuVideoController?.dispose();
    super.dispose();
  }
}

class NewsMedia extends StatefulWidget {
  final String url;
  const NewsMedia({super.key, required this.url});

  @override
  State<NewsMedia> createState() => _NewsMediaState();
}

class _NewsMediaState extends State<NewsMedia> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (_isVideo(widget.url)) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          setState(() {});
          _controller?.setLooping(true);
          _controller?.setVolume(0.0);
          _controller?.play();
        });
    }
  }

  bool _isVideo(String url) {
    return url.endsWith(".mp4") ||
        url.endsWith(".webm") ||
        url.endsWith(".mov") ||
        url.endsWith(".mkv");
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isVideo(widget.url)) {
      if (_controller != null && _controller!.value.isInitialized) {
        return AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFBDBDBD),
          ),
        );
      }
    } else {
      return Image.network(
        widget.url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade800,
          child: const Icon(Icons.error, color: Color(0xFFBDBDBD)),
        ),
      );
    }
  }
}
