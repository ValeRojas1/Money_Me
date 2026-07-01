import 'package:flutter/foundation.dart';
import 'package:money_me/features/ocr/data/models/ocr_result_model.dart';
import 'package:money_me/features/ocr/domain/entities/ocr_result.dart';
import 'package:money_me/features/ocr/domain/usecases/scan_receipt_usecase.dart';

enum OcrStatus { idle, scanning, completed, error }

class OcrProvider extends ChangeNotifier {
  final ScanReceiptUseCase _scanReceiptUseCase;

  OcrStatus _status = OcrStatus.idle;
  List<OcrResult>? _results;
  String? _errorMessage;
  List<ProcessedCaptureModel> _history = [];

  OcrProvider(this._scanReceiptUseCase);

  OcrStatus get status => _status;
  List<OcrResult>? get results => _results;
  String? get errorMessage => _errorMessage;
  List<ProcessedCaptureModel> get history => _history;

  Future<void> scanReceiptBytes(List<int> bytes, String filename) async {
    if (bytes.isEmpty) {
      _status = OcrStatus.error;
      _errorMessage = 'File not found';
      notifyListeners();
      return;
    }

    _status = OcrStatus.scanning;
    _errorMessage = null;
    notifyListeners();

    final (results, failure) = await _scanReceiptUseCase(bytes, filename);

    if (failure != null) {
      _status = OcrStatus.error;
      _errorMessage = failure.message;
    } else {
      _status = OcrStatus.completed;
      _results = results;
    }
    notifyListeners();
  }

  Future<bool> confirmCapture(int captureId, Map<String, dynamic>? edits) async {
    _status = OcrStatus.scanning;
    _errorMessage = null;
    notifyListeners();

    final (result, failure) = await _scanReceiptUseCase.confirmCapture(captureId, edits);

    if (failure != null) {
      _status = OcrStatus.error;
      _errorMessage = failure.message;
      notifyListeners();
      return false;
    } else {
      _status = OcrStatus.completed;
      notifyListeners();
      return true;
    }
  }

  Future<bool> rejectCapture(int captureId) async {
    _status = OcrStatus.scanning;
    _errorMessage = null;
    notifyListeners();

    final (result, failure) = await _scanReceiptUseCase.rejectCapture(captureId);

    if (failure != null) {
      _status = OcrStatus.error;
      _errorMessage = failure.message;
      notifyListeners();
      return false;
    } else {
      _status = OcrStatus.completed;
      notifyListeners();
      return true;
    }
  }

  Future<bool> saveManualEntry(Map<String, dynamic> data) async {
    _status = OcrStatus.scanning;
    _errorMessage = null;
    notifyListeners();

    final (result, failure) = await _scanReceiptUseCase.saveManualEntry(data);

    if (failure != null) {
      _status = OcrStatus.error;
      _errorMessage = failure.message;
      notifyListeners();
      return false;
    } else {
      _status = OcrStatus.completed;
      notifyListeners();
      return true;
    }
  }

  void reset() {
    _status = OcrStatus.idle;
    _results = null;
    _errorMessage = null;
    notifyListeners();
  }

  void setHistory(List<ProcessedCaptureModel> history) {
    _history = history;
    notifyListeners();
  }
}
