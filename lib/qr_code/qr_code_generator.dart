import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeGenerator extends StatefulWidget {
  const QrCodeGenerator({super.key});

  @override
  State<QrCodeGenerator> createState() => _QrCodeGeneratorState();
}

class _QrCodeGeneratorState extends State<QrCodeGenerator> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter text to generate QR code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              child: const Text('Generate QR Code'),
            ),
            const SizedBox(height: 20),
            if (_controller.text.isNotEmpty)
              RepaintBoundary(
                key: _qrKey,
                child: QrImageView(
                  data: _controller.text,
                  version: QrVersions.auto,
                  size: 100.0,
                  backgroundColor: Colors.white,
                ),
              ),
            ElevatedButton(
              onPressed: () {
                _saveQrImage();
              },
              child: const Text('Save QR Code'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveQrImage() async {
    RenderRepaintBoundary boundary =
        _qrKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    File imgFile = File('$directory/qr.png');
    await imgFile.writeAsBytes(pngBytes);
    final result = await ImageGallerySaver.saveImage(pngBytes);
    print(result);
  }
}
