import 'package:docs_gee/docs_gee.dart';
import 'package:file_saver/file_saver.dart';

enum ReportExportFormat { pdf, word }

class ReportExportService {
  Future<void> export({
    required String title,
    required String fileName,
    required List<List<String>> rows,
    required ReportExportFormat format,
  }) async {
    final document = Document(title: title, author: 'Congregation Reporting');
    document.addParagraph(Paragraph.heading(title, level: 1));
    document.addParagraph(
      Paragraph.text('${rows.length} ${rows.length == 1 ? 'report' : 'reports'}'),
    );
    document.addTable(
      Table(
        rows: [
          TableRow(
            cells: [
              for (final heading in const [
                'Group',
                'Member',
                'Reporting month',
                'Type',
                'Hours',
                'Bible studies',
                'Participated',
                'Submitted',
                'Status',
              ])
                TableCell.text(heading, backgroundColor: 'EDFCE9'),
            ],
          ),
          for (final row in rows)
            TableRow(cells: [for (final value in row) TableCell.text(value)]),
        ],
      ),
    );

    final bytes = switch (format) {
      ReportExportFormat.pdf => PdfGenerator().generate(document),
      ReportExportFormat.word => DocxGenerator().generate(document),
    };
    final extension = format == ReportExportFormat.pdf ? 'pdf' : 'docx';
    final mimeType = format == ReportExportFormat.pdf
        ? MimeType.pdf
        : MimeType.microsoftWord;
    final safeName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');

    await FileSaver.instance.saveFile(
      name: safeName,
      bytes: bytes,
      fileExtension: extension,
      mimeType: mimeType,
    );
  }
}
