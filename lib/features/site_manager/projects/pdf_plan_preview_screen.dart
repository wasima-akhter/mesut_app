import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:printing/printing.dart';

import 'models.dart';
import 'services/pdf_export_service.dart';

class PdfPlanPreviewScreen extends StatefulWidget {
  const PdfPlanPreviewScreen({
    super.key,
    required this.planFile,
    this.projectName = 'Goltstein Complex',
  });

  final ProjectPlanFile planFile;
  final String projectName;

  @override
  State<PdfPlanPreviewScreen> createState() => _PdfPlanPreviewScreenState();
}

class _PdfPlanPreviewScreenState extends State<PdfPlanPreviewScreen> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bytes = await PdfExportService.getPlanBytes(widget.planFile);
      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _downloadPdf() async {
    if (_pdfBytes == null) return;

    try {
      await PdfExportService.savePdfToDevice(
        bytes: _pdfBytes!,
        filename: widget.planFile.name,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF12B76A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          content: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Downloaded: ${widget.planFile.name}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'Share',
            textColor: Colors.white,
            onPressed: () {
              PdfExportService.sharePdf(
                bytes: _pdfBytes!,
                filename: widget.planFile.name,
              );
            },
          ),
        ),
      );
    } catch (_) {
      // Fallback to share sheet
      if (!mounted) return;
      await PdfExportService.sharePdf(
        bytes: _pdfBytes!,
        filename: widget.planFile.name,
      );
    }
  }

  Future<void> _sharePdf() async {
    if (_pdfBytes == null) return;
    await PdfExportService.sharePdf(
      bytes: _pdfBytes!,
      filename: widget.planFile.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20.sp,
            color: const Color(0xFF222222),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.planFile.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111111),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              '${widget.planFile.size} • ${widget.projectName}',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF666666),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Share PDF',
            icon: Icon(
              Icons.share_outlined,
              size: 22.sp,
              color: const Color(0xFF333333),
            ),
            onPressed: _pdfBytes == null ? null : _sharePdf,
          ),
          IconButton(
            tooltip: 'Download PDF',
            icon: Icon(
              Icons.download_rounded,
              size: 24.sp,
              color: const Color(0xFFC8102E),
            ),
            onPressed: _pdfBytes == null ? null : _downloadPdf,
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC8102E)),
            ),
            SizedBox(height: 16.h),
            Text(
              'Loading PDF Plan...',
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF555555),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 50.sp,
                color: const Color(0xFFC8102E),
              ),
              SizedBox(height: 12.h),
              Text(
                'Could not load PDF plan',
                style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6.h),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: const Color(0xFF777777),
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: _loadPdf,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC8102E),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return PdfPreview(
      build: (format) async => _pdfBytes!,
      canChangeOrientation: false,
      canChangePageFormat: false,
      canDebug: false,
      dynamicLayout: false,
      scrollViewDecoration: const BoxDecoration(color: Color(0xFFE9ECEF)),
      pdfFileName: widget.planFile.name,
      actions: [
        PdfPreviewAction(
          icon: const Icon(Icons.download_rounded),
          onPressed: (context, build, pageFormat) async {
            await _downloadPdf();
          },
        ),
      ],
    );
  }
}
