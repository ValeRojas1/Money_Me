import 'package:money_me/core/errors/failures.dart';
import 'package:money_me/features/ocr/data/models/ocr_result_model.dart';
import 'package:money_me/features/ocr/domain/entities/ocr_result.dart';

abstract interface class OcrRepository {
  Future<(List<OcrResult>, Failure?)> scanReceiptBytes(List<int> bytes, String filename);
  Future<(List<ProcessedCaptureModel>, Failure?)> getHistory();
  Future<(Map<String, dynamic>?, Failure?)> confirmCapture(int captureId, Map<String, dynamic>? edits);
  Future<(Map<String, dynamic>?, Failure?)> rejectCapture(int captureId);
  Future<(Map<String, dynamic>?, Failure?)> saveManualEntry(Map<String, dynamic> data);
}
