import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'PlaceBidPage.dart';

class ProductDescriptionScreen extends StatefulWidget {
  final String productId;
  final Function(bool)? onFavoriteToggle;
  const ProductDescriptionScreen({
    super.key,
    required this.productId,
    this.onFavoriteToggle,
  });

  @override
  _ProductDescriptionScreenState createState() =>
      _ProductDescriptionScreenState();
}

class _ProductDescriptionScreenState extends State<ProductDescriptionScreen> {
  DocumentSnapshot? productData;
  bool isLoading = true;
  Duration remainingTime = Duration.zero;
  bool isAuction = false;
  List<Map<String, dynamic>> bids = [];
  bool isAuctionEnded = false;
  bool isFinalized = false;
  bool isFavorite = false;
  bool isAddingToCart = false;
  bool isPlacingBid = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _checkAuctionStatus().then((_) => _fetchProductData());
  }

  Future<void> _checkFavoriteStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.productId)
        .get();

    if (mounted) {
      setState(() {
        isFavorite = doc.exists;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please sign in to add favorites"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      setState(() {
        isFavorite = !isFavorite;
      });

      if (widget.onFavoriteToggle != null) {
        widget.onFavoriteToggle!(isFavorite);
      }

      final favoritesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.productId);

      if (isFavorite) {
        await favoritesRef.set({
          'productId': widget.productId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await favoritesRef.delete();
      }
    } catch (e) {
      setState(() {
        isFavorite = !isFavorite;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update favorite: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkAuctionStatus() async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();
    if (doc.exists && mounted) {
      final status = doc.get('status');
      setState(() {
        isAuctionEnded = status == 'sold' || status == 'finished';
      });
    }
  }

  void _startCountdownTimer(Timestamp endTime) {
    DateTime endDateTime = endTime.toDate();
    Duration duration = endDateTime.difference(DateTime.now());

    if (duration.isNegative && !isFinalized) {
      setState(() {
        isAuctionEnded = true;
      });
      _finalizeAuction();
    } else if (!isFinalized) {
      setState(() {
        remainingTime = duration;
      });
      Future.delayed(duration, () {
        if (!isFinalized && mounted) {
          setState(() {
            isAuctionEnded = true;
          });
          _finalizeAuction();
        }
      });
    }
  }

  Future<void> _finalizeAuction() async {
    if (isLoading || productData == null || isFinalized || !mounted) return;

    try {
      isFinalized = true;
      await _fetchBids();

      if (bids.isNotEmpty) {
        String winnerId = bids.first['userId'];
        String winnerName = bids.first['name'];

        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .update({
          'status': 'sold',
          'highestBidder': winnerName,
        });

        await FirebaseFirestore.instance
            .collection('carts')
            .doc(winnerId)
            .collection('items')
            .add({
          'productId': widget.productId,
          'title': productData?.get('title') ?? '',
          'price': productData?.get('maxPrice') ?? 0,
          'quantity': 1,
          'imageUrl': productData?.get('imageUrl') ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          isAuctionEnded = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Auction ended! Product sold to $winnerName."),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .update({
          'status': 'finished',
        });

        setState(() {
          isAuctionEnded = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Auction ended with no bids."),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      await _fetchProductData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error finalizing auction: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchProductData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          productData = doc;
          isLoading = false;
          isAuction = doc.get('isAuction') ?? false;
          final status = doc.get('status');
          isAuctionEnded = status == 'sold' || status == 'finished';

          if (isAuction && !isAuctionEnded) {
            _startCountdownTimer(doc.get('endTime') as Timestamp);
            _fetchBids();
          }
        });
      } else if (mounted) {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load product: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchBids() async {
    try {
      QuerySnapshot bidsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .collection('bids')
          .orderBy('price', descending: true)
          .get();

      if (mounted) {
        setState(() {
          bids = bidsSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          bids = [];
        });
      }
    }
  }

  Future<void> _refresh() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      isFinalized = false;
      bids = [];
    });

    await _checkFavoriteStatus();
    await _checkAuctionStatus();
    await _fetchProductData();
    if (isAuction && !isAuctionEnded) {
      await _fetchBids();
    }
  }

  Future<void> _addToCart() async {
    if (isAddingToCart) return;

    setState(() {
      isAddingToCart = true;
    });

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You need to sign in to add to cart."),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        isAddingToCart = false;
      });
      return;
    }

    try {
      QuerySnapshot cartItems = await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('items')
          .where('productId', isEqualTo: widget.productId)
          .get();

      if (cartItems.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("This item is already in your cart."),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          isAddingToCart = false;
        });
        return;
      }

      await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('items')
          .add({
        'productId': widget.productId,
        'title': productData?.get('title') ?? '',
        'price': productData?.get('price') ?? productData?.get('maxPrice') ?? 0,
        'quantity': 1,
        'imageUrl': productData?.get('imageUrl') ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Item added to cart successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add to cart: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isAddingToCart = false;
        });
      }
    }
  }

  void _shareProduct() {
    if (productData == null) return;

    Share.share(
      'Check out this ${productData!.get('isAuction') ? 'auction' : 'product'}:'
      '\n\n${productData!.get('title')}'
      '\n\nPrice: \$${productData!.get('isAuction') ? productData!.get('maxPrice') : productData!.get('price')}'
      '\n\n${productData!.get('description')}',
      subject: 'Look at this amazing product!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text("Product Details",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareProduct,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: Colors.orange,
        backgroundColor: Colors.black,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : productData == null
                ? const Center(
                    child: Text("Product not found",
                        style: TextStyle(color: Colors.white)))
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  productData!.get('imageUrl') ??
                                      "https://via.placeholder.com/250",
                                  height: 250,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 250,
                                      color: Colors.grey[900],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 250,
                                      color: Colors.grey[900],
                                      child: const Center(
                                        child: Icon(Icons.error,
                                            color: Colors.red, size: 50),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (isAuction)
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "AUCTION",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  productData!.get('title') ?? "Product Title",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                isAuction
                                    ? "\$${productData!.get('maxPrice')?.toStringAsFixed(2) ?? '0.00'}"
                                    : "\$${productData!.get('price')?.toStringAsFixed(2) ?? '0.00'}",
                                style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Category: ${productData!.get('category') ?? 'Uncategorized'}",
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            productData!.get('description') ??
                                "No description available.",
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey[700]),
                          const SizedBox(height: 10),
                          if (isAuction) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Start Price: \$${productData!.get('startPrice')?.toStringAsFixed(2) ?? '0.00'}",
                                      style: TextStyle(
                                          color: Colors.orangeAccent,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Highest Bid: \$${productData!.get('maxPrice')?.toStringAsFixed(2) ?? '0.00'}",
                                      style: TextStyle(
                                          color: Colors.greenAccent,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                if (!isAuctionEnded)
                                  CircularCountDownTimer(
                                    duration: remainingTime.inSeconds,
                                    initialDuration: 0,
                                    width: 90,
                                    height: 90,
                                    ringColor: Colors.grey.shade800,
                                    fillColor: Colors.orange,
                                    backgroundColor: Colors.black,
                                    strokeWidth: 6.0,
                                    textStyle: const TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    isReverse: true,
                                    isTimerTextShown: true,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Divider(color: Colors.grey[700]),
                            const SizedBox(height: 15),
                            if (bids.isNotEmpty) ...[
                              const Text(
                                "Bids History:",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              ...bids.map((bid) => ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        bid['userImage'] ??
                                            "https://via.placeholder.com/50",
                                      ),
                                    ),
                                    title: Text(
                                      bid['name'] ?? 'Anonymous',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      "Bid: \$${bid['price']?.toStringAsFixed(2) ?? '0.00'}",
                                      style: TextStyle(color: Colors.grey[400]),
                                    ),
                                    trailing: Text(
                                      _formatTime(bid['createdAt']?.toDate()),
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12),
                                    ),
                                  )),
                              const SizedBox(height: 15),
                              Divider(color: Colors.grey[700]),
                              const SizedBox(height: 15),
                            ] else if (!isAuctionEnded) ...[
                              const Text(
                                "No Bids Yet",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                              const SizedBox(height: 15),
                            ],
                            if (isAuctionEnded) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      productData!.get('status') == 'sold'
                                          ? Icons.check_circle
                                          : Icons.highlight_off,
                                      color:
                                          productData!.get('status') == 'sold'
                                              ? Colors.green
                                              : Colors.red,
                                      size: 30,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        productData!.get('status') == 'sold'
                                            ? "Sold to ${productData!.get('highestBidder')} for \$${productData!.get('maxPrice')?.toStringAsFixed(2) ?? '0.00'}"
                                            : "Auction ended with no bids",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                            ],
                          ],
                          const Text(
                            "Seller Information:",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(
                                    productData!.get('sellerImage') ??
                                        "https://via.placeholder.com/50"),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productData!.get('seller') ??
                                          "Unknown Seller",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      productData!.get('sellerAddress') ??
                                          "No address provided",
                                      style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Listed: ${_formatTime(productData!.get('createdAt')?.toDate())}",
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: isAuction
                                ? ElevatedButton.icon(
                                    onPressed: isAuctionEnded
                                        ? null
                                        : () {
                                            setState(() {
                                              isPlacingBid = true;
                                            });
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PlaceBidPage(
                                                  productId: widget.productId,
                                                  currentMaxPrice: productData
                                                          ?.get('maxPrice')
                                                          ?.toDouble() ??
                                                      0,
                                                ),
                                              ),
                                            ).then((_) {
                                              if (mounted) {
                                                setState(() {
                                                  isPlacingBid = false;
                                                });
                                                _refresh();
                                              }
                                            });
                                          },
                                    icon: isPlacingBid
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.black,
                                            ),
                                          )
                                        : const Icon(Icons.gavel, size: 18),
                                    label: Text(
                                      isAuctionEnded
                                          ? "Auction Ended"
                                          : isPlacingBid
                                              ? "Loading..."
                                              : "Place a Bid",
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.black),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 24),
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  )
                                : ElevatedButton.icon(
                                    onPressed:
                                        isAddingToCart ? null : _addToCart,
                                    icon: isAddingToCart
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(FontAwesomeIcons.cartPlus,
                                            size: 18),
                                    label: Text(
                                      isAddingToCart
                                          ? "Adding..."
                                          : "Add to Cart",
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 24),
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) return "Unknown time";
    return "${date.day}/${date.month}/${date.year}";
  }
}

