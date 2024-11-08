import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:text_app/files/internetchecker.dart';

class ChatGptResponsePage extends StatefulWidget {
  final String response;

  ChatGptResponsePage({required this.response});

  @override
  _ChatGptResponsePageState createState() => _ChatGptResponsePageState();
}

class _ChatGptResponsePageState extends State<ChatGptResponsePage> {

  @override
  void initState() {
    super.initState();


    InternetConnectionChecker.checkInternetConnection(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Questions and Answers',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () => _printDocument(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  "Sample Exam Paper",
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Marks: 40',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Duration: 3 hrs',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Instructions:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '1. Answer all questions.',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                '2. Write your answers clearly.',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                '3. You have 3 hours to complete the exam.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 25),
              Center(
                child: Text(
                  "Answer the following questions:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.response,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _printDocument() async {
    final pdf = await _generatePdf();
    Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();
    var message = widget.response;

    // Split the response into paragraphs
    List<String> paragraphs = message.split('\n');

    // Set the maximum number of questions and answers per page
    const maxQuestionsPerPage = 15; // Adjust this value as needed and 11

    // Calculate the total number of pages needed
    final pageCount = (paragraphs.length / maxQuestionsPerPage).ceil();

    // Add header components (to be displayed only on the first page)
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Center(
                  child: pw.Text(
                    "Sample Exam Paper",
                    style: pw.TextStyle(
                      fontSize: 29,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Marks: 40',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Duration: 3 hrs',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 19),
                pw.Text(
                  'Instructions:',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  '1. Answer all questions.',
                  style: pw.TextStyle(fontSize: 18),
                ),
                pw.Text(
                  '2. Write your answers clearly.',
                  style: pw.TextStyle(fontSize: 18),
                ),
                pw.Text(
                  '3. You have 3 hours to complete the exam.',
                  style: pw.TextStyle(fontSize: 18),
                ),
                pw.SizedBox(height: 30),
                pw.Center(
                  child: pw.Text(
                    "Answer the following questions:",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                ),
                pw.SizedBox(height: 27),
                // Include questions and answers for the first page
                ...paragraphs
                    .take(maxQuestionsPerPage)
                    .map((paragraph) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    pw.Text(
                      paragraph,
                      style: pw.TextStyle(fontSize: 18),
                    ),
                    pw.SizedBox(height: 8), // Adjust the space as needed
                  ],
                )),
              ],
            ),
          );
        },
      ),
    );

    // Add content for the rest of the pages
    for (var i = 1; i < pageCount; i++) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // Questions and answers for the current page
                  ...paragraphs
                      .skip(i * maxQuestionsPerPage)
                      .take(maxQuestionsPerPage)
                      .map((paragraph) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Text(
                        paragraph,
                        style: pw.TextStyle(fontSize: 18),
                      ),
                      pw.SizedBox(height: 8), // Adjust the space as needed
                    ],
                  )),
                ],
              ),
            );
          },
        ),
      );
    }
    return pdf;
  }
}


