import 'package:flutter/material.dart';
// import 'Notice/notice.dart';
// import 'chatting/chatting.dart';
// //import 'choose_pictures/choose_pictures.dart';
// import 'login/login.dart';
// import 'making_print_type/making_print_type.dart';
import 'phone_auth.dart';
import 'photo_tagger/photo_tagger.dart';
import 'qr_code/qr_code_generator.dart';
import 'vision_detector_views/image_label_view.dart';
// import 'previous_albums/previous_albums.dart';
// import 'rebuild_folders/rebuild_folders.dart';
// import 'request_print/request_print.dart';
// import 'view_selected_pictures/view_selected_pictures.dart';

class Routes {
  static String loginPage = "/login";
  static String rebuildFoldersPage = "/rebuildFolders";
//  static String choosePicturesPage = "/choosePictures";
  static String photoTaggerPage = "/choosePictures";
  static String viewSelectedPicturesPage = "/viewSelectedPictures";
  static String makingPrintTypePage = "/makingPrintType";
  static String requestPrintPage = "/requestPrint";
  static String previousAlbumsPage = "/previousAlbums";
  static String chattingPage = "/chatting";
  static String noticePage = "/notice";
  static String imageLabelViewPage = "/imageLabelView";
  static String qrCodeGeneratorPage = "/qrCodeGenerator";
  static String phoneAuthPage = "/phoneAuth";
}

Map<String, Widget Function(BuildContext)> getRouters() {
  return {
//     Routes.loginPage: (context) => const Login(),
//     Routes.rebuildFoldersPage: (context) => const RebuildFolders(),
// //    Routes.choosePicturesPage: (context) => const ChoosePictures(),
    Routes.photoTaggerPage: (context) => const PhotoTagger(),
//     Routes.viewSelectedPicturesPage: (context) => const ViewSelectedPictures(),
//     Routes.makingPrintTypePage: (context) => const MakingPrintType(),
//     Routes.requestPrintPage: (context) => const RequestPrint(),
//     Routes.previousAlbumsPage: (context) => const PreviousAlbums(),
//     Routes.chattingPage: (context) => const Chatting(),
//     Routes.noticePage: (context) => const Notice(),
    Routes.imageLabelViewPage: (context) => const ImageLabelView(),
    Routes.qrCodeGeneratorPage: (context) => const QrCodeGenerator(),
    Routes.phoneAuthPage: (context) => const PhoneAuth(),
  };
}

// RebuildFolders(),
// // 주제에 따라 사진 선택하기
// // 날짜별 (년 월 기간 )
// // 위치별 (지역별)
// // 사람. 꽃, 해변, 산, 동물, 건물, 음식, 물건, 풍경, 기타
// ChoosePictures(),
// ViewSelectedPictures(),
// MakingPrintType(),
// RequestPrint(),
//  PreviousAlbums(),
//   다른 사람 작품 보기
//   다른 사람에게  보여주기(무료)
// Chatting(),
// Notice(),
