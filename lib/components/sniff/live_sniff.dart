import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vvibe/common/values/enum.dart';
import 'package:vvibe/utils/playlist/playlist_util.dart';

import 'package:vvibe/utils/playlist/sniff_util.dart';

class LiveSniff extends StatefulWidget {
  const LiveSniff({Key? key}) : super(key: key);

  @override
  _LiveSniffState createState() => _LiveSniffState();
}

class _LiveSniffState extends State<LiveSniff> {
  final TextEditingController _urlTextCtl = TextEditingController();
  final TextEditingController _batchNumCtl = TextEditingController();
  final TextEditingController _toNumCtl = TextEditingController();
  bool validOnly = true; //只看有效
  bool withMeta = false; //是否获取视频媒体信息
  int total = 0; //总数
  int checked = 0; //已检测
  int success = 0; //有效
  int timeout = 0; //超时
  int failed = 0; //无效数量
  bool sniffing = false; //扫描中
  bool canceled = false; //已取消
  List<dynamic> data = []; //表格数据
  @override
  void initState() {
    super.initState();
    _batchNumCtl.text = '5';
    _toNumCtl.text = '1000';
    _urlTextCtl.text = 'http://113.64.147.[1-10]:808/hls/[1-11]/index.m3u8';
  }

//开始扫描
  void _start() async {
    String urlText = _urlTextCtl.text;
    if (urlText.isEmpty) return;
    final list = SniffUtil().genUrlsByTpl(urlText);
    if (list.length < 1) return;
    setState(() {
      canceled = false;
      sniffing = true;
      total = list.length;
      success = 0;
      timeout = 0;
      failed = 0;
      checked = 0;
      data = [];
    });
    /* _checkUrl('http://111.59.189.40:8445/tsfile/live/1000_1.m3u8',
        withMeta: withMeta); */
    await _batchSniff(list);
    setState(() {
      sniffing = false;
    });
    EasyLoading.showToast('扫描完成');
  }

//批量扫描
  Future<void> _batchSniff(List<String> urls) async {
    final int size = int.tryParse(_batchNumCtl.text) ?? 1;

    final int batches = (urls.length / size).ceil();

    for (var i = 0; i < batches; i++) {
      final subUrls = urls.sublist(i * size,
          i * size + size > urls.length ? urls.length : i * size + size);

      final reqs = subUrls.map((url) => _checkUrl(url,
          withMeta: withMeta, timeout: int.tryParse(_toNumCtl.text) ?? 1000));
      if (canceled) {
        _stop();
        break;
      }
      final values = await Future.wait<dynamic>(reqs);

      final _data = data;
      _data.addAll(values);
      print('列表数量 ${_data.length}');
      setState(() {
        checked = i * size;
        success = success +
            values.where((element) => element['statusCode'] == 200).length;
        timeout = timeout +
            values.where((element) => element['statusCode'] == 504).length;
        // data = _data;
      });
    }
  }

  //检测url
  Future<dynamic> _checkUrl(String url,
      {bool withMeta = false, int timeout = 1000}) async {
    final map = await SniffUtil()
        .checkSniffUrl(url, withMeta: withMeta, timeout: timeout);
    return map;
  }

//取消扫描
  _stop() {
    setState(() {
      canceled = true;
      sniffing = false;
    });
  }

//清空
  _clear() {
    setState(() {
      canceled = false;
      data = [];
      total = 0;
      success = 0;
      failed = 0;
      timeout = 0;
      checked = 0;
    });
  }

