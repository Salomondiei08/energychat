import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFView extends StatefulWidget {
  const PDFView({super.key, required this.url});

  final String url;
  @override
  State<PDFView> createState() => _PDFViewState();
}

class _PDFViewState extends State<PDFView> {
  void sharePdf() {
    Share.share(widget.url, subject: 'Lien du Document PDF');
  }

  void downloadFile() async {
    showAdaptiveDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => const Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Téléchargement',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: LinearProgressIndicator(),
                  )
                ],
              ),
            ));

    HttpClient httpClient = HttpClient();
    File file;
    String filePath = '';
    String dir = Platform.isIOS
        ? (await getDownloadsDirectory())!.path
        : "/storage/emulated/0/Download/";
    print(dir);
    try {
      var request = await httpClient.getUrl(
        Uri.parse(widget.url),
      );

      String fileName = widget.url.split('/').last;
      var response = await request.close();
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '$dir/$fileName.pdf';
        file = File(filePath);
        await file.writeAsBytes(bytes);
        print(filePath);
      } else {
        filePath = 'Error code: ${response.statusCode}';
        print(filePath);
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF View'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            onPressed: () => sharePdf(),
            icon: const Icon(Icons.share),
          ),

        ],
      ),
      body:
          SfPdfViewer.network(widget.url, enableDocumentLinkAnnotation: false),
    );
  }
}
