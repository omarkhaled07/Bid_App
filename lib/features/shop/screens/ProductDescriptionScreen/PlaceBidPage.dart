import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlaceBidPage extends StatefulWidget {
  final String productId;
  final double currentMaxPrice;

  const PlaceBidPage({
    Key? key,
    required this.productId,
    required this.currentMaxPrice,
  }) : super(key: key);

  @override
  _PlaceBidPageState createState() => _PlaceBidPageState();
}

class _PlaceBidPageState extends State<PlaceBidPage> {
  final TextEditingController _bidController = TextEditingController();
  bool isLoading = false;
  String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  String userName = "Anonymous";
  String? sellerId;
  String? highestBidderId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? "Anonymous";
        });
      }

      DocumentSnapshot productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();
      if (productDoc.exists) {
        setState(() {
          sellerId = productDoc['sellerId'];
          highestBidderId = productDoc['highestBidderId'];
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> _submitBid() async {
    double? bidAmount = double.tryParse(_bidController.text);
    if (bidAmount == null || bidAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid amount!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (sellerId == userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You cannot bid on your own product!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (highestBidderId == userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You are already the highest bidder!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    double newMaxPrice = widget.currentMaxPrice + bidAmount;

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
        'maxPrice': newMaxPrice,
        'highestBidderId': userId,
        'highestBidder': userName,
      });

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .collection('bids')
          .add({
        'userId': userId,
        'name': userName,
        'price': newMaxPrice,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to place bid: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSeller = sellerId == userId;
    bool isHighestBidder = highestBidderId == userId;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Place a Bid"),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Current Bid Card
              Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Current Highest Bid",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "\$${widget.currentMaxPrice.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (isHighestBidder) ...[
                      const SizedBox(height: 8),
                      Chip(
                        label: const Text("You are the highest bidder"),
                        backgroundColor:
                        Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Seller Warning (if applicable)
            if (isSeller)
        Container(
        padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
    color: Colors.red.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
    color: Colors.red.withOpacity(0.3),
    ),),
    child: Row(
    children: [
    Icon(
    Icons.warning_amber_rounded,
    color: Colors.red[400],
    ),
    const SizedBox(width: 12),
    Expanded(
    child: Text(
    "You are the owner of this product. Owners cannot place bids.",
    style: TextStyle(
    color: Colors.red[700],
    fontWeight: FontWeight.w500,
    ),
    ),
    ),
    ],
    ),
    ),
    const SizedBox(height: 24),

    // Bid Input Section
    Text(
    "Enter your bid amount",
    style: Theme.of(context).textTheme.titleMedium,
    ),
    const SizedBox(height: 8),
    TextField(
    controller: _bidController,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
    hintText: "Amount to add to current bid",
    prefixIcon: const Icon(Icons.attach_money),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    filled: true,
    fillColor: Theme.of(context).colorScheme.surfaceVariant,
    ),
    style: Theme.of(context).textTheme.titleLarge?.copyWith(
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 16),
    Text(
      "Your total bid will be: \$${(widget.currentMaxPrice + (double.tryParse(_bidController.text) ?? 0)).toStringAsFixed(2)}",
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: Colors.grey[600],
    ),
    textAlign: TextAlign.center,
    ),
    const SizedBox(height: 32),

    // Submit Button
    ElevatedButton(
    onPressed: (isLoading || isSeller) ? null : _submitBid,
    style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Colors.white,
    elevation: 2,
    ),
    child: isLoading
    ? const SizedBox(
    width: 24,
    height: 24,
    child: CircularProgressIndicator(
    color: Colors.white,
    strokeWidth: 3,
    ),
    )
        : const Text(
    "PLACE BID",
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    ),
    ),
    ),

    // Terms Info
    const SizedBox(height: 24),
    Text(
    "By placing a bid, you agree to our Terms of Service and confirm this is a binding offer.",
    style: Theme.of(context).textTheme.bodySmall?.copyWith(
    color: Colors.grey[500],
    ),
    textAlign: TextAlign.center,
    ),
    ],
    ),
    ),
    );
  }
}