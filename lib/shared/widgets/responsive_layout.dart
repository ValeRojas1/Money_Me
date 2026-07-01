import 'package:flutter/material.dart';
import 'package:money_me/app/theme.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.mobile) {
          return mobile;
        } else if (constraints.maxWidth < AppBreakpoints.laptop) {
          return tablet;
        } else {
          return desktop;
        }
      },
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double gap;

  const ResponsiveGrid({super.key, required this.children, this.gap = AppSpacing.lg});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount;
        if (width < AppBreakpoints.mobile) {
          crossAxisCount = 1;
        } else if (width < AppBreakpoints.tablet) {
          crossAxisCount = 2;
        } else if (width < AppBreakpoints.laptop) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 4;
        }

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
            childAspectRatio: 1.6,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => children[index],
            childCount: children.length,
          ),
        );
      },
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final double gap;

  const ResponsiveRow({super.key, required this.children, this.gap = AppSpacing.lg});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < AppBreakpoints.tablet;

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _addGaps(children),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _addRowGaps(children),
        );
      },
    );
  }

  List<Widget> _addGaps(List<Widget> widgets) {
    return widgets.expand((w) => [w, SizedBox(height: gap)]).toList()..removeLast();
  }

  List<Widget> _addRowGaps(List<Widget> widgets) {
    return widgets
        .expand((w) => [Expanded(child: w), SizedBox(width: gap)])
        .toList()
      ..removeLast();
  }
}
