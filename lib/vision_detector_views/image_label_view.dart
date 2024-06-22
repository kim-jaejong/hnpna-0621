import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'detector_view.dart';

class ImageLabelView extends StatefulWidget {
  const ImageLabelView({super.key});

  @override
  State<ImageLabelView> createState() => _ImageLabelViewState();
}

class _ImageLabelViewState extends State<ImageLabelView> {
  late ImageLabeler _imageLabeler;
  bool _canProcess = false;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;

  @override
  void initState() {
    super.initState();

    _initializeLabeler();
  }

  @override
  void dispose() {
    _canProcess = false;
    _imageLabeler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: '사진 속 물체',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
    );
  }

  void _initializeLabeler() {
    _imageLabeler =
        ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.75));
    _canProcess = true;
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    try {
      final labels = await _imageLabeler.processImage(inputImage);
      String text = '갯수: ${labels.length}\n';
      for (final label in labels) {
        text += '${label.label}(${label.confidence.toStringAsFixed(2)})\n';
      }
      _text = text;
      _customPaint = null;
    } catch (e) {
      print(e);
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
