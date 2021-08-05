import 'dart:typed_data';

import 'package:fluffy_board/utils/image_utils.dart';
import 'package:fluffy_board/whiteboard/infinite_canvas.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket_connection.dart';
import 'package:fluffy_board/whiteboard/websocket/websocket_manager_send.dart';
import 'package:fluffy_board/whiteboard/whiteboard-data/upload.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as IMG;
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../../whiteboard_view.dart';
import '../../toolbar.dart' as Toolbar;

class UploadSettings extends StatefulWidget {
  final Upload? selectedUpload;
  final List<Upload> uploads;
  final OnUploadsChange onUploadsChange;
  final Toolbar.ToolbarOptions toolbarOptions;
  final Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  final WebsocketConnection? websocketConnection;
  final OnSaveOfflineWhiteboard onSaveOfflineWhiteboard;
  final Axis axis;

  UploadSettings(
      {required this.selectedUpload,
      required this.toolbarOptions,
      required this.onChangedToolbarOptions,
      required this.uploads,
      required this.onUploadsChange,
      required this.websocketConnection,
      required this.onSaveOfflineWhiteboard,
      required this.axis});

  @override
  _UploadSettingsState createState() => _UploadSettingsState();
}

class _UploadSettingsState extends State<UploadSettings> {
  double uploadSize = 1;
  double rotation = 0;

  @override
  @override
  Widget build(BuildContext context) {
    return Flex(
      mainAxisSize: MainAxisSize.min,
      direction: widget.axis,
      children: [
        RotatedBox(
          quarterTurns: widget.axis == Axis.vertical ? -1 : 0,
          child: Slider.adaptive(
            value: uploadSize,
            onChanged: (value) async {
              setState(() {
                uploadSize = value;
              });
            },
            onChangeEnd: (value) async {
              int index = widget.uploads.indexOf(widget.selectedUpload!);
              widget.selectedUpload!.uint8List =
                  ImageUtils.resizeImage(widget.selectedUpload!.uint8List, value);
              final ui.Codec codec = await PaintingBinding.instance!
                  .instantiateImageCodec(widget.selectedUpload!.uint8List);
              final ui.FrameInfo frameInfo = await codec.getNextFrame();

              widget.selectedUpload!.image = frameInfo.image;
              widget.uploads[index] = widget.selectedUpload!;
              widget.onUploadsChange(widget.uploads);
              widget.onSaveOfflineWhiteboard();
              WebsocketSend.sendUploadImageDataUpdate(
                  widget.selectedUpload!, widget.websocketConnection);
              setState(() {
                uploadSize = 1;
              });
            },
            min: 0.1,
            max: 2,
          ),
        ),
        SleekCircularSlider(
          appearance: CircularSliderAppearance(
              size: 50,
              startAngle: 270,
              angleRange: 360,
              infoProperties: InfoProperties(modifier: (double value) {
                final roundedValue = value.ceil().toInt().toString();
                return '$roundedValue °';
              })),
          initialValue: rotation,
          min: 0,
          max: 360,
          onChange: (value) {
            setState(() {
              rotation = value;
            });
          },
          onChangeEnd: (value) async {
            int index = widget.uploads.indexOf(widget.selectedUpload!);
            widget.selectedUpload!.uint8List =
                ImageUtils.rotateImage(widget.selectedUpload!.uint8List, value);
            final ui.Codec codec = await PaintingBinding.instance!
                .instantiateImageCodec(widget.selectedUpload!.uint8List);
            final ui.FrameInfo frameInfo = await codec.getNextFrame();

            widget.selectedUpload!.image = frameInfo.image;
            widget.uploads[index] = widget.selectedUpload!;
            widget.onUploadsChange(widget.uploads);
            widget.onSaveOfflineWhiteboard();
            WebsocketSend.sendUploadImageDataUpdate(
                widget.selectedUpload!, widget.websocketConnection);
            setState(() {
              rotation = 0;
            });
          },
        ),
        OutlinedButton(
            onPressed: () {
              setState(() {
                widget.uploads.remove(widget.selectedUpload!);
                WebsocketSend.sendUploadDelete(
                    widget.selectedUpload!, widget.websocketConnection);
                widget.onUploadsChange(widget.uploads);
                widget.onSaveOfflineWhiteboard();
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Icon(Icons.delete),
            ))
      ],
    );
  }
}