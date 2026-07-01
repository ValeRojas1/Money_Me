import 'package:flutter/foundation.dart';
import 'package:money_me/features/predictions/domain/entities/prediction_data.dart';
import 'package:money_me/features/predictions/domain/repositories/prediction_repository.dart';

enum PredictionStatus { initial, loading, loaded, error }

class PredictionProvider extends ChangeNotifier {
  final PredictionRepository _repository;

  PredictionStatus _status = PredictionStatus.initial;
  SpendingForecast? _spendingForecast;
  IncomeForecast? _incomeForecast;
  List<FinancialTip> _tips = [];
  String? _errorMessage;

  PredictionProvider(this._repository);

  PredictionStatus get status => _status;
  SpendingForecast? get spendingForecast => _spendingForecast;
  IncomeForecast? get incomeForecast => _incomeForecast;
  List<FinancialTip> get tips => _tips;
  String? get errorMessage => _errorMessage;

  Future<void> loadAll() async {
    _status = PredictionStatus.loading;
    notifyListeners();

    await Future.wait([
      _loadSpendingPrediction(),
      _loadIncomePrediction(),
      _loadRecommendations(),
    ]);

    _status = PredictionStatus.loaded;
    notifyListeners();
  }

  Future<void> _loadSpendingPrediction() async {
    final (data, failure) = await _repository.getMonthlySpendingPrediction();
    if (data != null) {
      _spendingForecast = SpendingForecast.fromJson(data);
    }
  }

  Future<void> _loadIncomePrediction() async {
    final (data, failure) = await _repository.getIncomePrediction();
    if (data != null) {
      _incomeForecast = IncomeForecast.fromJson(data);
    }
  }

  Future<void> _loadRecommendations() async {
    final (data, failure) = await _repository.getBudgetRecommendations();
    if (data != null) {
      final tipsList = data['tips'] as List<dynamic>? ?? [];
      _tips = tipsList
          .map((e) => FinancialTip.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }
}
