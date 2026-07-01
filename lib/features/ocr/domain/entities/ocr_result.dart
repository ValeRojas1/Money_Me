class OcrResult {
  final int captureId;
  final String rawText;
  final double ocrConfidence;
  final Map<String, dynamic> extractedFields;
  final Map<String, dynamic> classification;
  final bool isDuplicate;
  final double duplicateConfidence;
  final String fingerprint;
  final int processingTimeMs;
  final String status;

  const OcrResult({
    required this.captureId,
    required this.rawText,
    required this.ocrConfidence,
    required this.extractedFields,
    required this.classification,
    required this.isDuplicate,
    required this.duplicateConfidence,
    required this.fingerprint,
    required this.processingTimeMs,
    required this.status,
  });

  bool get isLowConfidence => ocrConfidence < 50;
  bool get isHighConfidence => ocrConfidence >= 80;
  bool get isError => status == 'error';

  String? get merchant => extractedFields['merchant'] as String?;
  int? get amountCents => extractedFields['amount_cents'] as int?;
  String? get currency => extractedFields['currency'] as String?;
  String? get concept => extractedFields['concept'] as String?;

  double? get amount => amountCents != null ? amountCents! / 100 : null;
}
