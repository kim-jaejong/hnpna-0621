import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sqflite/sqflite.dart';

class PhotoTagger extends StatefulWidget {
  const PhotoTagger({super.key});

  @override
  State<PhotoTagger> createState() => _PhotoTaggerState();
}

class _PhotoTaggerState extends State<PhotoTagger> {
  final ImagePicker _picker = ImagePicker();
  Database? _database;
  List<Map<String, dynamic>> _photos = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = '${documentsDirectory.path}/photos.db';

    _database = await openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute('''
          CREATE TABLE photos (
            id INTEGER PRIMARY KEY,
            path TEXT,
            tags TEXT
          )
        ''');
    });
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final photos = await _database?.query('photos') ?? [];
    setState(() {
      _photos = photos;
    });
  }

  Future<void> _takePhoto(ImageSource source) async {
    final pickedFile =
        await _picker.pickImage(source: source); //ImageSource.camera);
    if (pickedFile != null) {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final imageLabeler =
          ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.7));
      try {
        final labels = await imageLabeler.processImage(inputImage);
        final tags = labels.map((label) => label.label).join(',');
        await _database
            ?.insert('photos', {'path': pickedFile.path, 'tags': tags});
        _loadPhotos();
      } catch (e) {
        // Handle any errors here
      } finally {
        imageLabeler.close();
      }
    }
  }

  Future<void> _searchPhotos(String query) async {
    final photos = await _database
            ?.query('photos', where: 'tags LIKE ?', whereArgs: ['%$query%']) ??
        [];
    setState(() {
      _photos = photos;
    });
  }

  Future<void> _processDatePickerPhotos() async {
    final DateTime? startDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now()
          .subtract(const Duration(days: 30)), // 한 달 전을 초기 날짜로 설정합니다.
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: '시작일 선택', // 다이얼로그의 타이틀을 설정합니다.
      locale: const Locale('ko'), // 다이얼로그의 언어를 한국어로 설정합니다.
    );
    if (startDate == null) return;

    final DateTime? endDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // 현재 날짜를 초기 날짜로 설정합니다.
      firstDate: startDate,
      lastDate: DateTime.now(),
      helpText: '종료일 선택',
      locale: const Locale('ko'),
    );
    if (endDate == null) return;

//    final startDate = DateTime(2024, 6, 1); // 시작 날짜를 지정합니다.
//     final endDate = DateTime(2024, 6, 10); // 마지막 날짜를 지정합니다.

    final albums = await PhotoManager.getAssetPathList(onlyAll: true);
    final recentAlbum = albums.first;

    final recentAssets = await recentAlbum.getAssetListRange(
        start: 0, end: 1000000); // 모든 사진을 가져옵니다.

    // 시작 날짜와 마지막 날짜 사이에 촬영된 사진만 필터링합니다.
    final filteredAssets = recentAssets.where((asset) {
      final assetDate = DateTime.fromMillisecondsSinceEpoch(
          asset.createDateTime.millisecondsSinceEpoch);
      return assetDate.isAfter(startDate) && assetDate.isBefore(endDate);
    }).toList();

    for (final asset in filteredAssets) {
      final file = await asset.originFile;
      final inputImage = InputImage.fromFilePath(file!.path);
      final imageLabeler =
          ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.7));

      try {
        final labels = await imageLabeler.processImage(inputImage);
        final tags = labels.map((label) => label.label).join(',');

        await _database?.insert('photos', {'path': file.path, 'tags': tags});
      } catch (e) {
        // Handle any errors here
      } finally {
        imageLabeler.close();
      }
    }

    _loadPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Photo Tagger'), actions: [
          IconButton(
              icon: const Icon(Icons.camera),
              onPressed: () => _takePhoto(ImageSource.camera)),
          IconButton(
              icon: const Icon(Icons.photo),
              onPressed: () => _takePhoto(ImageSource.gallery)),
          IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _processDatePickerPhotos),
          // 갤러리
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                final query = await _showSearchDialog();
                if (query != null && query.isNotEmpty) {
                  _searchPhotos(query);
                }
              })
        ]),
        body: ListView.builder(
            itemCount: _photos.length,
            itemBuilder: (context, index) {
              final photo = _photos[index];
              return ListTile(
                  leading: Image.file(File(photo['path'])),
                  title: Text(photo['tags']));
            }));
  }

  Future<String?> _showSearchDialog() async {
    return showDialog<String>(
        context: context,
        builder: (context) {
          String query = '';
          return AlertDialog(
              title: const Text('Search Photos'),
              content: TextField(
                  onChanged: (value) {
                    query = value;
                  },
                  decoration:
                      const InputDecoration(hintText: 'Enter tags to search')),
              actions: [
                TextButton(
                    child: const Text('Search'),
                    onPressed: () {
                      Navigator.of(context).pop(query);
                    })
              ]);
        });
  }
}

//Flutter를 사용하여 사진을 촬영하고, 사진의 내용을 분석하여 태그를 저장하고 검색하는 기능을 구현할 수 있습니다.
// 이를 위해 다음과 같은 라이브러리와 서비스를 사용할 수 있습니다:
//
// image_picker: 사진 촬영 및 선택을 위한 플러그인
// firebase_ml_vision 또는 google_ml_kit: 사진의 내용을 분석하기 위한 머신러닝 라이브러리
// sqflite: 태그와 사진 경로를 로컬 데이터베이스에 저장하기 위한 SQLite 플러그인
// 이 코드는 기본적인 예제이므로 실제 애플리케이션에서는 에러 처리, 성능 최적화 등을 추가로 고려해야 합니다.

