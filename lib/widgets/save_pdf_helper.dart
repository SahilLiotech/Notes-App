import 'dart:convert';
import 'dart:io';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:notes_app/widgets/custom_toast.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class SavePdfHelper {
  void savePdf(String fileName, String content) async {
    final permissionStatus = await _requestStoragePermission();
    if (!permissionStatus) {
      CustomToast.shoeFailed(
        "Permission Denied",
        "Storage permission is required to save PDF.",
      );
      return;
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build:
            (context) => [
              pw.Header(
                level: 0,
                child: pw.Text(
                  fileName,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.RichText(
                text: _convertQuillToPdfTextSpan(
                  Document.fromJson(jsonDecode(content)),
                ),
              ),
            ],
      ),
    );

    final dir = await getExternalStorageDirectory();
    final outputDir = Directory("${dir!.path}/NotesApp");

    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    final file = File("${outputDir.path}/$fileName.pdf");
    await file.writeAsBytes(await pdf.save());

    CustomToast.showSuccess(
      "PDF SAVED SUCCESSFULLY",
      "PDF saved at ${file.path}",
    );

    final filePath = file.path;
    await OpenFile.open(filePath);
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }
      final status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    }
    return false;
  }

  pw.TextSpan _convertQuillToPdfTextSpan(Document document) {
    final spans = <pw.TextSpan>[];

    for (final op in document.toDelta().toList()) {
      if (op.data is String) {
        String text = op.data as String;
        final style = pw.TextStyle(fontSize: 12);

        if (op.attributes != null) {
          spans.add(
            pw.TextSpan(
              text: text,
              style: style.copyWith(
                fontWeight:
                    op.attributes!['bold'] == true ? pw.FontWeight.bold : null,
                fontStyle:
                    op.attributes!['italic'] == true
                        ? pw.FontStyle.italic
                        : null,
                decoration:
                    op.attributes!['underline'] == true
                        ? pw.TextDecoration.underline
                        : null,
              ),
            ),
          );
        } else {
          spans.add(pw.TextSpan(text: text, style: style));
        }
      }

      if (op.isInsert && op.data == '\n') {
        spans.add(pw.TextSpan(text: '\n'));
      }
    }

    return pw.TextSpan(children: spans);
  }
}
