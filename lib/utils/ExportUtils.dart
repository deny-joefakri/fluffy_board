import 'dart:typed_data';

import 'package:fluffy_board/utils/ScreenUtils.dart';
import 'package:fluffy_board/whiteboard/CanvasCustomPainter.dart';
import 'package:fluffy_board/whiteboard/DrawPoint.dart';
import 'dart:ui' as ui;
import 'package:file_saver/file_saver.dart';
import 'package:fluffy_board/whiteboard/overlays/Toolbar.dart';
import 'package:flutter/material.dart' as material;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportUtils {
  static exportPNG(List<Scribble> scribbles, List<Upload> uploads, List<TextItem> texts, ToolbarOptions toolbarOptions, ui.Offset screenSize, ui.Offset offset,
      double scale) async {
    ui.Rect rect = getBounds(scribbles);
    ui.PictureRecorder recorder = ui.PictureRecorder();
    ui.Canvas canvas = getCanvas(scribbles, uploads, texts, offset, screenSize, scale, rect, recorder);

    // Finally render the image, this can take about 8 to 25 milliseconds.
    var picture = recorder.endRecording();
    ui.Image image = await picture.toImage(
        rect.width.ceil(), rect.height.ceil());
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final buffer = byteData.buffer;
    await FileSaver.instance.saveFile(
        "FluffyBoard-image-export",
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        "png", mimeType: MimeType.PNG
    );
  }

  static exportPDF(List<Scribble> scribbles, List<Upload> uploads, List<TextItem> texts, ToolbarOptions toolbarOptions, ui.Offset screenSize, ui.Offset offset,
      double scale) async{
    ui.Rect rect = getBounds(scribbles);
    ui.PictureRecorder recorder = ui.PictureRecorder();
    ui.Canvas canvas = getCanvas(scribbles, uploads, texts, offset, screenSize, scale, rect, recorder);

    // Finally render the image, this can take about 8 to 25 milliseconds.
    var picture = recorder.endRecording();
    ui.Image image = await picture.toImage(
    rect.width.ceil(), rect.height.ceil());
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final buffer = byteData.buffer;
    var imageProvider = pw.MemoryImage(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.undefined,
        build: (pw.Context context) {
      return pw.Center(
        child: pw.Image(imageProvider),
      ); // Center
    })); //
    await FileSaver.instance.saveFile(
    "FluffyBoard-pdf-export",
    await pdf.save(),
    "pdf", mimeType: MimeType.PDF
    );
  }

  static exportScreenSizePNG(List<Scribble> scribbles, List<Upload> uploads, List<TextItem> texts, ToolbarOptions toolbarOptions, ui.Offset screenSize, ui.Offset offset,
      double scale) async {
    ui.Rect rect = material.Rect.fromLTWH(offset.dx, offset.dy, screenSize.dx, screenSize.dy);
    ui.PictureRecorder recorder = ui.PictureRecorder();
    ui.Canvas canvas = getScreenSizeCanvas(scribbles, uploads, texts, offset, screenSize, scale, rect, recorder);

    // Finally render the image, this can take about 8 to 25 milliseconds.
    var picture = recorder.endRecording();
    ui.Image image = await picture.toImage(
        rect.width.ceil(), rect.height.ceil());
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final buffer = byteData.buffer;
    await FileSaver.instance.saveFile(
        "FluffyBoard-image-screen-size-export",
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        "png", mimeType: MimeType.PNG
    );
  }

  static ui.Canvas getScreenSizeCanvas(List<Scribble> scribbles, List<Upload> uploads, List<TextItem> texts, ui.Offset offset, ui.Offset screenSize, double scale, ui.Rect rect, ui.PictureRecorder recorder){
    ui.Canvas canvas = ui.Canvas(recorder, rect);
    canvas.translate(-rect.left, -rect.top);
    canvas.scale(scale);

    ui.Paint background = ui.Paint()
      ..color = material.Colors.white;
    canvas.drawRect(rect, background);
    PainterUtils.paintScribbles(canvas, scribbles, offset, screenSize, scale, false);
    PainterUtils.paintUploads(canvas, uploads, screenSize, scale, offset, false);
    PainterUtils.paintTextItems(canvas, texts, offset, screenSize, scale, false);
    return canvas;
  }

  static ui.Canvas getCanvas(List<Scribble> scribbles, List<Upload> uploads, List<TextItem> texts, ui.Offset offset, ui.Offset screenSize, double scale, ui.Rect rect, ui.PictureRecorder recorder){
    ui.Canvas canvas = ui.Canvas(recorder, rect);
    canvas.translate(-rect.left, -rect.top);

    ui.Paint background = ui.Paint()
      ..color = material.Colors.white;
    canvas.drawRect(rect, background);
    PainterUtils.paintScribbles(canvas, scribbles, offset, screenSize, scale, false);
    PainterUtils.paintUploads(canvas, uploads, screenSize, scale, offset, false);
    PainterUtils.paintTextItems(canvas, texts, offset, screenSize, scale, false);
    return canvas;
  }

  static ui.Rect getBounds(List<Scribble> scribbles) {
    double left = 0,
        right = 0,
        top = 0,
        bottom = 0;
    for (Scribble scribble in scribbles) {
      if (scribble.leftExtremity < left)
        left = scribble.leftExtremity;
      if (scribble.rightExtremity > right)
        right = scribble.rightExtremity;
      if (scribble.topExtremity < top)
        top = scribble.topExtremity;
      if (scribble.bottomExtremity > bottom)
        bottom = scribble.bottomExtremity;
    }
    left -= 25;
    right += 25;
    top -= 25;
    bottom += 25;
    return material.Rect.fromLTRB(left, top, right, bottom);
  }
}