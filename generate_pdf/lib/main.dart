import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PdfFromHtmlPage(),
    );
  }
}

class PdfFromHtmlPage extends StatefulWidget {
  const PdfFromHtmlPage({super.key});
  @override
  State<PdfFromHtmlPage> createState() => _PdfFromHtmlPageState();
}

class _PdfFromHtmlPageState extends State<PdfFromHtmlPage> {
  final TextEditingController _htmlController = TextEditingController();

  bool _isLoading = false;

  /// Parses the HTML string and converts it to a list of PDF widgets.
  Future<List<pw.Widget>> _parseHtml(String htmlContent) async {
    final document = html_parser.parse(htmlContent);
    final List<pw.Widget> widgets = [];

    // Traverse the document body
    void traverse(dom.Node node) {
      if (node is dom.Element) {
        switch (node.localName) {
          case 'h1':
            widgets.add(pw.Header(
              level: 1,
              text: node.text,
              textStyle: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ));
            widgets.add(pw.SizedBox(height: 10));
            break;
          case 'h2':
            widgets.add(pw.Header(
              level: 2,
              text: node.text,
              textStyle: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ));
            widgets.add(pw.SizedBox(height: 8));
            break;
          case 'h3':
            widgets.add(pw.Header(
              level: 3,
              text: node.text,
              textStyle: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ));
            widgets.add(pw.SizedBox(height: 6));
            break;
          case 'p':
            widgets.add(pw.Paragraph(
              text: node.text,
              style: const pw.TextStyle(fontSize: 12),
            ));
            widgets.add(pw.SizedBox(height: 8));
            break;
          case 'li':
            widgets.add(pw.Bullet(
              text: node.text,
              style: const pw.TextStyle(fontSize: 12),
            ));
            widgets.add(pw.SizedBox(height: 4));
            break;
        }
        // Recurse through children
        for (var child in node.children) {
          traverse(child);
        }
      }
    }

    traverse(document.body!);

    return widgets;
  }

  /// Generates the PDF document from the parsed HTML widgets.
  Future<Uint8List> _generatePdf(String html) async {
    final pdf = pw.Document();
    final widgets = await _parseHtml(html);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => widgets,
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Page ${context.pageNumber}/${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
        ),
      ),
    );

    return pdf.save();
  }

  /// Handles the print button press, including loading state and error handling.
  void _printPdf() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pdfData = await _generatePdf(_htmlController.text);
      await Printing.layoutPdf(onLayout: (format) => pdfData);
    } catch (e) {
      // Show an error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF from HTML')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _htmlController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'paste your html code',
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _printPdf,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Print / Preview PDF'),
            ),
          ],
        ),
      ),
    );
  }
}


