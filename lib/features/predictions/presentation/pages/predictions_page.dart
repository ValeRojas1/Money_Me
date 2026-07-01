import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_me/app/theme.dart';
import 'package:money_me/features/predictions/domain/entities/prediction_data.dart';
import 'package:money_me/features/predictions/presentation/providers/prediction_provider.dart';
import 'package:money_me/shared/widgets/money_card.dart';

class PredictionsPage extends StatelessWidget {
  const PredictionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Predictions')),
      body: Consumer<PredictionProvider>(
        builder: (context, provider, _) {
          if (provider.status == PredictionStatus.initial) {
            provider.loadAll();
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.status == PredictionStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.status == PredictionStatus.error) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, size: 48, color: AppColors.textTertiary),
                    SizedBox(height: AppSpacing.md),
                    Text(provider.errorMessage ?? 'Not enough data for predictions yet',
                        style: AppTypography.bodyMedium, textAlign: TextAlign.center),
                    SizedBox(height: AppSpacing.sm),
                    Text('Keep tracking your transactions regularly.',
                        style: AppTypography.bodySmall, textAlign: TextAlign.center),
                    SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: provider.loadAll,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => provider.loadAll(),
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.md),
              children: [
                _ForecastCard(provider),
                SizedBox(height: AppSpacing.md),
                _IncomeCard(provider),
                SizedBox(height: AppSpacing.md),
                _TipsCard(provider),
                SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final PredictionProvider provider;
  const _ForecastCard(this.provider);

  @override
  Widget build(BuildContext context) {
    final forecast = provider.spendingForecast;
    if (forecast == null) return const SizedBox.shrink();

    final isUp = forecast.trendDirection == 'increasing';

    return MoneyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.accent, size: 20),
              SizedBox(width: AppSpacing.sm),
              Text('Next Month Forecast', style: AppTypography.titleMedium),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              '\$${forecast.predictedAmount.toStringAsFixed(2)}',
              style: AppTypography.amountLarge.copyWith(color: isUp ? AppColors.expense : AppColors.income),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUp ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: isUp ? AppColors.expense : AppColors.income,
                ),
                SizedBox(width: AppSpacing.xs),
                Text('Confidence: ${(forecast.confidence * 100).toStringAsFixed(0)}%',
                    style: AppTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeCard extends StatelessWidget {
  final PredictionProvider provider;
  const _IncomeCard(this.provider);

  @override
  Widget build(BuildContext context) {
    final forecast = provider.incomeForecast;
    if (forecast == null) return const SizedBox.shrink();

    return MoneyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance, color: AppColors.income, size: 20),
              SizedBox(width: AppSpacing.sm),
              Text('Income Forecast', style: AppTypography.titleMedium),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              '\$${forecast.predictedIncome.toStringAsFixed(2)}',
              style: AppTypography.amountLarge.copyWith(color: AppColors.income),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              forecast.isRegular ? 'Regular income pattern detected' : 'Variable income',
              style: AppTypography.bodySmall.copyWith(
                color: forecast.isRegular ? AppColors.income : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  final PredictionProvider provider;
  const _TipsCard(this.provider);

  @override
  Widget build(BuildContext context) {
    final tips = provider.tips;
    if (tips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Financial Tips', style: AppTypography.titleMedium),
        SizedBox(height: AppSpacing.sm),
        ...tips.map((tip) => Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: MoneyCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  tip.icon == 'savings'
                      ? Icons.savings_outlined
                      : tip.icon == 'warning'
                          ? Icons.warning_amber_outlined
                          : Icons.lightbulb_outline,
                  size: 20,
                  color: AppColors.accent,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tip.title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text(tip.message, style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}
