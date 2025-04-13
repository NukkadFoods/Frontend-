import 'package:flutter/material.dart';

class Category extends StatefulWidget {
  final String imagePath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap; // Added onTap callback

  Category({
    super.key,
    required this.imagePath,
    required this.label,
    this.isSelected = false,
    required this.onTap, // Required onTap parameter
  });

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? Color.fromARGB(255, 199, 241, 201)
              : Color.fromARGB(244, 244, 244, 244),
          border: Border.all(
            color: const Color.fromARGB(255, 221, 221, 221),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Image.asset(
              widget.imagePath,
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 8.0),
            Text(widget.label),
          ],
        ),
      ),
    );
  }
}