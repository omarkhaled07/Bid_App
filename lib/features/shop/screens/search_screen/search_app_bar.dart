import 'package:flutter/material.dart';

class SearchAppBar extends StatefulWidget {
  final Function(String) onSearch;
  final TextEditingController searchController;

  const SearchAppBar({
    super.key,
    required this.onSearch,
    required this.searchController,
  });

  @override
  _SearchAppBarState createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xff1C162E),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            padding: const EdgeInsets.only(left: 10),
            constraints: const BoxConstraints(
              minWidth: 9.15,
              minHeight: 18,
            ),
          ),
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.searchController,
                      decoration: const InputDecoration(
                        hintText: "What are you looking for?",
                        hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      onChanged: (value) {
                        widget.onSearch(value);
                      },
                      onSubmitted: (value) {
                        widget.onSearch(value);
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onSearch(widget.searchController.text);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Icon(Icons.search,
                          color: Colors.teal, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
