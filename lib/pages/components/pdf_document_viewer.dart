import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfDocumentViewerPage extends StatefulWidget {
  final String pdfPath; // Chemin local ou URL
  final String? title;

  const PdfDocumentViewerPage({
    super.key,
    required this.pdfPath,
    this.title,
  });

  @override
  State<PdfDocumentViewerPage> createState() => _PdfDocumentViewerPageState();
}

class _PdfDocumentViewerPageState extends State<PdfDocumentViewerPage> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pdfViewerController.addListener(_updatePageNumber);
  }

  void _updatePageNumber() {
    setState(() {
      _currentPage = _pdfViewerController.pageNumber;
    });
  }

  @override
  void dispose() {
    _pdfViewerController.removeListener(_updatePageNumber);
    _pdfViewerController.dispose();
    super.dispose();
  }

  bool _isNetworkUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Lecteur PDF'),
        actions: [
          if (!_isLoading && _totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
            tooltip: 'Signets',
          ),
        ],
      ),
      body: Stack(
        children: [
          _isNetworkUrl(widget.pdfPath)
              ? SfPdfViewer.network(
            widget.pdfPath,
            key: _pdfViewerKey,
            controller: _pdfViewerController,
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              setState(() {
                _totalPages = details.document.pages.count;
                _isLoading = false;
              });
            },
            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur de chargement: ${details.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          )
              : SfPdfViewer.asset(
            widget.pdfPath,
            key: _pdfViewerKey,
            controller: _pdfViewerController,
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              setState(() {
                _totalPages = details.document.pages.count;
                _isLoading = false;
              });
            },
            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur de chargement: ${details.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'zoom_in',
            mini: true,
            onPressed: () {
              _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel + 0.25;
            },
            child: Icon(Icons.zoom_in, color: Theme.of(context).textTheme.bodyLarge?.color,),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoom_out',
            mini: true,
            onPressed: () {
              _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel - 0.25;
            },
            child: Icon(Icons.zoom_out, color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'previous_page',
            mini: true,
            onPressed: _currentPage > 1
                ? () {
              _pdfViewerController.previousPage();
            }
                : null,
            child: Icon(Icons.arrow_upward, color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'next_page',
            mini: true,
            onPressed: _currentPage < _totalPages
                ? () {
              _pdfViewerController.nextPage();
            }
                : null,
            child: Icon(Icons.arrow_downward, color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ],
      ),
    );
  }
}
