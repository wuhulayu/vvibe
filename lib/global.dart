import 'dart:io';
//import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/common/values/values.dart';
import 'package:vvibe/components/spinning.dart';
import 'package:vvibe/pages/login/login_model.dart';
import 'package:vvibe/theme.dart';
import 'package:vvibe/utils/logger.dart';
import 'package:vvibe/utils/playlist/epg_util.dart';
import 'package:window_manager/window_manager.dart';
import 'package:vvibe/utils/utils.dart';

/// 全局配置
class Global {
  /// 用户配置
  static UserLoginResponseModel? profile = UserLoginResponseModel(token: null);

  /// 是否第一次打开
  static bool isFirstOpen = false;

  /// 是否离线登录
  static bool isOfflineLogin = true;

  /// 是否 release
  static bool get isRelease => IS_RELEASE;

  /// init
  static Future<ThemeData> init({bool shouldSetSize = true}) async {
    // 运行初始
    WidgetsFlutterBinding.ensureInitialized();

    await windowManager.ensureInitialized();

    // Ruquest 模块初始化
    Request();
    // 本地存储初始化
    await LoacalStorage.init();

    //日志
    await Logger().init();

    //播放列表截图目录
    await PlaylistUtil().getSnapshotDir();

    // 读取设备第一次打开
    isFirstOpen = !LoacalStorage().getBool(STORAGE_DEVICE_ALREADY_OPEN_KEY);
    if (isFirstOpen) {
      LoacalStorage().setBool(STORAGE_DEVICE_ALREADY_OPEN_KEY, true);
    }

    // 读取离线用户信息
    var _profileJSON = LoacalStorage().getJSON(STORAGE_USER_PROFILE_KEY);
    if (_profileJSON != null) {
      profile = UserLoginResponseModel.fromJson(_profileJSON);
      isOfflineLogin = true;
    }

    // android 状态栏为透明的沉浸
    if (Platform.isAndroid) {
      SystemUiOverlayStyle systemUiOverlayStyle =
          SystemUiOverlayStyle(statusBarColor: Colors.transparent);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }
    //自定义easyloading
    EasyLoading.instance
      ..indicatorWidget = SizedBox(
        width: 40,
        child: Spinning(),
      );
    if (shouldSetSize) EpgUtil().downloadEpgDataIsolate();

    return genTheme();
  }

  // 持久化 用户信息
  static Future<bool> saveProfile(UserLoginResponseModel userResponse) {
    profile = userResponse;
    return LoacalStorage()
        .setJSON(STORAGE_USER_PROFILE_KEY, userResponse.toJson());
  }
}
