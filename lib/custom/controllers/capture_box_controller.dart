import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as image;
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:page_testes/flutter_flow/flutter_flow_util.dart';

class CaptureBoxController {
  final GlobalKey boxKey = GlobalKey();

  String get _fileName => "Recibo - ${DateFormat("dd_MM_yyyy").format(DateTime.now())}";

  Future<Uint8List?> _widgetToPng() async {
    final RenderRepaintBoundary? boundary = boxKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    final ui.Image? image = await boundary?.toImage();
    final ByteData? byteData = await image?.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }

  Future<Uint8List?> _pngToJpg(Uint8List pngByteList) async {
    final image.Image? png = image.decodePng(pngByteList);

    if(png != null) {
      return image.encodeJpg(png);
    }
    
    return null;
  }

  Future<Uint8List?> _pngToPdf(Uint8List pngByteList) async {
    final pw.Document doc = pw.Document(
      pageMode: PdfPageMode.thumbs,
      compress: false,
      title: _fileName,
      author: "Criar Games DevTeam",
      creator: "Criar Games",
    );

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.undefined,
      build: (pw.Context context) => pw.Center(
        child: pw.Image(pw.MemoryImage(pngByteList)),
      ),
    ));

    return await doc.save();
  }

  void _downloadBytes({
    required Uint8List byteList,
    required String fileName,
    required String fileExtension
  }) => html.AnchorElement(
    href: "data:application/octet-stream;charset=utf-16le;base64,${base64Encode(byteList)}"
  )..setAttribute("download", "$fileName.$fileExtension")
  ..click();

  void downloadPng() async {
    Uint8List? pngByteList = await _widgetToPng();

    if(pngByteList != null) {
      _downloadBytes(
        byteList: pngByteList, 
        fileName: _fileName, 
        fileExtension: "png"
      );

      return;
    }

    throw Exception("An error occurred during the Widget conversion to PNG.");
  }

  void downloadJpg() async {
    Uint8List? pngByteList = await _widgetToPng();

    if(pngByteList != null) {
      Uint8List? jpgByteList = await _pngToJpg(pngByteList);

      if(jpgByteList != null) {
        _downloadBytes(
          byteList: jpgByteList, 
          fileName: _fileName, 
          fileExtension: "jpg"
        );

        return;
      }
    }

    throw Exception("An error occurred during the Widget conversion to JPG.");
  }

  void printPdf() async {
    Uint8List? pngByteList = await _widgetToPng();

    if(pngByteList != null) {
      Uint8List? pdfByteList = await _pngToPdf(pngByteList);

      if(
        pdfByteList != null
        && !(await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) => pdfByteList,
          name: _fileName,
          format: PdfPageFormat.a4
        ))
      ) {
        throw Exception("An error occurred while gererating the printing layout.");
      }

      return;
    }

    throw Exception("An error occurred during the Widget conversion to PDF.");
  }
}