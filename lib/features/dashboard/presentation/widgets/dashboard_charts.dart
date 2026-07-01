import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:money_me/app/theme.dart';
import 'package:money_me/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:money_me/shared/widgets/money_card.dart';

class TrendChart extends StatelessWidget {
  final List<MonthlyTrendPoint> data;
  final String label;

  const TrendChart({super.key, required this.data, this.label = 'Monthly trend'});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return MoneyCard(
        child: SizedBox(
          height: 200,
          child: Center(child: Text('No trend data', style: AppTypography.bodyMedium)),
        ),
      );
    }
    return MoneyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: AppSpacing.md, top: AppSpacing.md),
            child: Text(label, style: AppTypography.titleSmall),
          ),
          SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 200,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CustomPaint(
                size: Size.infinite,
                painter: _TrendChartPainter(data),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final List<MonthlyTrendPoint> data;
  _TrendChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final w = size.width;
    final h = size.height;
    final barWidth = (w / data.length) * 0.6;
    final gap = (w / data.length) * 0.4;
    final maxVal = data.fold(0, (int m, d) => math.max(m, math.max(d.expenseCents, d.incomeCents))).toDouble();
    if (maxVal == 0) return;

    for (var i = 0; i < data.length; i++) {
      final x = i * (barWidth + gap) + gap / 2;
      final expH = (data[i].expenseCents / maxVal) * (h - 20);
      final incH = (data[i].incomeCents / maxVal) * (h - 20);

      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, h - 10 - expH, barWidth / 2 - 2, expH), Radius.circular(3)),
        Paint()..color = AppColors.error,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x + barWidth / 2 + 2, h - 10 - incH, barWidth / 2 - 2, incH), Radius.circular(3)),
        Paint()..color = AppColors.success,
      );
    }

    canvas.drawLine(Offset(0, h - 10), Offset(w, h - 10), Paint()..color = AppColors.divider..strokeWidth = 1);

    if (data.length > 1) {
      for (var i = 0; i < data.length; i += math.max(1, data.length ~/ 6)) {
        canvas.drawString(data[i].label.split(' ').first, Offset(i * (barWidth + gap) + gap / 2, h - 8), AppTypography.caption.color ?? Colors.grey);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CategoryPieChart extends StatelessWidget {
  final List<BreakdownItem> data;

  const CategoryPieChart({super.key, required this.data});

  static const _colors = [
    Color(0xFF4A90D9), Color(0xFF50C878), Color(0xFFFF6B6B),
    Color(0xFFFFD93D), Color(0xFFC084FC), Color(0xFFFB923C),
    Color(0xFF2DD4BF), Color(0xFFF472B6),
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return MoneyCard(
        child: SizedBox(
          height: 200,
          child: Center(child: Text('No category data', style: AppTypography.bodyMedium)),
        ),
      );
    }
    return MoneyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: AppSpacing.md, top: AppSpacing.md),
            child: Text('By category', style: AppTypography.titleSmall),
          ),
          SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 220,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomPaint(
                    size: Size(160, 200),
                    painter: _PieChartPainter(data),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: EdgeInsets.only(right: AppSpacing.sm),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(data.length, (i) {
                        final item = data[i];
                        final color = _colors[i % _colors.length];
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                              SizedBox(width: 6),
                              Expanded(child: Text('Cat ${item.id}', style: AppTypography.caption, overflow: TextOverflow.ellipsis)),
                              Text('\$${item.total.toStringAsFixed(0)}', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<BreakdownItem> data;
  _PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.fold(0.0, (double sum, d) => sum + d.total);
    if (total == 0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 10;
    var startAngle = -math.pi / 2;

    for (var i = 0; i < data.length; i++) {
      final sweepAngle = (data[i].total / total) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle, sweepAngle, true,
        Paint()..color = CategoryPieChart._colors[i % CategoryPieChart._colors.length],
      );
      startAngle += sweepAngle;
    }
    canvas.drawCircle(Offset(cx, cy), r * 0.4, Paint()..color = AppColors.surface);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WalletBarChart extends StatelessWidget {
  final List<BreakdownItem> data;

  const WalletBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox.shrink();
    return MoneyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: AppSpacing.md, top: AppSpacing.md),
            child: Text('By wallet', style: AppTypography.titleSmall),
          ),
          SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 120,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CustomPaint(
                size: Size.infinite,
                painter: _WalletBarPainter(data),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletBarPainter extends CustomPainter {
  final List<BreakdownItem> data;
  _WalletBarPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.fold(0.0, (double m, d) => math.max(m, d.total));
    if (maxVal == 0) return;
    final barH = 20.0;
    final gap = 8.0;
    final totalH = data.length * (barH + gap);

    for (var i = 0; i < data.length && i < 5; i++) {
      final y = i * (barH + gap);
      final w = (data[i].total / maxVal) * (size.width - 80);

      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, y, w, barH), Radius.circular(4)),
        Paint()..color = CategoryPieChart._colors[i % CategoryPieChart._colors.length],
      );
      canvas.drawString(
        '\$${data[i].total.toStringAsFixed(0)}', Offset(w + 8, y + 3),
        AppTypography.caption.color ?? Colors.grey,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TopCategoriesList extends StatelessWidget {
  final List<TopCategoryItem> items;

  const TopCategoriesList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return SizedBox.shrink();
    final total = items.fold(0.0, (double s, i) => s + i.total);
    return MoneyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: AppSpacing.md, top: AppSpacing.md),
            child: Text('Top categories', style: AppTypography.titleSmall),
          ),
          ...items.map((item) {
            final pct = total > 0 ? item.total / total * 100 : 0.0;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Cat ${item.categoryId}', style: AppTypography.bodySmall, overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        backgroundColor: AppColors.surfaceVariant,
                        minHeight: 8,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 60,
                    child: Text('\$${item.total.toStringAsFixed(0)}', style: AppTypography.caption, textAlign: TextAlign.right),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

}

extension _CanvasDrawString on Canvas {
  void drawString(String text, Offset pos, Color color, {double size = 10}) {
    final builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(fontSize: size, textDirection: TextDirection.ltr),
    )
      ..pushStyle(ui.TextStyle(color: color))
      ..addText(text);
    final paragraph = builder.build()..layout(ui.ParagraphConstraints(width: 100));
    drawParagraph(paragraph, pos);
  }
}
