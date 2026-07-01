enum ExportFormat { csv, pdf, excel, json }
enum ExportStatus { pending, processing, completed, failed }
enum ExportType { transactions, budgetReport, annualReport, monthlyReport, custom }

class Export {
  final int id;
  final int userId;
  final ExportType type;
  final ExportFormat format;
  final ExportStatus status;
  final String? fileUrl;
  final int? fileSizeBytes;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Export({
    required this.id,
    required this.userId,
    required this.type,
    required this.format,
    this.status = ExportStatus.pending,
    this.fileUrl,
    this.fileSizeBytes,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
  });
}
