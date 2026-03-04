import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_address_screeen.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String uid;
  late Future<List<Map<String, dynamic>>> addressesFuture;

  @override
  void initState() {
    super.initState();
    uid = _auth.currentUser!.uid;
    addressesFuture = _fetchAddresses();
  }

  Future<List<Map<String, dynamic>>> _fetchAddresses() async {
    QuerySnapshot snapshot = await _firestore
        .collection('addresses')
        .where('uid', isEqualTo: uid)
        .get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> _deleteAddress(String docId) async {
    await _firestore.collection('addresses').doc(docId).delete();
    setState(() {
      addressesFuture = _fetchAddresses();
    });
  }

  Future<void> _navigateToAddAddress() async {
    await Get.to(() => AddAddressScreen());
    setState(() {
      addressesFuture = _fetchAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: const Color(0xff080618),
      appBar: AppBar(
        title: Text(isArabic ? "العناوين المحفوظة" : "Saved Addresses"),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                isArabic ? "لم يتم العثور على عناوين" : "No addresses found",
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var address = snapshot.data![index];
              return Card(
                color: Colors.white10,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Directionality(
                  textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      address['country'] ??
                          (isArabic ? "غير متوفر" : "Not available"),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address['city'] ??
                              (isArabic ? "غير متوفر" : "Not available"),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          address['address'] ??
                              (isArabic ? "غير متوفر" : "Not available"),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteAddress(address['id']),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddAddress,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
