import 'package:flutter_test/flutter_test.dart';
import 'package:money_me/core/errors/failures.dart';
import 'package:money_me/features/ocr/data/models/ocr_result_model.dart';
import 'package:money_me/features/ocr/domain/entities/ocr_result.dart';
import 'package:money_me/features/ocr/domain/repositories/ocr_repository.dart';
import 'package:money_me/features/ocr/domain/usecases/scan_receipt_usecase.dart';
import 'package:money_me/features/ocr/presentation/providers/ocr_provider.dart';

class MockScanReceiptUseCase extends ScanReceiptUseCase {
  MockScanReceiptUseCase() : super(MockOcrRepository());

  bool shouldFail = false;

  @override
  Future<(List<OcrResult>, Failure?)> call(List<int> bytes, String filename) async {
    if (shouldFail) return (<OcrResult>[], ServerFailure('OCR failed'));
    return ([
      OcrResult(
        captureId: 1, rawText: 'Coffee 4.50', ocrConfidence: 0.85,
        extractedFields: {'amount_cents': 450}, classification: {'category': 'food', 'confidence': 0.9},
        isDuplicate: false, duplicateConfidence: 0.0, fingerprint: 'abc',
        processingTimeMs: 100, status: 'completed',
      ),
    ], null);
  }

  @override
  Future<(Map<String, dynamic>?, Failure?)> confirmCapture(int captureId, Map<String, dynamic>? edits) async {
    if (shouldFail) return (null, ServerFailure('Confirm failed'));
    return ({'movement_id': 1, 'status': 'confirmed'}, null);
  }

  @override
  Future<(Map<String, dynamic>?, Failure?)> rejectCapture(int captureId) async {
    if (shouldFail) return (null, ServerFailure('Reject failed'));
    return ({'status': 'rejected'}, null);
  }

  @override
  Future<(Map<String, dynamic>?, Failure?)> saveManualEntry(Map<String, dynamic> data) async {
    if (shouldFail) return (null, ServerFailure('Save failed'));
    return ({'movement_id': 1, 'status': 'created'}, null);
  }
}

class MockOcrRepository implements OcrRepository {
  @override
  Future<(List<OcrResult>, Failure?)> scanReceiptBytes(List<int> bytes, String filename) async {
    return (<OcrResult>[], null);
  }

  @override
  Future<(List<ProcessedCaptureModel>, Failure?)> getHistory() async {
    return (<ProcessedCaptureModel>[], null);
  }

  @override
  Future<(Map<String, dynamic>?, Failure?)> confirmCapture(int captureId, Map<String, dynamic>? edits) async {
    return ({'movement_id': 1}, null);
  }

  @override
  Future<(Map<String, dynamic>?, Failure?)> rejectCapture(int captureId) async {
    return ({'status': 'rejected'}, null);
  }

  @override
  Future<(Map<String, dynamic>?, Failure?)> saveManualEntry(Map<String, dynamic> data) async {
    return ({'movement_id': 1}, null);
  }
}

void main() {
  late MockScanReceiptUseCase useCase;
  late OcrProvider provider;

  setUp(() {
    useCase = MockScanReceiptUseCase();
    provider = OcrProvider(useCase);
  });

  group('OcrProvider', () {
    test('initial status is idle', () {
      expect(provider.status, OcrStatus.idle);
      expect(provider.results, isNull);
      expect(provider.errorMessage, isNull);
      expect(provider.history, isEmpty);
    });

    test('scanReceiptBytes sets completed status on success', () async {
      await provider.scanReceiptBytes([1, 2, 3], 'test.png');
      expect(provider.status, OcrStatus.completed);
      expect(provider.results, isNotNull);
      expect(provider.results!.length, 1);
    });

    test('scanReceiptBytes sets error on empty bytes', () async {
      await provider.scanReceiptBytes([], 'empty.png');
      expect(provider.status, OcrStatus.error);
      expect(provider.errorMessage, 'File not found');
    });

    test('scanReceiptBytes sets error on failure', () async {
      useCase.shouldFail = true;
      await provider.scanReceiptBytes([1, 2, 3], 'test.png');
      expect(provider.status, OcrStatus.error);
      expect(provider.errorMessage, isNotNull);
    });

    test('confirmCapture returns true on success', () async {
      final result = await provider.confirmCapture(1, null);
      expect(result, isTrue);
    });

    test('confirmCapture returns false on failure', () async {
      useCase.shouldFail = true;
      final result = await provider.confirmCapture(1, null);
      expect(result, isFalse);
      expect(provider.status, OcrStatus.error);
    });

    test('rejectCapture returns true on success', () async {
      final result = await provider.rejectCapture(1);
      expect(result, isTrue);
    });

    test('saveManualEntry returns true on success', () async {
      final result = await provider.saveManualEntry({'amount_cents': 1000, 'description': 'Test'});
      expect(result, isTrue);
    });

    test('reset clears state', () {
      provider.reset();
      expect(provider.status, OcrStatus.idle);
      expect(provider.results, isNull);
      expect(provider.errorMessage, isNull);
    });

    test('setHistory updates history list', () {
      provider.setHistory([]);
      expect(provider.history, isEmpty);
    });
  });
}
