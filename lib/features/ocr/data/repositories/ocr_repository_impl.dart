import 'package:money_me/core/errors/failures.dart';
import 'package:money_me/core/network/api_exceptions.dart';
import 'package:money_me/features/ocr/data/datasources/ocr_remote_datasource.dart';
import 'package:money_me/features/ocr/data/models/ocr_result_model.dart';
import 'package:money_me/features/ocr/domain/entities/ocr_result.dart';
import 'package:money_me/features/ocr/domain/repositories/ocr_repository.dart';

class OcrRepositoryImpl implements OcrRepository {
  final OcrRemoteDataSource _remoteDataSource;

  OcrRepositoryImpl(this._remoteDataSource);

  @override
  Future<(List<OcrResult>, Failure?)> scanReceiptBytes(List<int> bytes, String filename) async {
    try {
      final result = await _remoteDataSource.scanReceiptBytes(bytes, filename);
      return (result, null);
    } on ApiException catch (e) {
      return (<OcrResult>[], ServerFailure(e.message));
    } catch (e) {
      return (<OcrResult>[], ServerFailure(e.toString()));
    }
  }

  @override
  Future<(List<ProcessedCaptureModel>, Failure?)> getHistory() async {
    try {
      final history = await _remoteDataSource.getHistory();
      return (history, null);
    } on ApiException catch (e) {
      return (<ProcessedCaptureModel>[], ServerFailure(e.message));
    } catch (e) {
      return (<ProcessedCaptureModel>[], ServerFailure(e.toString()));
    }
  }

  @override
  Future<(Map<String, dynamic>?, Failure?)> confirmCapture(int captureId, Map<String, dynamic>? edits) async {
    try {
      final result = await _remoteDataSource.confirmCapture(captureId, edits);
      return (result, null);
    } on ApiException catch (e) {
      return (null, ServerFailure(e.message));
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Future<(Map<String, dynamic>?, Failure?)> rejectCapture(int captureId) async {
    try {
      final result = await _remoteDataSource.rejectCapture(captureId);
      return (result, null);
    } on ApiException catch (e) {
      return (null, ServerFailure(e.message));
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Future<(Map<String, dynamic>?, Failure?)> saveManualEntry(Map<String, dynamic> data) async {
    try {
      final result = await _remoteDataSource.saveManualEntry(data);
      return (result, null);
    } on ApiException catch (e) {
      return (null, ServerFailure(e.message));
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }
}
