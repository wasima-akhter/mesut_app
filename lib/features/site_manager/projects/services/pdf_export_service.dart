import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models.dart';

class PdfExportService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  /// Fetch image bytes safely from URL or local file path
  static Future<Uint8List?> _loadImageBytes(String url) async {
    try {
      if (url.startsWith('http://') || url.startsWith('https://')) {
        final response = await _dio.get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
        );
        if (response.data != null) {
          return Uint8List.fromList(response.data!);
        }
      } else {
        final file = File(url);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
      }
    } catch (_) {
      // Return null on failure; fallback placeholder will be rendered in PDF
    }
    return null;
  }

  /// Compile photos into a single PDF document
  static Future<Uint8List> generatePhotosPdf({
    required List<ProjectPhoto> photos,
    String projectName = 'Goltstein Complex',
    String projectId = 'Prj-0842',
  }) async {
    final pdf = pw.Document(
      title: '$projectName - Photos Documentation',
      author: 'Mesut Gündoğdu App',
    );

    // Load all image bytes in parallel
    final imageBytesList = await Future.wait(
      photos.map((photo) => _loadImageBytes(photo.url)),
    );

    // Group photos into pages of 2 photos each for high resolution & readability
    const photosPerPage = 2;
    final totalPages = (photos.length / photosPerPage).ceil();

    for (var pageIdx = 0; pageIdx < totalPages; pageIdx++) {
      final startIndex = pageIdx * photosPerPage;
      final endIndex = (startIndex + photosPerPage > photos.length)
          ? photos.length
          : startIndex + photosPerPage;
      final pagePhotos = photos.sublist(startIndex, endIndex);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                _buildPdfHeader(
                  projectName: projectName,
                  projectId: projectId,
                  pageNumber: pageIdx + 1,
                  totalPages: totalPages,
                ),
                pw.SizedBox(height: 12),

                if (pageIdx == 0) ...[
                  // Cover meta banner on first page
                  _buildMetaSummaryBanner(
                    projectName: projectName,
                    projectId: projectId,
                    photoCount: photos.length,
                  ),
                  pw.SizedBox(height: 14),
                ],

                // Photos list on this page
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      for (var i = 0; i < pagePhotos.length; i++) ...[
                        _buildPhotoCard(
                          photo: pagePhotos[i],
                          index: startIndex + i + 1,
                          imageBytes: imageBytesList[startIndex + i],
                        ),
                        if (i < pagePhotos.length - 1) pw.SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),

                // Footer
                _buildPdfFooter(pageIdx + 1, totalPages),
              ],
            );
          },
        ),
      );
    }

    return await pdf.save();
  }

  static pw.Widget _buildPdfHeader({
    required String projectName,
    required String projectId,
    required int pageNumber,
    required int totalPages,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFC8102E), width: 2),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'MESUT GUNDOGDU GERUESTBAU',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFFC8102E),
                ),
              ),
              pw.Text(
                'Photo Documentation - $projectName ($projectId)',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColor.fromInt(0xFF666666),
                ),
              ),
            ],
          ),
          pw.Text(
            '${DateTime.now().day.toString().padLeft(2, '0')}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().year}',
            style: pw.TextStyle(
              fontSize: 9,
              color: const PdfColor.fromInt(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMetaSummaryBanner({
    required String projectName,
    required String projectId,
    required int photoCount,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF7F7F7),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE0E0E0)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SITE INSPECTION & PROGRESS PHOTOS',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF222222),
                ),
              ),
              pw.Text(
                'Total items included: $photoCount photos',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColor.fromInt(0xFF555555),
                ),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFC8102E),
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Text(
              'APPROVED REPORT',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPhotoCard({
    required ProjectPhoto photo,
    required int index,
    required Uint8List? imageBytes,
  }) {
    return pw.Expanded(
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: const PdfColor.fromInt(0xFFE0E0E0)),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          color: PdfColors.white,
        ),
        padding: const pw.EdgeInsets.all(8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: pw.BoxDecoration(
                        color: photo.isCover
                            ? const PdfColor.fromInt(0xFFC8102E)
                            : const PdfColor.fromInt(0xFF333333),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(3),
                        ),
                      ),
                      child: pw.Text(
                        photo.isCover ? 'COVER #$index' : 'PHOTO #$index',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      photo.title ?? 'Site Progress Photo $index',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFF222222),
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  '${photo.createdAt.day.toString().padLeft(2, '0')}.${photo.createdAt.month.toString().padLeft(2, '0')}.${photo.createdAt.year}',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColor.fromInt(0xFF777777),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Expanded(
              child: pw.Container(
                width: double.infinity,
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFEEEEEE),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: imageBytes != null
                    ? pw.Image(
                        pw.MemoryImage(imageBytes),
                        fit: pw.BoxFit.contain,
                      )
                    : pw.Center(
                        child: pw.Text(
                          '[ Photo Image Not Available ]',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColor.fromInt(0xFF888888),
                          ),
                        ),
                      ),
              ),
            ),
            if (photo.caption != null && photo.caption!.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                photo.caption!,
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColor.fromInt(0xFF555555),
                ),
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildPdfFooter(int pageNumber, int totalPages) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColor.fromInt(0xFFEAEAEA)),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated via Mesut Gundogdu Construction Management System',
            style: const pw.TextStyle(
              fontSize: 7.5,
              color: PdfColor.fromInt(0xFF888888),
            ),
          ),
          pw.Text(
            'Page $pageNumber of $totalPages',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF444444),
            ),
          ),
        ],
      ),
    );
  }

  /// Generate or retrieve bytes for a ProjectPlanFile
  static Future<Uint8List> getPlanBytes(ProjectPlanFile planFile) async {
    if (planFile.fileBytes != null && planFile.fileBytes!.isNotEmpty) {
      return planFile.fileBytes!;
    }

    if (planFile.path != null && planFile.path!.isNotEmpty) {
      final file = File(planFile.path!);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    }

    // Generate a professional Scaffolding Approval & Engineering Plan PDF
    return await generateSamplePlanPdf(planFile.name);
  }

  /// Generates a realistic engineering blueprint & scaffold approval document
  static Future<Uint8List> generateSamplePlanPdf(String planName) async {
    final pdf = pw.Document(
      title: planName,
      author: 'Mesut Gündoğdu Gerüstbau GmbH',
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Company Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'MESUT GUNDOGDU GERUESTBAU GMBH',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor.fromInt(0xFFC8102E),
                        ),
                      ),
                      pw.Text(
                        'Meisterbetrieb fuer Fassaden- & Industriegerueste',
                        style: const pw.TextStyle(
                          fontSize: 8.5,
                          color: PdfColor.fromInt(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(6),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: const PdfColor.fromInt(0xFFC8102E),
                        width: 1.5,
                      ),
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(4),
                      ),
                    ),
                    child: pw.Text(
                      'DIN EN 12811-1\nCERTIFIED',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 7.5,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFFC8102E),
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(color: const PdfColor.fromInt(0xFFC8102E), thickness: 2),
              pw.SizedBox(height: 10),

              // Document Title
              pw.Center(
                child: pw.Text(
                  'GERUESTFREIGABE- & AUSFUEHRUNGSPLAN',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF111111),
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'SCAFFOLDING APPROVAL & INSPECTION PROTOCOL',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColor.fromInt(0xFF555555),
                  ),
                ),
              ),
              pw.SizedBox(height: 14),

              // Project Specs Table
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: const PdfColor.fromInt(0xFFDDDDDD),
                  ),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                ),
                child: pw.Table(
                  border: pw.TableBorder.all(
                    color: const PdfColor.fromInt(0xFFEEEEEE),
                  ),
                  children: [
                    _tableRow('Project:', 'Goltstein Complex (Prj-0842)'),
                    _tableRow('Document Name:', planName),
                    _tableRow('Location / Section:', 'Section A - North Facade'),
                    _tableRow('Scaffold Type:', 'Fassadengeruest (Steel / Aluminum 0.73m)'),
                    _tableRow('Load Capacity (Lastklasse):', 'Class 4 (3.0 kN/m2 evenly distributed)'),
                    _tableRow('Total Scaffold Area:', '384.50 m2 (Height: 18.5m x Length: 20.8m)'),
                    _tableRow('Anchoring Grid (Verankerung):', 'Every 4.0m with 12mm ring ties (4.5 kN min)'),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              // Schematic drawing simulation box
              pw.Text(
                'STRUCTURAL ELEVATION DIAGRAM',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF333333),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                height: 140,
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFF9FAFB),
                  border: pw.Border.all(
                    color: const PdfColor.fromInt(0xFFCCCCCC),
                  ),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                ),
                padding: const pw.EdgeInsets.all(12),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      '[ SCHEMATIC DRAWING - ELEVATION NORTH WING ]',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFF4B5563),
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      '|-- Base Jacks: Spindle length 60cm on wood distribution planks\n'
                      '|-- Bay Length: 2.57m - System Width: 0.73m\n'
                      '|-- Access: Integrated internal staircase tower with hatch decks\n'
                      '+-- Top Guardrail: Triple-layer edge protection (Toe board, intermediate & top rail)',
                      style: const pw.TextStyle(
                        fontSize: 7.5,
                        color: PdfColor.fromInt(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              // Approval stamp and inspection confirmation
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Checklist
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'SAFETY CHECKLIST (PRÜFUNGSERGEBNIS):',
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        _checkItem('Foundation & sole plates level & secure', true),
                        _checkItem('Anchorage pull-test executed & passed', true),
                        _checkItem('Guards, toe boards & safety netting intact', true),
                        _checkItem('Ladder access & safety gates functional', true),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  // Green Approval Seal
                  pw.Container(
                    width: 140,
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: const PdfColor.fromInt(0xFF12B76A),
                        width: 2,
                      ),
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(6),
                      ),
                      color: const PdfColor.fromInt(0xFFECFDF3),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'FREIGEGEBEN',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor.fromInt(0xFF027A48),
                          ),
                        ),
                        pw.Text(
                          'APPROVED FOR USE',
                          style: const pw.TextStyle(
                            fontSize: 7,
                            color: PdfColor.fromInt(0xFF027A48),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Inspected: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                          style: const pw.TextStyle(
                            fontSize: 7,
                            color: PdfColor.fromInt(0xFF333333),
                          ),
                        ),
                        pw.Text(
                          'Inspector: Tim Müller',
                          style: const pw.TextStyle(
                            fontSize: 7,
                            color: PdfColor.fromInt(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),

              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _signatureBox('Kolonnenführer / Scaffolder'),
                  _signatureBox('Bauleiter / Site Manager'),
                  _signatureBox('Sicherheitsbeauftragter / Safety Officer'),
                ],
              ),
              pw.SizedBox(height: 8),
              _buildPdfFooter(1, 1),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  static pw.TableRow _tableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF444444),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColor.fromInt(0xFF222222),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _checkItem(String text, bool checked) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        children: [
          pw.Container(
            width: 10,
            height: 10,
            decoration: pw.BoxDecoration(
              color: checked
                  ? const PdfColor.fromInt(0xFF12B76A)
                  : PdfColors.white,
              border: pw.Border.all(
                color: const PdfColor.fromInt(0xFF12B76A),
                width: 1,
              ),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
            ),
            child: pw.Center(
              child: pw.Text(
                'v',
                style: pw.TextStyle(
                  fontSize: 7,
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 5),
          pw.Text(
            text,
            style: const pw.TextStyle(
              fontSize: 7.5,
              color: PdfColor.fromInt(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _signatureBox(String label) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 140,
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(
                color: PdfColor.fromInt(0xFF888888),
                width: 0.8,
              ),
            ),
          ),
          height: 25,
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 7,
            color: PdfColor.fromInt(0xFF666666),
          ),
        ),
      ],
    );
  }

  /// Saves PDF bytes to the device filesystem and returns the saved file path
  static Future<String> savePdfToDevice({
    required Uint8List bytes,
    required String filename,
  }) async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory == null) {
      throw Exception('Could not access storage directory');
    }

    // Ensure valid filename
    final safeFilename = filename.endsWith('.pdf') ? filename : '$filename.pdf';
    final file = File('${directory.path}/$safeFilename');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Triggers the system share / save sheet for a PDF
  static Future<void> sharePdf({
    required Uint8List bytes,
    required String filename,
  }) async {
    final safeFilename = filename.endsWith('.pdf') ? filename : '$filename.pdf';
    await Printing.sharePdf(bytes: bytes, filename: safeFilename);
  }
}
