import 'package:flutter/material.dart';
import 'package:snapmug/core/class/colors.dart';

class CustomDot extends StatefulWidget {
  final bool isSelected;
  const CustomDot({super.key, required this.isSelected});

  @override
  State<CustomDot> createState() => _CustomDotState();
}

class _CustomDotState extends State<CustomDot> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: 4,
      width: widget.isSelected ? 40 : 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: widget.isSelected ? AppColors.yellowColor : Colors.white,
      ),
    );
  }
}
