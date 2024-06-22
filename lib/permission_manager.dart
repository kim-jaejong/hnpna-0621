// permission_manager.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class PermissionManager {
  bool _isGranted = false;
  PermissionManager();

  Future<bool> requestPermissions() async {
    print('권한 진입');
    var storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
      print('권한 허용');
      _isGranted = true;
      return _isGranted;
    } else {
      print('접근 불가');
      Future.error('Permission Denied');
      return _isGranted;
    }
  }

  bool get isGranted => _isGranted;

  bool showPermissionMessage(BuildContext context) {
    String message = '접근 권한이 필요합니다.';
    if (_isGranted) {
      message = '접근 권한이 허용되었습니다.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    return _isGranted;
  }
}
