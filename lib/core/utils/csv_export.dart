import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_colors.dart';

class CsvExport {
  /// Generate a CSV string from headers and data rows
  static String generateCsv(List<String> headers, List<List<String>> rows) {
    final buffer = StringBuffer();
    buffer.writeln(headers.map((h) => _escapeCsvField(h)).join(','));
    for (final row in rows) {
      buffer.writeln(row.map((r) => _escapeCsvField(r)).join(','));
    }
    return buffer.toString();
  }

  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  /// Save CSV to a temp file and share location
  static Future<String?> saveToFile(String csvContent, String filename) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsString(csvContent);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// Format date for CSV
  static String formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  /// Export and show result to user
  static Future<void> exportAndNotify(
    BuildContext context,
    String csvContent,
    String filename,
    String label,
  ) async {
    try {
      // Save to file
      final path = await saveToFile(csvContent, filename);

      // Always copy to clipboard
      await Clipboard.setData(ClipboardData(text: csvContent));

      if (!context.mounted) return;

      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '$label u eksportua!',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'CSV u kopjua në clipboard. Mund ta ngjitni në Excel/Google Sheets.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
      } else {
        // File save failed, but clipboard worked
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.content_copy_rounded, color: AppColors.white, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('CSV u kopjua në clipboard')),
              ],
            ),
            backgroundColor: AppColors.info,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gabim gjatë eksportit: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
