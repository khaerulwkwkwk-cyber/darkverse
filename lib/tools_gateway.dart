import 'dart:ui';
import 'package:flutter/material.dart';
import 'manage_server.dart';
import 'wifi_internal.dart';
import 'wifi_external.dart';
import 'ddos_panel.dart';
import 'nik_check.dart';
import 'tiktok_page.dart';
import 'instagram_page.dart';
import 'qr_gen.dart';
import 'domain_page.dart';
import 'spam_ngl.dart';

class ToolsPage extends StatelessWidget {
  final String sessionKey;
  final String userRole;
  final List<Map<String, dynamic>> listDoos;

  const ToolsPage({
    super.key,
    required this.sessionKey,
    required this.userRole,
    required this.listDoos,
  });

  // --- Warna Tema Abu-Abu Silver ---
  final Color primaryDark = const Color(0xFF1A1A1A); // Dark background
  final Color primarySilver = const Color(0xFF757575); // Silver tua
  final Color accentSilver = const Color(0xFFBDBDBD); // Silver aksen lebih terang
  final Color lightSilver = const Color(0xFFE0E0E0); // Silver lebih terang untuk highlight
  final Color primaryWhite = Colors.white;
  final Color accentGrey = Colors.grey;
  final Color cardDark = const Color(0xFF2C2C2C); // Dark silver card

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            // === HEADER ===
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primarySilver.withOpacity(0.3), // Diubah ke silver
                    accentSilver.withOpacity(0.2), // Diubah ke silver
                    primarySilver.withOpacity(0.3), // Diubah ke silver
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                border: Border.all(color: primarySilver.withOpacity(0.3)), // Diubah ke silver
                boxShadow: [
                  BoxShadow(
                    color: primarySilver.withOpacity(0.2), // Diubah ke silver
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.build_circle_outlined,
                          color: primaryWhite, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        "TOOLS DASHBOARD",
                        style: TextStyle(
                          color: primaryWhite,
                          fontSize: 20,
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: primarySilver.withOpacity(0.8), // Diubah ke silver
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Advanced Security & OSINT Tools",
                    style: TextStyle(
                      color: lightSilver, // Diubah ke silver
                      fontSize: 14,
                      fontFamily: 'ShareTechMono',
                    ),
                  ),
                ],
              ),
            ),

            // === CATEGORY CARDS ===
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    // DDoS Tools
                    _buildToolCard(
                      icon: Icons.flash_on,
                      title: "DDoS Tools",
                      subtitle: "Attack & Server",
                      color: primaryWhite,
                      gradient: [
                        primarySilver.withOpacity(0.3), // Diubah ke silver
                        accentSilver.withOpacity(0.2), // Diubah ke silver
                      ],
                      onTap: () => _showDDoSTools(context),
                    ),

                    // Network Tools
                    _buildToolCard(
                      icon: Icons.wifi,
                      title: "Network",
                      subtitle: "WiFi & Spam",
                      color: primaryWhite,
                      gradient: [
                        primarySilver.withOpacity(0.3), // Diubah ke silver
                        accentSilver.withOpacity(0.2), // Diubah ke silver
                      ],
                      onTap: () => _showNetworkTools(context),
                    ),

                    // OSINT Tools
                    _buildToolCard(
                      icon: Icons.search,
                      title: "OSINT",
                      subtitle: "Investigation",
                      color: primaryWhite,
                      gradient: [
                        primarySilver.withOpacity(0.3), // Diubah ke silver
                        accentSilver.withOpacity(0.2), // Diubah ke silver
                      ],
                      onTap: () => _showOSINTTools(context),
                    ),

                    // Media Downloader
                    _buildToolCard(
                      icon: Icons.download,
                      title: "Downloader",
                      subtitle: "Social Media",
                      color: primaryWhite,
                      gradient: [
                        primarySilver.withOpacity(0.3), // Diubah ke silver
                        accentSilver.withOpacity(0.2), // Diubah ke silver
                      ],
                      onTap: () => _showDownloaderTools(context),
                    ),

                    // Additional Tools
                    _buildToolCard(
                      icon: Icons.build,
                      title: "Utilities",
                      subtitle: "Extra Tools",
                      color: primaryWhite,
                      gradient: [
                        primarySilver.withOpacity(0.3), // Diubah ke silver
                        accentSilver.withOpacity(0.2), // Diubah ke silver
                      ],
                      onTap: () => _showUtilityTools(context),
                    ),

                    // Quick Access
                    _buildToolCard(
                      icon: Icons.rocket_launch,
                      title: "Quick Access",
                      subtitle: "Favorites",
                      color: primaryWhite,
                      gradient: [
                        primarySilver.withOpacity(0.3), // Diubah ke silver
                        accentSilver.withOpacity(0.2), // Diubah ke silver
                      ],
                      onTap: () => _showQuickAccess(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primarySilver.withOpacity(0.4), width: 1), // Diubah ke silver
            boxShadow: [
              BoxShadow(
                color: primarySilver.withOpacity(0.2), // Diubah ke silver
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primarySilver, accentSilver], // Diubah ke silver
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: lightSilver.withOpacity(0.3)), // Diubah ke silver
                    boxShadow: [
                      BoxShadow(
                        color: primarySilver.withOpacity(0.3), // Diubah ke silver
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: primaryWhite, size: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: primaryWhite,
                    fontSize: 13,
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: lightSilver, // Diubah ke silver
                    fontSize: 12,
                    fontFamily: 'ShareTechMono',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDDoSTools(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(color: primarySilver.withOpacity(0.3)), // Diubah ke silver
          boxShadow: [
            BoxShadow(
              color: primarySilver.withOpacity(0.2), // Diubah ke silver
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primarySilver, accentSilver], // Diubah ke silver
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.flash_on, color: primaryWhite),
                  const SizedBox(width: 12),
                  Text(
                    "DDoS Tools",
                    style: TextStyle(
                      color: primaryWhite,
                      fontSize: 20,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildToolOption(
                      icon: Icons.flash_on,
                      label: "Attack Panel",
                      color: lightSilver, // Diubah ke silver
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AttackPanel(
                              sessionKey: sessionKey,
                              listDoos: listDoos,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.dns,
                      label: "Manage Server",
                      color: lightSilver, // Diubah ke silver
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ManageServerPage(keyToken: sessionKey),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNetworkTools(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(color: primarySilver.withOpacity(0.3)), // Diubah ke silver
          boxShadow: [
            BoxShadow(
              color: primarySilver.withOpacity(0.2), // Diubah ke silver
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primarySilver, accentSilver], // Diubah ke silver
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.wifi, color: primaryWhite),
                  const SizedBox(width: 12),
                  Text(
                    "Network Tools",
                    style: TextStyle(
                      color: primaryWhite,
                      fontSize: 20,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildToolOption(
                      icon: Icons.newspaper_outlined,
                      label: "Spam NGL",
                      color: lightSilver, // Diubah ke silver
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => NglPage()),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.wifi_off,
                      label: "WiFi Killer (Internal)",
                      color: lightSilver, // Diubah ke silver
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => WifiKillerPage()),
                        );
                      },
                    ),
                    if (userRole == "vip" || userRole == "owner")
                      _buildToolOption(
                        icon: Icons.router,
                        label: "WiFi Killer (External)",
                        color: lightSilver, // Diubah ke silver
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WifiInternalPage(sessionKey: sessionKey),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOSINTTools(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(color: primarySilver.withOpacity(0.3)), // Diubah ke silver
          boxShadow: [
            BoxShadow(
              color: primarySilver.withOpacity(0.2), // Diubah ke silver
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primarySilver, accentSilver], // Diubah ke silver
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: primaryWhite),
                  const SizedBox(width: 12),
                  Text(
                    "OSINT Tools",
                    style: TextStyle(
                      color: primaryWhite,
                      fontSize: 20,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildToolOption(
                      icon: Icons.badge,
                      label: "NIK Detail",
                      color: lightSilver, // Diubah ke silver
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NikCheckerPage()),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.domain,
                      label: "Domain OSINT",
                      color: lightSilver, // Diubah ke silver
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DomainOsintPage()),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.person_search,
                      label: "Phone Lookup",
                      color: lightSilver, // Diubah ke silver
                      onTap: () => _showComingSoon(context),
                    ),
                    _buildToolOption(
                      icon: Icons.email,
                      label: "Email OSINT",
                      color: lightSilver, // Diubah ke silver
                      onTap: () => _showComingSoon(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDownloaderTools(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(color: primarySilver.withOpacity(0.3)), // Diubah ke silver
          boxShadow: [
            BoxShadow(
              color: primarySilver.withOpacity(0.2), // Diubah ke silver
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primarySilver, accentSilver], // Diubah ke silver
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.download, color: primaryWhite),
                  const SizedBox(width: 12),
                  Text(
                    "Media Downloader",
                    style: TextStyle(
                      color: primaryWhite,
                      fontSize: 20,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildToolOption(
                      icon: Icons.video_library,
                      label: "TikTok Downloader",
                      color: lightSilver, // Diubah ke silver
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TiktokDownloaderPage()),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.camera_alt,
                      label: "Instagram Downloader",
                      color: lightSilver, // Diubah ke silver
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const InstagramDownloaderPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUtilityTools(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(color: primarySilver.withOpacity(0.3)), // Diubah ke silver
          boxShadow: [
            BoxShadow(
              color: primarySilver.withOpacity(0.2), // Diubah ke silver
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primarySilver, accentSilver], // Diubah ke silver
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.build, color: primaryWhite),
                  const SizedBox(width: 12),
                  Text(
                    "Utility Tools",
                    style: TextStyle(
                      color: primaryWhite,
                      fontSize: 20,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildToolOption(
                      icon: Icons.qr_code,
                      label: "QR Generator",
                      color: lightSilver, // Diubah ke silver
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QrGeneratorPage()),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.security,
                      label: "IP Scanner",
                      color: lightSilver, // Diubah ke silver
                      onTap: () => _showComingSoon(context),
                    ),
                    _buildToolOption(
                      icon: Icons.network_check,
                      label: "Port Scanner",
                      color: lightSilver, // Diubah ke silver
                      onTap: () => _showComingSoon(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickAccess(BuildContext context) {
    _showComingSoon(context);
  }

  Widget _buildToolOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: cardDark,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: primarySilver.withOpacity(0.3)), // Diubah ke silver
      ),
      elevation: 4,
      shadowColor: primarySilver.withOpacity(0.2), // Diubah ke silver
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primarySilver.withOpacity(0.2), // Diubah ke silver
            shape: BoxShape.circle,
            border: Border.all(color: primarySilver.withOpacity(0.3)), // Diubah ke silver
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: primaryWhite,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: primarySilver.withOpacity(0.2), // Diubah ke silver
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_forward_ios, color: color, size: 14),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.hourglass_top, color: primaryWhite),
            SizedBox(width: 8),
            Text(
              'Feature Coming Soon!',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.bold,
                color: primaryWhite,
              ),
            ),
          ],
        ),
        backgroundColor: primarySilver, // Diubah ke silver
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
