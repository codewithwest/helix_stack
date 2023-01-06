import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({
    required this.controller,
    required this.focusNode,
    Key? key,
  }) : super(key: key);
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 8,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: Colors.white38,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: null,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            GestureDetector(
              onTap: controller.clear,
              child: const Icon(
                Icons.clear_rounded,
                size: 18,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
