import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

class GalleryView extends StatefulWidget {
  const GalleryView(
      {super.key,
      required this.title,
      this.text,
      required this.onImage,
      required this.onDetectorViewModeChanged});

  final String title;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function()? onDetectorViewModeChanged;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  File? _image;
  String? _path;
  ImagePicker? _imagePicker;

  @override
  void initState() {
    super.initState();

    _imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            // Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 16),
            //     child: ElevatedButton(
            //         child: const Text('갤러리'),
            //         onPressed: () => _getImage(ImageSource.gallery))),
            // Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 16),
            //     child: ElevatedButton(
            //         child: const Text('촬영'),
            //         onPressed: () => _getImage(ImageSource.camera))),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () => _getImage(ImageSource.gallery),
                child: const Icon(Icons.photo //: Icons.camera,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () => _getImage(ImageSource.camera),
                child: const Icon(
                  Icons.camera,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: widget.onDetectorViewModeChanged,
                child: const Icon(
                  Icons.camera_alt_outlined, //: Icons.camera,
                ),
              ),
            ),
          ],
        ),
        body: _galleryBody());
  }

  Widget _galleryBody() {
    return ListView(shrinkWrap: true, children: [
      _image != null
          ? SizedBox(
              height: 400,
              width: 400,
              child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[Image.file(_image!)]))
          : const Icon(Icons.image, size: 200),
      // Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 16),
      //     child: ElevatedButton(
      //         child: const Text('갤러리'),
      //         onPressed: () => _getImage(ImageSource.gallery))),
      // Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 16),
      //     child: ElevatedButton(
      //         child: const Text('촬영'),
      //         onPressed: () => _getImage(ImageSource.camera))),
      if (_image != null)
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
//                '${_path == null ? '' : 'Image path: $_path'}\n\n${widget.text ?? ''}'))
            '${_path == null ? '' : ''}${widget.text ?? ''}',
            style: const TextStyle(fontSize: 8, color: Colors.black),
          ),
        ),
    ]);
  }

  Future _getImage(ImageSource source) async {
    setState(() {
      _image = null;
      _path = null;
    });
    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      _processFile(pickedFile.path);
    }
  }

  Future _processFile(String path) async {
    setState(() {
      _image = File(path);
    });
    _path = path;
    final inputImage = InputImage.fromFilePath(path);
    widget.onImage(inputImage);
  }
}
