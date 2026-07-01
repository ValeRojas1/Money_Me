import 'package:money_me/features/ocr/domain/entities/ocr_result.dart';

class OcrResultModel extends OcrResult {
  const OcrResultModel({
    required super.captureId,
    required super.rawText,
    required super.ocrConfidence,
    required super.extractedFields,
    required super.classification,
    required super.isDuplicate,
    required super.duplicateConfidence,
    required super.fingerprint,
    required super.processingTimeMs,
    required super.status,
  });

  factory OcrResultModel.fromJson(Map<String, dynamic> json) {
    return OcrResultModel(
      captureId: json['capture_id'] as int? ?? 0,
      rawText: json['raw_text'] as String? ?? '',
      ocrConfidence: (json['ocr_confidence'] as num?)?.toDouble() ?? 0.0,
      extractedFields: Map<String, dynamic>.from(
          json['extracted_data'] as Map? ?? {}),
      classification: Map<String, dynamic>.from(
          json['classification'] as Map? ?? {}),
      isDuplicate: json['is_duplicate'] as bool? ?? false,
      duplicateConfidence:
          (json['duplicate_confidence'] as num?)?.toDouble() ?? 0.0,
      fingerprint: json['fingerprint'] as String? ?? '',
      processingTimeMs: json['processing_time_ms'] as int? ?? 0,
      status: json['status'] as String? ?? 'unknown',
    );
  }
}

class ProcessedCaptureModel {
  final int id;
  final int userId;
  final String source;
  final String status;
  final String? merchantName;
  final int? totalCents;
  final String? currency;
  final double? confidenceScore;
  final String createdAt;

  const ProcessedCaptureModel({
    required this.id,
    required this.userId,
    required this.source,
    required this.status,
    this.merchantName,
    this.totalCents,
    this.currency,
    this.confidenceScore,
    required this.createdAt,
  });

  factory ProcessedCaptureModel.fromJson(Map<String, dynamic> json) {
    return ProcessedCaptureModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      source: json['source'] as String,
      status: json['status'] as String,
      merchantName: json['merchant_name'] as String?,
      totalCents: json['total_cents'] as int?,
      currency: json['currency'] as String?,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      createdAt: json['created_at'] as String,
    );
  }
}
