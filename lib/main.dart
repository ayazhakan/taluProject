import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show ByteData, rootBundle;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excel to PDF Converter',
      home: ExcelToPdfConverter(),
    );
  }
}

class ExcelToPdfConverter extends StatelessWidget {
  Future<void> _convertExcelToPdf() async {
    // Open the Excel file
    ByteData data = await rootBundle.load("assets/A2823-0251yikamaoncesi.xlsx");
    List<int> bytes = data.buffer.asUint8List();
    var excel = Excel.decodeBytes(bytes);

    // Create a PDF document
    final pdf = pw.Document();

    // Add each sheet as a page in PDF
    for (var table in excel.tables.keys) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Table(
              children: [
                for (var row in excel.tables[table]!.rows)
                  pw.TableRow(
                    children: [
                      for (var cell in row)
                        if(cell!=null)
                        pw.Container(
                          child: pw.Text(cell.value.toString()),
                          padding: pw.EdgeInsets.all(5),
                        ),
                    ],
                  ),
              ],
            );
          },
        ),
      );
    }

    // Save the PDF file
    final output = await getExternalStorageDirectory();
    final pdfFile = File("${output!.path}/converted_file.pdf");
    await pdfFile.writeAsBytes(await pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Excel to PDF Converter'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _convertExcelToPdf,
          child: Text('Convert Excel to PDF'),
        ),
      ),
    );
  }
}
