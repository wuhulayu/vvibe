import 'dart:io';

import 'package:vvibe/models/playlist_item.dart';
import 'package:collection/collection.dart';

class PlaylistUtil {
  static PlaylistUtil _instance = new PlaylistUtil._();
  factory PlaylistUtil() => _instance;

  PlaylistUtil._();
  //本地播放列表目录
  Future<Directory> getPlayListDir() async {
    final dir = Directory('playlist');
    if (!await (dir.exists())) {
      await dir.create();
    }
    return dir;
  }

  //获取本地播放列表文件列表
  Future<List<String>> getPlayListFiles() async {
    final Directory dir = await getPlayListDir();
    final dirList = await dir.list().toList();
    final List<String> list = [];
    for (var v in dirList) {
      if (v.path.endsWith(".txt") || v.path.endsWith(".m3u"))
        list.add(v.path.replaceAll('\\', '/'));
    }
    return list;
  }

  //解析【本地】文件的播放列表内容
  Future<List<PlayListItem>> parsePlaylistFile(String filePath) async {
    if (filePath.endsWith('.m3u')) {
      final lines = await readFileLines(filePath);
      return parseM3uContents(lines);
    }

    if (filePath.endsWith('.txt')) {
      final lines = await readFileLines(filePath);

      return parseTxtContents(lines);
    }

    return [];
  }

//根据url解析远程txt或m3u内容
  Future<List<PlayListItem>> parsePlaylistUrl(String url) async {
    return [];
  }

//读取文件文本行内容
  Future<List<String>> readFileLines(String filePath) async {
    return File(filePath).readAsLines();
  }

  //根据文本行 解析txt的播放列表文件内容
  List<PlayListItem> parseTxtContents(List<String> lines) {
    try {
      final list = lines
          .where((element) => element.indexOf(',') > -1)
          .map((String e) {
            final List<String> arr = e.split(',');

            return PlayListItem(
                group: '未分组', name: arr[0].trim(), tvgId: '', url: arr[1]);
          })
          .where((PlayListItem element) =>
              element.url != null && element.name != null)
          .toList();
      return list;
    } catch (e) {
      print('读取解析TXT文本行内容出错: $e');
      return [];
    }
  }

  //reg group-title, tvg-id, tvg-logo等属性表达式
  String getM3uPropItem(String line, RegExp reg, {String defVal = ""}) {
    Match? match = reg.firstMatch(line);

    if (match != null) {
      return match.group(1) ?? "";
    }
    return defVal;
  }

  //根据文本行 解析m3u的播放列表文件内容
  List<PlayListItem> parseM3uContents(List<String> lines) {
    try {
      if (!(lines.length > 0 && lines[0].startsWith("#EXTM3U"))) {
        return [];
      }

      List<PlayListItem> list = [];
      for (var i = 0; i < lines.length; i++) {
        if (i > 0 && lines[i].startsWith("#EXTINF:-1")) {
          final info = lines[i],
              url = lines[i + 1],
              name = info.split(',').last.trim();
          list.add(PlayListItem(
              group: getM3uPropItem(info, new RegExp(r'group-title="(.*?)"')),
              tvgName: getM3uPropItem(info, new RegExp(r'tvg-name="(.*?)"')),
              tvgLogo: getM3uPropItem(info, new RegExp(r'tvg-logo="(.*?)"')),
              name: name,
              tvgId: getM3uPropItem(info, new RegExp(r'tvg-id="(.*?)"')),
              url: url));
        }
      }
      final groups = getPlaylistgroups(list);
      return list;
    } catch (e) {
      print('读取M3U文本行内容出错: $e');
      return [];
    }
  }

  //对播放列表分组
  Map<String, List<PlayListItem>> getPlaylistgroups(List<PlayListItem> list) {
    return groupBy(list, (e) => e.group ?? "未分组");
  }
}