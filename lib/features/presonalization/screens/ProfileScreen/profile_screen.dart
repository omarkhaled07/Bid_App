import 'package:bid/features/presonalization/screens/EditProfileScreen/edit_profile_screen.dart';
import 'package:bid/features/presonalization/screens/SavedCardsScreen/saved_cards.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../AccountInfoScreen/account_info_screen.dart';
import '../ChangeEmailScreen/change_email.dart';
import '../changePasswordScreen/change_password.dart';
import '../SavedAddressesScreen/saved_addresses_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  RxInt followersCount = 0.obs;
  RxBool isFollowing = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var userData = {}.obs;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      String? uid = _auth.currentUser?.uid;
      if (uid == null) {
        print("⚠️ No user logged in!");
        return;
      }

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        print("⚠️ User document does not exist!");
        return;
      }

      userData.value = userDoc.data() as Map<String, dynamic>;
      print("✅ User data loaded: $userData");

      if (!userData.containsKey('uid')) {
        userData['uid'] = uid; // تعيين الـ UID إذا لم يكن موجودًا
      }

      List followers = userData['followers'] ?? [];
      followersCount.value = followers.length;
      isFollowing.value = followers.contains(uid);
    } catch (e) {
      print("❌ Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff080618),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Get.to(EditProfileScreen());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (userData.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildProfileHeader(),
              _buildMenuList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              "https://source.unsplash.com/random/900x400"), // صورة الغلاف
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(userData['profileImage'] ?? ""),
          ),
          SizedBox(height: 10),
          Text(
            userData['name'] ?? "Loading...",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            "@${userData['email']?.split('@')[0]}",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => ElevatedButton.icon(
                    onPressed: () async {
                      print("Current User ID: ${_auth.currentUser!.uid}");
                      print("Profile User ID: ${userData['uid']}");

                      if (userData['uid'] == null) {
                        Get.snackbar("Error", "User data is incomplete!",
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                        return;
                      }

                      await toggleFollow();
                    },
                    icon: Icon(
                      isFollowing.value
                          ? Icons.person_remove
                          : Icons.person_add,
                      color: Colors.white,
                    ),
                    label: Text(
                      isFollowing.value ? "Unfollow" : "Follow",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing.value
                          ? Colors.deepPurple
                          : Colors.indigo, // لون جديد متناسق
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  )),
              SizedBox(width: 15),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.group, color: Colors.white, size: 18),
                    SizedBox(width: 5),
                    Obx(() => Text(
                          "$followersCount",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconButton(Icons.store, "Favorite Stores"),
              SizedBox(width: 20),
              _buildIconButton(Icons.favorite, "Wishlist"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        Text(text, style: TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildMenuList() {
    return Column(
      children: [
        _buildMenuItem(Icons.account_circle, "Account Info"),
        _buildMenuItem(Icons.lock, "Change Password"),
        _buildMenuItem(Icons.email, "Change Email"),
        _buildMenuItem(Icons.location_on, "Saved Addresses"),
        _buildMenuItem(Icons.credit_card, "Saved Cards"),
        _buildMenuItem(Icons.shopping_bag, "Orders"),
        _buildMenuItem(Icons.shopping_cart, "Mazad"),
        _buildMenuItem(Icons.group, "Join BID Family"),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
      onTap: () {
        if (title == "Account Info") {
          Get.to(() =>
              AccountInfoScreen(userData: Map<String, dynamic>.from(userData)));
        } else if (title == "Change Password") {
          Get.to(() => ChangePasswordScreen());
        } else if (title == "Change Email") {
          Get.to(() => ChangeEmailScreen());
        } else if (title == "Saved Addresses") {
          Get.to(() => SavedAddressesScreen());
        } else if (title == "Saved Cards") {
          Get.to(() => SavedCardsScreen());
        }
      },
    );
  }

  Future<void> toggleFollow() async {
    try {
      String? currentUserId = _auth.currentUser?.uid;
      String? profileUserId = userData['uid'];

      if (currentUserId == null || profileUserId == null) {
        print("⚠️ User data is incomplete!");
        Get.snackbar("Error", "User data is incomplete!",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      DocumentReference userRef =
          _firestore.collection('users').doc(profileUserId);

      if (isFollowing.value) {
        await userRef.update({
          'followers': FieldValue.arrayRemove([currentUserId])
        });
        followersCount.value--;
      } else {
        await userRef.update({
          'followers': FieldValue.arrayUnion([currentUserId])
        });
        followersCount.value++;
      }

      isFollowing.value = !isFollowing.value;
      print("✅ Follow status updated successfully!");
    } catch (e) {
      print("❌ Error updating follow status: $e");
    }
  }
}
