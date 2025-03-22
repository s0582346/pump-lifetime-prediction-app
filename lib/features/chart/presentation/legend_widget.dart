import 'package:flutter/material.dart';

 
// Source: ChatGPT: ChatGPT o3-mini.high, 22-03-2025
// Prompt: Can you create a custom legend widget for a line and bar chart in Flutter? 
//          There are more for items, so arrange the first two at the top and the remaining 
//          ones at the bottom. The legend box is placed inside a SingleChildScrollView > ConstrainedBox, 
//          which should provide basic responsiveness. However, if you think additional layout adjustments 
//          are needed to better support various screen sizes, please include those improvements.


class LegendItem {
  final String label;
  final Color color;
  final bool isDashed;
  final bool isLine; // true for line indicator, false for bar

  LegendItem({
    required this.label,
    required this.color,
    this.isDashed = false,
    this.isLine = true,
  });
}

/// The custom legend widget.
/// It splits the legend items into two sections: 
/// the first two items at the top and the remaining ones at the bottom.
class LegendWidget extends StatelessWidget {
  final List<LegendItem> legendItems;

  const LegendWidget({Key? key, required this.legendItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Partition the items: first two on top, the rest on bottom.
    final topItems = legendItems.take(2).toList();
    final bottomItems = legendItems.skip(2).toList();

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // Ensure the box takes at least the full width of the screen.
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Top legend row: using LayoutBuilder to adjust layout based on available width.
              LayoutBuilder(
                builder: (context, constraints) {
                  // If the width is very narrow, stack the two items vertically.
                  if (constraints.maxWidth < 300) {
                    return Column(
                      children: topItems
                          .map((item) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: _LegendTile(item: item),
                              ))
                          .toList(),
                    );
                  } else {
                    // Otherwise, show them in a row.
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          topItems.map((item) => _LegendTile(item: item)).toList(),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              // Bottom legend items in a Wrap for responsiveness.
                 LayoutBuilder(
                builder: (context, constraints) {
                  // If the width is very narrow, stack the two items vertically.
                  if (constraints.maxWidth < 300) {
                    return Column(
                      children: bottomItems
                          .map((item) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: _LegendTile(item: item),
                              ))
                          .toList(),
                    );
                  } else {
                    // Otherwise, show them in a row.
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          bottomItems.map((item) => _LegendTile(item: item)).toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small widget that represents a single legend tile with an indicator and a label.
class _LegendTile extends StatelessWidget {
  final LegendItem item;

  const _LegendTile({Key? key, required this.item}) : super(key: key);

  /// Build the colored indicator (line or bar). 
  Widget _buildIndicator(BuildContext context) {
    // Set a base size for the indicator.
    const double width = 40;
    const double lineHeight = 4;
    if (item.isLine) {
      if (item.isDashed) {
        // Use a CustomPaint for dashed lines.
        return CustomPaint(
          size: const Size(width, lineHeight),
          painter: DashedLinePainter(color: item.color, strokeWidth: lineHeight),
        );
      } else {
        return Container(
          width: width,
          height: lineHeight,
          color: item.color,
        );
      }
    } else {
      // For bar charts, display a rectangle.
      return Container(
        width: width,
        height: 16,
        color: item.color,
      );
    }
  }

  @override
  Widget build(BuildContext context) {  
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIndicator(context),
        const SizedBox(width: 10),
        Text(
          item.label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

/// Custom painter to render dashed lines.
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DashedLinePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 8;
    double dashSpace = 3;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
