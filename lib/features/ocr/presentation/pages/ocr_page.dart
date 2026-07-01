import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:money_me/app/theme.dart';
import 'package:money_me/features/ocr/domain/entities/ocr_result.dart';
import 'package:money_me/features/ocr/presentation/providers/ocr_provider.dart';
import 'package:money_me/features/ocr/presentation/widgets/capture_history_widget.dart';
import 'package:money_me/features/ocr/presentation/widgets/transaction_table_form.dart';
import 'package:money_me/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:money_me/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:money_me/features/auth/presentation/providers/auth_provider.dart';
import 'package:money_me/shared/widgets/money_button.dart';
import 'package:money_me/shared/widgets/money_alert.dart';

class OcrPage extends StatefulWidget {
  const OcrPage({super.key});

  @override
  State<OcrPage> createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages({bool multiple = false}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp', 'tiff'],
      allowMultiple: multiple,
      withData: true,
    );

    if (result == null || !mounted || result.files.isEmpty) return;

    final file = result.files.firstWhere(
      (picked) => picked.bytes != null && picked.bytes!.isNotEmpty,
      orElse: () => result.files.first,
    );
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) return;

    if (multiple && result.files.length > 1) {
      final images = result.files
          .where((picked) => picked.bytes != null && picked.bytes!.isNotEmpty)
          .map((picked) => _PickedImage(name: picked.name, bytes: picked.bytes!))
          .toList();
      if (images.isEmpty) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _MultiPreviewPage(files: images),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _CapturePreviewPage(
            fileName: file.name,
            bytes: bytes,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'Scan', icon: Icon(Icons.document_scanner, size: 20)),
            Tab(text: 'History', icon: Icon(Icons.history, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildScanTab(),
          Consumer<OcrProvider>(
            builder: (_, provider, __) => CaptureHistoryWidget(
              items: [],
              onTap: (capture) {},
              onManualEntry: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _ManualEntryPage()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanTab() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Icons.document_scanner, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text('Scan a Receipt', style: AppTypography.headlineSmall),
              const SizedBox(height: 8),
              Text('Capture receipts or invoices to auto-extract data', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: MoneyButton(
                  label: 'Take Photo',
                  icon: Icons.camera_alt,
                  onPressed: () => _pickImages(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: MoneyButton(
                  label: 'Choose from Gallery',
                  icon: Icons.image,
                  expanded: true,
                  onPressed: () => _pickImages(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: MoneyButton(
                  label: 'Scan Multiple',
                  icon: Icons.collections,
                  expanded: true,
                  onPressed: () => _pickImages(multiple: true),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text("Don't have an image?", style: AppTypography.bodySmall),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _ManualEntryPage())),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Enter Manually'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickedImage {
  final String name;
  final List<int> bytes;

  const _PickedImage({required this.name, required this.bytes});
}

class _CapturePreviewPage extends StatefulWidget {
  final String fileName;
  final List<int> bytes;

  const _CapturePreviewPage({
    required this.fileName,
    required this.bytes,
  });

  @override
  State<_CapturePreviewPage> createState() => _CapturePreviewPageState();
}

class _CapturePreviewPageState extends State<_CapturePreviewPage> {
  bool _processing = false;

  Future<void> _process() async {
    setState(() => _processing = true);
    final provider = context.read<OcrProvider>();
    await provider.scanReceiptBytes(widget.bytes, widget.fileName);
    if (mounted) {
      setState(() => _processing = false);
      // Check both provider status and result status (backend may return error in result)
      if (provider.status == OcrStatus.error) {
        final displayMsg = provider.errorMessage ?? 'Scan failed';
        final isAuthError = displayMsg.contains('token') ||
                            displayMsg.contains('Unauthorized') ||
                            displayMsg.contains('expired');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(displayMsg),
            backgroundColor: AppColors.error,
            action: isAuthError ? SnackBarAction(
              label: 'Sign In Again',
              textColor: Colors.white,
              onPressed: () {
                context.read<AuthProvider>().logout();
              },
            ) : null,
          ),
        );
        return;
      }
      final results = provider.results;
      if (results != null && results.any((r) => r.isError)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OCR processing error. Please try a clearer image.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      if (results != null && results.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => _ReviewPage(
              fileName: widget.fileName,
              bytes: widget.bytes,
              ocrResults: results,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No result returned from OCR. Try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        Uint8List.fromList(widget.bytes),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 64),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [AppShadows.elevated]),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MoneyAlert(type: MoneyAlertType.info, title: 'Review image', message: 'Make sure the receipt is clear and readable before processing'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: MoneyButton(label: 'Cancel', onPressed: () => Navigator.pop(context))),
                          const SizedBox(width: 12),
                          Expanded(child: MoneyButton(label: 'Process', isLoading: _processing, onPressed: _processing ? null : _process)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MultiPreviewPage extends StatefulWidget {
  final List<_PickedImage> files;
  const _MultiPreviewPage({required this.files});

  @override
  State<_MultiPreviewPage> createState() => _MultiPreviewPageState();
}

class _MultiPreviewPageState extends State<_MultiPreviewPage> {
  bool _processing = false;

  Future<void> _processAll() async {
    setState(() => _processing = true);
    final provider = context.read<OcrProvider>();

    List<OcrResult>? firstResults;
    _PickedImage? firstImage;
    final List<String> errors = [];

    for (final img in widget.files) {
      await provider.scanReceiptBytes(img.bytes, img.name);
      if (provider.status == OcrStatus.error || provider.results == null || provider.results!.any((r) => r.isError)) {
        errors.add(img.name);
      } else if (firstResults == null) {
        firstResults = provider.results;
        firstImage = img;
      }
    }

    if (!mounted) return;
    setState(() => _processing = false);

    if (firstResults != null && firstImage != null) {
      if (errors.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${errors.length} image(s) failed OCR: ${errors.join(", ")}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => _ReviewPage(
            fileName: firstImage!.name,
            bytes: firstImage!.bytes,
            ocrResults: firstResults!,
          ),
        ),
      );
    } else {
      final msg = errors.isNotEmpty
          ? 'All images failed: ${provider.errorMessage ?? "OCR could not extract data"}'
          : 'No results from OCR. Try clearer images.';
      final isAuthError = msg.contains('token') ||
                          msg.contains('Unauthorized') ||
                          msg.contains('expired');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.error,
          action: isAuthError ? SnackBarAction(
            label: 'Sign In Again',
            textColor: Colors.white,
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
          ) : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.files.length} images selected')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
        ),
        itemCount: widget.files.length,
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            Uint8List.fromList(widget.files[i].bytes),
            fit: BoxFit.cover,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: MoneyButton(
          label: 'Process ${widget.files.length} images',
          isLoading: _processing,
          onPressed: _processing ? null : _processAll,
        ),
      ),
    );
  }
}

class _ReviewPage extends StatefulWidget {
  final String fileName;
  final List<int> bytes;
  final List<OcrResult> ocrResults;

  const _ReviewPage({
    required this.fileName,
    required this.bytes,
    required this.ocrResults,
  });

  @override
  State<_ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<_ReviewPage> {
  late List<TextEditingController> _amountCtrls;
  late List<TextEditingController> _entityCtrls;
  late List<TextEditingController> _subjectCtrls;
  late List<TextEditingController> _dateCtrls;
  late List<TextEditingController> _timeCtrls;
  late List<String> _types;
  bool _confirming = false;

  @override
  void initState() {
    super.initState();
    _amountCtrls = [];
    _entityCtrls = [];
    _subjectCtrls = [];
    _dateCtrls = [];
    _timeCtrls = [];
    _types = [];

    for (var res in widget.ocrResults) {
      final amountVal = res.amount != null ? res.amount!.toStringAsFixed(2) : "";
      _amountCtrls.add(TextEditingController(text: amountVal));
      _entityCtrls.add(TextEditingController(text: res.merchant ?? ""));
      _subjectCtrls.add(TextEditingController(text: "")); // Starts blank
      
      final dateStr = res.extractedFields['date'] as String? ?? 
          DateTime.now().toIso8601String().split('T')[0];
      _dateCtrls.add(TextEditingController(text: dateStr));

      final timeStr = res.extractedFields['time'] as String? ?? 
          "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}";
      _timeCtrls.add(TextEditingController(text: timeStr));

      _types.add(res.extractedFields['transaction_type'] as String? ?? "expense");
    }
    
    // Proactively load categories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    for (var c in _amountCtrls) c.dispose();
    for (var c in _entityCtrls) c.dispose();
    for (var c in _subjectCtrls) c.dispose();
    for (var c in _dateCtrls) c.dispose();
    for (var c in _timeCtrls) c.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() => _confirming = true);
    final ocrProvider = context.read<OcrProvider>();
    final categories = context.read<TransactionProvider>().categories;
    bool allSuccess = true;
    String? lastError;

    for (int i = 0; i < widget.ocrResults.length; i++) {
      final res = widget.ocrResults[i];
      final amountVal = double.tryParse(_amountCtrls[i].text) ?? 0.0;
      int amountCents = (amountVal * 100).round();

      final categoryName = (res.classification['category'] as String? ?? 'other').toLowerCase();
      int categoryId = 2; // Default to 'other'
      if (categories.isNotEmpty) {
        try {
          final match = categories.firstWhere(
            (c) => c.name.toLowerCase() == categoryName,
            orElse: () => categories.firstWhere(
              (c) => c.name.toLowerCase().contains(categoryName),
              orElse: () => categories.first,
            ),
          );
          categoryId = match.id;
        } catch (_) {
          categoryId = 2;
        }
      }

      final edits = {
        'amount_cents': _types[i] == 'income' ? -amountCents : amountCents,
        'description': _subjectCtrls[i].text.trim().isNotEmpty
            ? "${_entityCtrls[i].text} - ${_subjectCtrls[i].text.trim()}"
            : _entityCtrls[i].text,
        'transaction_date': _dateCtrls[i].text,
        'category_id': categoryId,
        'notes': 'Time: ${_timeCtrls[i].text}',
      };

      final success = await ocrProvider.confirmCapture(res.captureId, edits);
      if (!success) {
        allSuccess = false;
        lastError = ocrProvider.errorMessage;
      }
    }

    setState(() => _confirming = false);

    if (allSuccess && mounted) {
      // Reload providers
      context.read<TransactionProvider>().loadTransactions();
      context.read<DashboardProvider>().loadAll();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transactions saved successfully'), backgroundColor: AppColors.success),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lastError ?? 'Failed to confirm some transactions'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tomamos la confianza de la primera captura como representativa
    final conf = widget.ocrResults.isNotEmpty ? widget.ocrResults.first.ocrConfidence : 0;
    final confColor = conf >= 70
        ? AppColors.success
        : conf >= 40
            ? Colors.orange
            : AppColors.error;
    final confLabel = conf >= 70
        ? 'Alta calidad — datos extraídos automáticamente'
        : conf >= 40
            ? 'Calidad media — revisa los campos'
            : 'Baja calidad — completa los campos manualmente';
    final rawText = widget.ocrResults.isNotEmpty ? widget.ocrResults.first.rawText : '';

    return Scaffold(
      appBar: AppBar(title: const Text('Revisar transacción')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  Uint8List.fromList(widget.bytes),
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 12),

              // Confidence indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: confColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: confColor.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    Icon(
                      conf >= 70 ? Icons.check_circle : conf >= 40 ? Icons.info : Icons.warning_amber,
                      color: confColor,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Confianza OCR: ${conf.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: confColor,
                            ),
                          ),
                          Text(
                            confLabel,
                            style: TextStyle(fontSize: 12, color: confColor.withAlpha(200)),
                          ),
                        ],
                      ),
                    ),
                    if (rawText.isNotEmpty)
                      TextButton(
                        onPressed: () => _showRawText(context, rawText),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('Ver texto', style: TextStyle(fontSize: 11)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Verifica y completa los datos detectados:',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TransactionTableForm(
                amountCtrls: _amountCtrls,
                entityCtrls: _entityCtrls,
                subjectCtrls: _subjectCtrls,
                dateCtrls: _dateCtrls,
                timeCtrls: _timeCtrls,
                types: _types,
                onTypeChanged: (index, val) {
                  if (val != null) setState(() => _types[index] = val);
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _confirming ? null : () => Navigator.pop(context),
                      child: const Text('Descartar', style: TextStyle(color: AppColors.error)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MoneyButton(
                      label: 'Confirmar',
                      isLoading: _confirming,
                      onPressed: _confirming ? null : _confirm,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showRawText(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Texto extraído por OCR', style: TextStyle(fontSize: 15)),
        content: SingleChildScrollView(
          child: SelectableText(
            text.isEmpty ? '(sin texto detectado)' : text,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _ManualEntryPage extends StatefulWidget {
  const _ManualEntryPage();

  @override
  State<_ManualEntryPage> createState() => _ManualEntryPageState();
}

class _ManualEntryPageState extends State<_ManualEntryPage> {
  late TextEditingController _amountCtrl;
  late TextEditingController _entityCtrl;
  late TextEditingController _subjectCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _timeCtrl;
  String _type = 'expense';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController();
    _entityCtrl = TextEditingController();
    _subjectCtrl = TextEditingController();
    _dateCtrl = TextEditingController(text: DateTime.now().toIso8601String().split('T')[0]);
    _timeCtrl = TextEditingController(
      text: "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
    );
    
    // Proactively load categories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _entityCtrl.dispose();
    _subjectCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final amountVal = double.tryParse(_amountCtrl.text) ?? 0.0;
    final amountCents = (amountVal * 100).round();

    final data = {
      'amount_cents': amountCents,
      'type': _type,
      'description': _subjectCtrl.text.trim().isNotEmpty
          ? "${_entityCtrl.text} - ${_subjectCtrl.text.trim()}"
          : _entityCtrl.text,
      'date': _dateCtrl.text,
      'notes': 'Time: ${_timeCtrl.text}',
    };

    final ocrProvider = context.read<OcrProvider>();
    final success = await ocrProvider.saveManualEntry(data);

    setState(() => _saving = false);

    if (success && mounted) {
      // Reload providers
      context.read<TransactionProvider>().loadTransactions();
      context.read<DashboardProvider>().loadAll();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction saved manually'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ocrProvider.errorMessage ?? 'Failed to save transaction'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Entry')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), borderRadius: BorderRadius.circular(32)),
                child: const Icon(Icons.edit, color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: 16),
              Text('Enter Transaction Details', style: AppTypography.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TransactionTableForm(
                amountCtrls: [_amountCtrl],
                entityCtrls: [_entityCtrl],
                subjectCtrls: [_subjectCtrl],
                dateCtrls: [_dateCtrl],
                timeCtrls: [_timeCtrl],
                types: [_type],
                onTypeChanged: (index, val) {
                  if (val != null) setState(() => _type = val);
                },
              ),
              const SizedBox(height: 24),
              MoneyButton(
                label: 'Save Transaction',
                isLoading: _saving,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
