import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:money_me/app/theme.dart';

const _chartColors = [
  Color(0xFF4A7CF7),
  Color(0xFF2E7D6F),
  Color(0xFFD4891D),
  Color(0xFF7C6FF7),
  Color(0xFFC0392B),
  Color(0xFF6B7280),
];

class MoneyBarChart extends StatelessWidget {
  final List<BarChartItem> items;
  final double height;
  final String? title;

  const MoneyBarChart({
    super.key,
    required this.items,
    this.height = 200,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final maxValue = items.fold<double>(0, (m, i) => i.value > m ? i.value : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!, style: AppTypography.titleLarge),
          SizedBox(height: AppSpacing.md),
        ],
        SizedBox(
          height: height,
          child: CustomPaint(
            size: Size.infinite,
            painter: _BarChartPainter(items, maxValue),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items
              .map((item) => Expanded(
                    child: Text(
                      item.label,
                      style: AppTypography.caption,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class BarChartItem {
  static const defaultColor = Color(0xFF4A7CF7);

  final String label;
  final double value;
  final Color color;

  const BarChartItem({
    required this.label,
    required this.value,
    this.color = defaultColor,
  });
}

class _BarChartPainter extends CustomPainter {
  final List<BarChartItem> items;
  final double maxValue;

  _BarChartPainter(this.items, this.maxValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty || maxValue == 0) return;

    final barWidth = size.width / items.length * 0.55;
    final gap = size.width / items.length * 0.45;

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final barHeight = (item.value / maxValue) * (size.height - 16);
      final x = i * (barWidth + gap) + gap / 2;
      final y = size.height - 8 - barHeight;

      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        ),
        paint,
      );
    }

    canvas.drawLine(
      Offset(0, size.height - 8),
      Offset(size.width, size.height - 8),
      Paint()..color = AppColors.border..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => true;
}

class MoneyPieChart extends StatelessWidget {
  final List<PieChartItem> items;
  final double size;
  final String? title;

  const MoneyPieChart({
    super.key,
    required this.items,
    this.size = 180,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final total = items.fold<double>(0, (s, i) => s + i.value);

    return Column(
      children: [
        if (title != null) ...[
          Text(title!, style: AppTypography.titleLarge),
          SizedBox(height: AppSpacing.md),
        ],
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            size: Size.square(size),
            painter: _PieChartPainter(items, total),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        ...items.map((item) => Padding(
              padding: EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(item.label, style: AppTypography.bodyMedium)),
                  Text(
                    '\$${(item.value / 100).toStringAsFixed(2)}',
                    style: AppTypography.amountSmall,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '${(item.value / total * 100).toStringAsFixed(1)}%',
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class PieChartItem {
  final String label;
  final double value;
  final Color color;

  const PieChartItem({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _PieChartPainter extends CustomPainter {
  final List<PieChartItem> items;
  final double total;

  _PieChartPainter(this.items, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty || total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    final rect = Rect.fromCircle(center: center, radius: radius);
    var startAngle = -1.5708;

    for (final item in items) {
      final sweepAngle = (item.value / total) * 6.28319;
      canvas.drawArc(rect, startAngle, sweepAngle, true, Paint()..color = item.color);
      startAngle += sweepAngle;
    }

    final centerPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.4, centerPaint);

    final totalText = TextPainter(
      text: TextSpan(
        text: '\$${(total / 100).toStringAsFixed(0)}',
        style: AppTypography.amountSmall,
      ),
      textDirection: ui.TextDirection.ltr,
    );
    totalText.layout();
    totalText.paint(
      canvas,
      Offset(center.dx - totalText.width / 2, center.dy - totalText.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) => true;
}
