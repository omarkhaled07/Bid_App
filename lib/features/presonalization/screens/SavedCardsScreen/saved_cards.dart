import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_card_screen.dart';

class SavedCardsScreen extends StatefulWidget {
  const SavedCardsScreen({super.key});

  @override
  State<SavedCardsScreen> createState() => _SavedCardsScreenState();
}

class _SavedCardsScreenState extends State<SavedCardsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String uid;
  late Future<List<Map<String, dynamic>>> cardsFuture;

  @override
  void initState() {
    super.initState();
    uid = _auth.currentUser!.uid;
    cardsFuture = _fetchCards();
  }

  Future<List<Map<String, dynamic>>> _fetchCards() async {
    QuerySnapshot snapshot =
        await _firestore.collection('cards').where('uid', isEqualTo: uid).get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> _deleteCard(String docId) async {
    await _firestore.collection('cards').doc(docId).delete();
    setState(() {
      cardsFuture = _fetchCards();
    });
  }

  Future<void> _navigateToAddCard() async {
    await Get.to(() => AddCardScreen());
    setState(() {
      cardsFuture = _fetchCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff080618),
      appBar: AppBar(
        title: Text("Saved Cards"),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text("No saved cards found",
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var card = snapshot.data![index];
              return Card(
                color: Colors.white10,
                margin: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text("**** **** **** ${card['last4']}",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  subtitle: Text("Expires: ${card['expiryDate']}",
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteCard(card['id']),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddCard,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
