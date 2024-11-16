import 'package:flutter/material.dart';

class MobileFrame extends StatefulWidget {
  const MobileFrame({super.key});

  @override
  _MobileFrameState createState() => _MobileFrameState();
}

class _MobileFrameState extends State<MobileFrame> {
  List<Map<String, dynamic>> droppedWidgets = []; // Store widget data

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth * 0.8;
            final height = constraints.maxHeight * 0.8;
            final borderRadius = width * 0.05; // Responsive corner radius

            return Stack(
              children: [
                // Mobile frame
                CustomPaint(
                  size: Size(width, height),
                  painter: MobileFramePainter(borderRadius: borderRadius),
                ),
                // Status Bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: height * 0.05, // Responsive height for status bar
                    decoration: BoxDecoration(
                      color: Colors.blue[900], // Darker blue for the status bar
                      borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          spreadRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.signal_cellular_4_bar, color: Colors.white),
                            SizedBox(width: 4),
                            Icon(Icons.wifi, color: Colors.white),
                          ],
                        ),
                        Text('100%', style: TextStyle(color: Colors.white)),
                        Icon(Icons.battery_full, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                // Draggable area
                Positioned(
                  top: height * 0.05, // Adjust based on the status bar height
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: DragTarget<String>(
                    onAcceptWithDetails: (details) {
                      setState(() {
                        // Create a new widget entry and add it to the list
                        droppedWidgets.add({
                          'type': details.data,
                          'position': {
                            'left': 20.0 + (droppedWidgets.length % 3) * 120,
                            'top': 20.0 + (droppedWidgets.length ~/ 3) * 100
                          }
                        });
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Stack(
                        children: [
                          // Display the dropped widgets
                          ...droppedWidgets.map((widgetData) {
                            return Positioned(
                              left: widgetData['position']['left'],
                              top: widgetData['position']['top'],
                              child: Container(
                                margin: const EdgeInsets.all(4.0),
                                width: width * 0.25,
                                height: height * 0.15,
                                // Placeholder for widget creation
                                color: Colors.grey[300], // Placeholder color for the widget
                              ),
                            );
                          }),
                          // Feedback for dragging
                          if (candidateData.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Release to drop here'),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class MobileFramePainter extends CustomPainter {
  final double borderRadius;

  MobileFramePainter({required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final Rect mobileRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final RRect roundedRect = RRect.fromRectAndRadius(mobileRect, Radius.circular(borderRadius));

    // Draw the frame
    canvas.drawRRect(roundedRect, paint);

    // Draw the screen area
    final screenRect = Rect.fromLTWH(10, 10, size.width - 20, size.height - 20);
    final RRect screenRoundedRect = RRect.fromRectAndRadius(screenRect, const Radius.circular(20));
    paint.color = Colors.grey.shade100;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(screenRoundedRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
