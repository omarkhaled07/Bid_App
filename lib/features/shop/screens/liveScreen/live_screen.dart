import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shop_home_screen/shop_home_screen.dart';
import '../cartScreen/cart_screen.dart';
import '../favoriteScreen/favorite_screen.dart';
import '../shop_home_screen/nav_bar/custom_bottom_nav.dart';
import 'live_details.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  _LivePageState createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  bool isLive = false;
  int _currentIndex = 3;

  Future<void> _checkPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (statuses[Permission.camera]!.isDenied ||
        statuses[Permission.microphone]!.isDenied) {
      throw Exception('Camera or microphone permissions denied');
    }
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Get.off(() => ShopHomeScreen());
        break;
      case 1:
        Get.off(() => FavoritesPage());
        break;
      case 2:
        Get.off(() => ShoppingCartPage());
        break;
      case 3:
        Get.off(() => LivePage());
        break;
    }
  }

  Future<void> _startLive() async {
    try {
      await _checkPermissions();
      final isHost = await _determineUserRole();
      Get.to(() => LiveDetailsScreen(isHost: isHost));
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<bool> _determineUserRole() async {
    // يمكنك استبدال هذا بمنطق تحديد الدور الفعلي
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isHost') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Live Streaming", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff080618),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.live_tv,
                    size: 80, color: isLive ? Colors.green : Colors.red),
                const SizedBox(height: 20),
                Text(
                  isLive
                      ? "Live streaming is active"
                      : "No live stream currently",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              child: const Icon(Icons.videocam, color: Colors.white, size: 30),
              onPressed: _startLive,
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
