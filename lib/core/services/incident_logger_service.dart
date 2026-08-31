import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncidentLogEntry {
  final String timestamp;
  final String action;
  final String details;

  IncidentLogEntry({required this.timestamp, required this.action, required this.details});

  Map<String, String> toMap() => {'timestamp': timestamp, 'action': action, 'details': details};
  factory IncidentLogEntry.fromMap(Map<String, dynamic> map) => IncidentLogEntry(
        timestamp: map['timestamp'] ?? '',
        action: map['action'] ?? '',
        details: map['details'] ?? '',
      );
}

class IncidentLoggerService {
  static const String _logKey = 'connect_incident_audit_trail';

  static Future<void> logEvent(String action, String details) async {
    final prefs = await SharedPreferences.getInstance();
    final rawLogs = prefs.getStringList(_logKey) ?? [];
    final entry = IncidentLogEntry(
      timestamp: DateTime.now().toIso8601String(),
      action: action,
      details: details,
    );
    rawLogs.add(jsonEncode(entry.toMap()));
    await prefs.setStringList(_logKey, rawLogs);
  }

  static Future<List<IncidentLogEntry>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawLogs = prefs.getStringList(_logKey) ?? [];
    return rawLogs.map((e) => IncidentLogEntry.fromMap(jsonDecode(e))).toList();
  }

  static Future<void> exportPdfReport(String problem, String location) async {
    final logs = await getLogs();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                  level: 0,
                  child: pw.Text('CONNECT Incident Audit Report',
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 10),
              pw.Text('Incident Topic: $problem',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text('Location Context: $location', style: const pw.TextStyle(fontSize: 12)),
              pw.Text('Report Generated: ${DateTime.now().toString()}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text('Timeline Audit Trail:',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              ...logs.map((log) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(
                            width: 130,
                            child: pw.Text(log.timestamp.substring(0, 19),
                                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700))),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(log.action,
                                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                              pw.Text(log.details, style: const pw.TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}