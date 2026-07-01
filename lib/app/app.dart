import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_me/core/network/api_client.dart';
import 'package:money_me/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:money_me/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:money_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:money_me/features/auth/domain/usecases/login_usecase.dart';
import 'package:money_me/features/auth/domain/usecases/register_usecase.dart';
import 'package:money_me/features/auth/presentation/pages/auth_gate.dart';
import 'package:money_me/features/auth/presentation/providers/auth_provider.dart';
import 'package:money_me/features/ocr/data/datasources/ocr_remote_datasource.dart';
import 'package:money_me/features/ocr/data/repositories/ocr_repository_impl.dart';
import 'package:money_me/features/ocr/domain/usecases/scan_receipt_usecase.dart';
import 'package:money_me/features/ocr/presentation/providers/ocr_provider.dart';
import 'package:money_me/features/analysis/data/datasources/analysis_remote_datasource.dart';
import 'package:money_me/features/analysis/data/repositories/analysis_repository_impl.dart';
import 'package:money_me/features/analysis/presentation/providers/analysis_provider.dart';
import 'package:money_me/features/predictions/data/datasources/prediction_remote_datasource.dart';
import 'package:money_me/features/predictions/data/repositories/prediction_repository_impl.dart';
import 'package:money_me/features/predictions/presentation/providers/prediction_provider.dart';
import 'package:money_me/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:money_me/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:money_me/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:money_me/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:money_me/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:money_me/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'theme.dart';

class MoneyMeApp extends StatelessWidget {
  const MoneyMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) {
            final client = ApiClient();
            final datasource = AuthRemoteDataSource(client);
            final repo = AuthRepositoryImpl(datasource) as AuthRepository;
            return AuthProvider(LoginUseCase(repo), RegisterUseCase(repo), repo);
          },
        ),
        ChangeNotifierProvider<OcrProvider>(
          create: (context) {
            final client = ApiClient();
            final authProvider = context.read<AuthProvider>();
            final datasource = OcrRemoteDataSource(client, authProvider);
            final repo = OcrRepositoryImpl(datasource);
            return OcrProvider(ScanReceiptUseCase(repo));
          },
        ),
        ChangeNotifierProvider<AnalysisProvider>(
          create: (_) {
            final client = ApiClient();
            final datasource = AnalysisRemoteDataSource(client);
            final repo = AnalysisRepositoryImpl(datasource);
            return AnalysisProvider(repo);
          },
        ),
        ChangeNotifierProvider<PredictionProvider>(
          create: (_) {
            final client = ApiClient();
            final datasource = PredictionRemoteDataSource(client);
            final repo = PredictionRepositoryImpl(datasource);
            return PredictionProvider(repo);
          },
        ),
        ChangeNotifierProvider<TransactionProvider>(
          create: (context) {
            final client = ApiClient();
            final authProvider = context.read<AuthProvider>();
            final datasource = TransactionRemoteDataSource(
              client: client,
              authProvider: authProvider,
            );
            final repo = TransactionRepositoryImpl(dataSource: datasource);
            return TransactionProvider(repository: repo);
          },
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (context) {
            final client = ApiClient();
            final authProvider = context.read<AuthProvider>();
            final datasource = DashboardRemoteDataSource(
              client: client,
              authProvider: authProvider,
            );
            final repo = DashboardRepositoryImpl(dataSource: datasource);
            return DashboardProvider(repository: repo);
          },
        ),
      ],
      child: MaterialApp(
        title: 'Money Me',
        theme: appTheme,
        home: const AuthGate(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
