import 'package:flutter/material.dart';
import 'package:money_me/app/theme.dart';

class MoneyTableColumn {
  final String header;
  final double flex;
  final TextAlign alignment;
  final String? Function(dynamic) cellFormatter;

  const MoneyTableColumn({
    required this.header,
    this.flex = 1,
    this.alignment = TextAlign.left,
    this.cellFormatter = _defaultFormat,
  });

  static String _defaultFormat(dynamic value) => value?.toString() ?? '';
}

class MoneyTable extends StatelessWidget {
  final List<MoneyTableColumn> columns;
  final List<dynamic> rows;
  final bool loading;
  final String? emptyMessage;

  const MoneyTable({
    super.key,
    required this.columns,
    required this.rows,
    this.loading = false,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return _loadingState();
    }
    if (rows.isEmpty) {
      return _emptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 480) {
          return _buildMobileList();
        }
        return _buildDesktopTable();
      },
    );
  }

  Widget _loadingState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: SizedBox(
          width: 24, height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.accent),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: AppColors.textTertiary),
            SizedBox(height: AppSpacing.md),
            Text(emptyMessage ?? 'No data', style: AppTypography.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 40,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 44,
        headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
        dataRowColor: WidgetStateProperty.all(Colors.transparent),
        border: TableBorder(
          horizontalInside: BorderSide(color: AppColors.divider, width: 0.5),
        ),
        columnSpacing: 24,
        columns: columns
            .map((c) => DataColumn(
                  label: Text(c.header, style: AppTypography.labelSmall),
                  numeric: c.alignment == TextAlign.right,
                ))
            .toList(),
        rows: rows.map((row) {
          return DataRow(
            cells: columns
                .map((c) => DataCell(
                      Text(
                        c.cellFormatter(row) ?? '',
                        style: AppTypography.bodyMedium,
                        textAlign: c.alignment,
                      ),
                    ))
                .toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: rows.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.divider),
      itemBuilder: (context, index) {
        final row = rows[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columns
                .where((c) => c.header.isNotEmpty)
                .map((c) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: c.alignment == TextAlign.right
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Text('${c.header}: ', style: AppTypography.labelSmall),
                          Text(c.cellFormatter(row) ?? '', style: AppTypography.bodyMedium),
                        ],
                      ),
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}