//이 코드는 Flutter를 사용하여 사진을 촬영하고,
// Google ML Kit의 ImageLabeler를 사용하여 사진의 라벨을 추출하고,
// 이 라벨을 SQLite 데이터베이스에 저장하는 기능을 구현하고 있습니다.
// 또한, 사용자가 태그를 입력하여 사진을 검색하는 기능도 구현하고 있습니다.
// 이미지를 촬영하고 라벨을 추출하는 부분은 _takePhoto 메서드에서 처리하고 있습니다.
// 이 메서드는 ImagePicker를 사용하여 사진을 촬영하고, ImageLabeler를 사용하여 사진에서 라벨을 추출합니다.
// 추출된 라벨은 데이터베이스에 저장되며, 이후에 라벨을 기반으로 사진을 검색할 수 있습니다.
// 사진을 검색하는 기능은 _searchPhotos 메서드에서 처리하고 있습니다.
// 이 메서드는 사용자가 입력한 쿼리를 기반으로 데이터베이스에서 사진을 검색합니다.
// 검색 결과는 _photos 리스트에 저장되며, 이 리스트는 build 메서드에서 ListView.builder를 사용하여 화면에 표시됩니다.

//갤러리에서 이미지를 선택하는 기능  : _selectPhoto
// ImagePicker를 사용하여 갤러리에서 이미지를 선택하고, 선택한 이미지에 대해 라벨링을 수행한 후,
// 라벨을 데이터베이스에 저장합니다.

//=============================================================
// 라벨을 직접 한글로 번역하는 추가 작업을 위해 Google Cloud Translation API와 같은 번역 서비스를 사용하여
// 데이터베이스에 저장하고 검색도 영문과 한글로 동시에 할 수 있는 코드

// Google Cloud Translation API를 사용하여 라벨을 한글로 번역하려면,
// 먼저 Google Cloud Translation API를 사용할 수 있도록 설정해야 합니다.
// 이를 위해 Google Cloud Console에서 새 프로젝트를 생성하고,
// Translation API를 활성화하고, API 키를 생성해야 합니다.  그런
// 다음, googleapis 패키지를 사용하여 Google Cloud Translation API를 호출할 수 있습니다.
// 이 패키지는 Flutter에서 Google APIs를 사용하는 데 필요한 클라이언트 라이브러리를 제공합니다.
// dependencies:
//   googleapis: ^0.60.0
//translateLabels 함수를 만들어 라벨을 한글로 번역합니다.
// 이 함수는 라벨의 리스트를 입력으로 받아, 각 라벨을 한글로 번역한 후, 번역된 라벨의 리스트를 반환합니다:
// import 'package:googleapis/translate/v2.dart' as translate;
// import 'package:googleapis_auth/auth_io.dart' as auth;
//
// final _credentials = auth.ServiceAccountCredentials.fromJson({
//   // 여기에 Google Cloud Console에서 생성한 서비스 계정 키를 입력합니다.
// });
//
// final _scopes = [translate.TranslateApi.CloudTranslationScope];
//
// Future<List<String>> translateLabels(List<String> labels) async {
//   final client = await auth.clientViaServiceAccount(_credentials, _scopes);
//   final translateApi = translate.TranslateApi(client);
//
//   final response = await translateApi.translations.list(labels, 'ko');
//   return response.translations.map((t) => t.translatedText).toList();
// }

//이제 translateLabels 함수를 사용하여 라벨을 한글로 번역하고, 번역된 라벨을 데이터베이스에 저장할 수 있습니다:

//final labels = await imageLabeler.processImage(inputImage);
// final englishTags = labels.map((label) => label.label).toList();
// final koreanTags = await translateLabels(englishTags);
//
// await _database?.insert('photos', {'path': file.path, 'tags': englishTags.join(','), 'translated_tags': koreanTags.join(',')});

//이 코드는 라벨을 한글로 번역한 후, 원본 라벨과 번역된 라벨을 모두 데이터베이스에 저장합니다.
// 이렇게 하면, 사용자가 영어 또는 한글로 검색할 때 모두 결과를 반환할 수 있습니다.
// 검색 기능을 구현할 때는, 사용자가 입력한 쿼리가 원본 라벨 또는 번역된 라벨 중 어느 것과도 일치하는 사진을 반환해야 합니다.
// 이를 위해 SQL 쿼리에서 OR 연산자를 사용할 수 있습니다:

// final query = 'SELECT * FROM photos WHERE tags LIKE ? OR translated_tags LIKE ?';
// final results = await _database?.rawQuery(query, ['%$searchQuery%', '%$searchQuery%']);

//이 코드는 사용자가 입력한 검색 쿼리가 원본 라벨 또는 번역된 라벨 중 어느 것과도 일치하는 사진을 검색합니다.

// 안드로이드 매니페스트에 인터넷 권한을 추가할 것
//<uses-permission android:name="android.permission.INTERNET" />
