import 'package:flutter/material.dart';

class LinearVWidget extends StatelessWidget {
  const LinearVWidget({super.key});

   @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0), // Add margin around the widget
      child: Container(
        width: 100, // Fixed width for uniformity
        height: 50, // Fixed height for uniformity
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8), // Optional: rounded corners
        ),
        alignment: Alignment.center, // Center the text
        child: const Text(
          'Linear V', // Widget name
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), // Changed to black for better visibility
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
