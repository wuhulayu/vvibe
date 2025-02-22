//开始连接斗鱼、忽悠、b站的弹幕
import 'package:vvibe/models/live_danmaku_item.dart';
import 'package:vvibe/models/playlist_item.dart';
import 'package:vvibe/services/danmaku/danmaku_type.dart';
import 'package:vvibe/services/services.dart';
import 'package:vvibe/utils/logger.dart';

class DanmakuService {
  static DanmakuService _instance = new DanmakuService._();
  factory DanmakuService() => _instance;

  DanmakuService._();
  DouyuDnamakuService? _dy;
  BilibiliDanmakuService? _bl;
  HuyaDanmakuService? _hy;

  bool canConnDanmaku(PlayListItem item, RegExp groupReg, RegExp proxyUrlReg) {
    try {
      final groupMatch = item.group?.contains(groupReg) ?? false;
      final uri = Uri.parse(item.url.trim()),
          urlMatch1 = uri.path.contains(proxyUrlReg);

      return groupMatch || urlMatch1;
    } catch (e) {
      return false;
    }
  }

//开始连接斗鱼、虎牙、b站的弹幕
  void start(
      PlayListItem item, void renderDanmaku(LiveDanmakuItem? data)) async {
    try {
      stop();

      if (!(item.tvgId != null && item.tvgId!.isNotEmpty)) return;
      final String rid = item.tvgId!;
      MyLogger.info('即将登录弹幕 ${item.group} ${item.name} ${item.tvgId}');
      final ext = item.ext ?? {};
      if (canConnDanmaku(
              item, DanmakuType.douyuGroupReg, DanmakuType.douyuProxyUrlReg) ||
          ext['douyu'] == true) {
        _dy = DouyuDnamakuService(roomId: rid, onDanmaku: renderDanmaku);
        _dy!.connect();
      } else if (canConnDanmaku(
              item, DanmakuType.biliGroupReg, DanmakuType.biliProxyUrlReg) ||
          ext['bilibili'] == true) {
        _bl = BilibiliDanmakuService(roomId: rid, onDanmaku: renderDanmaku);
        _bl?.connect();
      } else if (canConnDanmaku(
              item, DanmakuType.huyaGroupReg, DanmakuType.huyaProxyUrlReg) ||
          ext['huya'] == true) {
        _hy = HuyaDanmakuService(roomId: rid, onDanmaku: renderDanmaku);
        _hy?.connect();
      }
    } catch (e) {
      MyLogger.error(e.toString());
    }
  }

//断开所有弹幕连接
  void stop() {
    try {
      _dy?.dispose();

      _bl?.displose();

      _hy?.displose();
    } catch (e) {}
  }
}
