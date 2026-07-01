import 'package:money_me/core/errors/failures.dart';
import 'package:money_me/features/ocr/domain/entities/ocr_result.dart';
import 'package:money_me/features/ocr/domain/repositories/ocr_repository.dart';

class ScanReceiptUseCase {
  final OcrRepository _repository;

  ScanReceiptUseCase(this._repository);

  Future<(List<OcrResult>, Failure?)> call(List<int> bytes, String filename) {
    return _repository.scanReceiptBytes(bytes, filename);
  }

  Future<(Map<String, dynamic>?, Failure?)> confirmCapture(int captureId, Map<String, dynamic>? edits) {
    return _repository.confirmCapture(captureId, edits);
  }

  Future<(Map<String, dynamic>?, Failure?)> rejectCapture(int captureId) {
    return _repository.rejectCapture(captureId);
  }

  Future<(Map<String, dynamic>?, Failure?)> saveManualEntry(Map<String, dynamic> data) {
    return _repository.saveManualEntry(data);
  }
}
