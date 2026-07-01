import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:money_me/app/theme.dart';
import 'package:money_me/core/network/api_constants.dart';
import 'package:money_me/core/utils/error_messages.dart';
import 'package:money_me/features/auth/presentation/providers/auth_provider.dart';
import 'package:money_me/shared/widgets/money_button.dart';
import 'package:money_me/shared/widgets/money_card.dart';
import 'package:money_me/shared/widgets/money_form_field.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  bool _isExporting = false;
  String? _error;

  Future<void> _export(String format) async {
    setState(() {
      _isExporting = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.token;

      final params = <String, String>{};
      if (_startCtrl.text.isNotEmpty) params['start_date'] = _startCtrl.text;
      if (_endCtrl.text.isNotEmpty) params['end_date'] = _endCtrl.text;
      final query = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/reports/export/$format${query.isNotEmpty ? '?$query' : ''}');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConstants.timeout);

      if (response.statusCode != 200) {
        final err = UserFriendlyError.fromStatusCode(response.statusCode, response.body);
        throw Exception(err.message);
      }

      final bytes = response.bodyBytes;

      final ext = format == 'csv' ? 'csv' : 'pdf';
      final mime = format == 'csv' ? 'text/csv' : 'application/pdf';
      final fileName = 'transactions_${_startCtrl.text.isNotEmpty ? _startCtrl.text : 'all'}_${_endCtrl.text.isNotEmpty ? _endCtrl.text : 'all'}.$ext';

      if (mounted) {
        _showSaveDialog(fileName, bytes, mime);
      }
    } catch (e) {
      final err = UserFriendlyError.fromException(e);
      setState(() => _error = err.message);
    }

    setState(() => _isExporting = false);
  }

  void _showSaveDialog(String fileName, List<int> bytes, String mime) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$fileName ready (${(bytes.length / 1024).toStringAsFixed(1)} KB)'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export transactions')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
          MoneyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date range (optional)', style: AppTypography.titleSmall),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: MoneyFormField(
                        label: 'From',
                        hintText: 'YYYY-MM-DD',
                        controller: _startCtrl,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: MoneyFormField(
                        label: 'To',
                        hintText: 'YYYY-MM-DD',
                        controller: _endCtrl,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          if (_error != null)
            Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: MoneyCard(
                color: AppColors.error.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(_error!, style: AppTypography.bodySmall)),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: MoneyButton(
                  label: 'Export CSV',
                  icon: Icons.table_chart_outlined,
                  isLoading: _isExporting,
                  onPressed: () => _export('csv'),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _export('pdf'),
                  icon: Icon(Icons.picture_as_pdf, size: 16),
                  label: Text('Export PDF'),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          MoneyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('About exports', style: AppTypography.titleSmall),
                SizedBox(height: AppSpacing.sm),
                _infoRow(Icons.description_outlined, 'CSV includes all fields: date, type, description, amount, currency, category, notes, tags'),
                SizedBox(height: AppSpacing.sm),
                _infoRow(Icons.picture_as_pdf, 'PDF includes a formatted table with totals (income, expense, balance)'),
                SizedBox(height: AppSpacing.sm),
                _infoRow(Icons.calendar_today, 'Leave dates empty to export all transactions'),
              ],
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: AppTypography.bodySmall)),
      ],
    );
  }
}