  TableRow _genTableRow(List<Widget> children) {
    return TableRow(
      decoration: BoxDecoration(
        border: const Border(bottom: BorderSide(color: Colors.grey)),
        color: Colors.white,
      ),
      children: children,
    );
  }

//渲染状态标签
  Widget _renderStatus(UrlSniffResStatus status) {
    Color color = Colors.black;
    String text = '';
    switch (status) {
      case UrlSniffResStatus.success:
        color = Colors.green;
        text = '有效';
        break;
      case UrlSniffResStatus.timeout:
        color = Colors.orange;
        text = '超时';
        break;
      default:
        break;
    }
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 14, color: color),
    );
  }

  Widget _genCell(dynamic text,
      {isHeader = false, isLink = false, isStatus = false}) {
    final textStyle = TextStyle(fontSize: isHeader ? 16 : 14);
    return Padding(
        padding: const EdgeInsets.all(10),
        child: isStatus
            ? _renderStatus(text as UrlSniffResStatus)
            : (isLink
                ? SelectableText(
                    text.toString(),
                    textAlign: TextAlign.center,
                    style: textStyle,
                  )
                : Text(
                    text.toString(),
                    textAlign: TextAlign.center,
                    style: textStyle,
                  )));
  }

  TableRow _genTableHeader() {
    return _genTableRow([
      _genCell('频道', isHeader: true),
      _genCell('状态', isHeader: true),
      _genCell('分辨率', isHeader: true),
      _genCell('地区/运营商', isHeader: true),
      _genCell('链接', isHeader: true)
    ]);
  }

  List<TableRow> _tableRowList(List<dynamic> list) {
    final rows = [_genTableHeader()];
    for (var ele in list) {
      rows.add(_genTableRow([
        _genCell(
          list.indexOf(ele) + 1,
        ),
        _genCell(ele['status'], isStatus: true),
        _genCell(
          '分辨率',
        ),
        _genCell(
          ele['ipInfo'],
        ),
        _genCell(ele['url'], isLink: true)
      ]));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(children: <Widget>[
        Row(
          children: [
            SizedBox(
              width: 500,
              child: TextField(
                controller: _urlTextCtl,
                decoration: InputDecoration(
                    hintText:
                        '模板，如 http://113.64.[1-255].[1-255]:808/hls/[1-200]/index.m3u8'),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 5),
              margin: const EdgeInsets.only(left: 90),
              width: 120,
              child: Text('${checked}/${total}'),
            ),
            Container(
              padding: const EdgeInsets.only(top: 5),
              margin: const EdgeInsets.only(left: 20),
              width: 120,
              child:
                  Text('有效：${success}', style: TextStyle(color: Colors.green)),
            ),
            Container(
              padding: const EdgeInsets.only(top: 5),
              margin: const EdgeInsets.only(left: 20),
              width: 120,
              child: Text('无效：${failed}', style: TextStyle(color: Colors.red)),
            ),
            Container(
              padding: const EdgeInsets.only(top: 5),
              margin: const EdgeInsets.only(left: 20),
              width: 120,
              child: Text('超时：${timeout}'),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Checkbox(
                value: validOnly,
                onChanged: (v) {
                  setState(() {
                    validOnly = v ?? false;
                  });
                }),
            Text('只看有效'),
            Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.only(top: 5),
              width: 100,
              child: Tooltip(
                  child: Row(
                    children: [
                      Checkbox(
                          value: withMeta,
                          onChanged: (v) {
                            setState(() {
                              withMeta = v ?? false;
                            });
                          }),
                      Text('媒体信息'),
                    ],
                  ),
                  message: '是否加载媒体信息，速度较慢'),
            ),
            Container(
              width: 100,
              margin: const EdgeInsets.only(left: 20),
              child: TextField(
                decoration: InputDecoration(label: Text('同时连接数')),
                controller: _batchNumCtl,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(2),
                  FilteringTextInputFormatter.digitsOnly
                ],
                keyboardType: TextInputType.number,
              ),
            ),
            Container(
              width: 100,
              margin: const EdgeInsets.only(left: 20, right: 50),
              child: TextField(
                decoration: InputDecoration(label: Text('超时(ms)')),
                controller: _toNumCtl,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.digitsOnly
                ],
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(
              width: 100,
            ),
            FilledButton(
              child: Text(sniffing ? '扫描中' : '扫描'),
              onPressed: !sniffing
                  ? () {
                      _start();
                    }
                  : null,
            ),
            SizedBox(
              width: 20,
            ),
            ElevatedButton(
              child: Text('导出'),
              onPressed: null,
            ),
            SizedBox(
              width: 20,
            ),
            OutlinedButton(
              child: Text('清空', style: TextStyle(color: Colors.grey)),
              onPressed: !sniffing
                  ? () {
                      _clear();
                    }
                  : null,
            ),
            SizedBox(
              width: 20,
            ),
            TextButton(
              child: Text('取消', style: TextStyle(color: Colors.grey)),
              onPressed: sniffing && !canceled
                  ? () {
                      _stop();
                    }
                  : null,
            ),
            SizedBox(
              width: 20,
            ),
            Tooltip(
              child: Icon(
                Icons.question_mark_outlined,
                color: Colors.orangeAccent,
              ),
              message: '支持3组数字变量，变量用[]表示。目前仅支持http协议',
            )
          ],
        ),
        Expanded(
          child: Container(
              margin: const EdgeInsets.only(
                top: 20,
              ),
              child: SingleChildScrollView(
                  child: Table(
                children: _tableRowList(data),
                columnWidths: {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(3),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              ))),
        )
      ]),
    );
  }
}