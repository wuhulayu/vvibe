//播放列表面板宽度

const PLAYLIST_BAR_WIDTH = 220.0;

//默认请求头
const DEF_REQ_UA = 'VVibe/0.x Windows';

//默认epg地址
const DEF_EPG_URL = 'https://epg.v1.mk/fy.xml.gz';

//默认弹幕字体大小
const DEF_DM_FONT_SIZE = 20;

const bool IS_RELEASE = bool.fromEnvironment("dart.vm.product");

//assets目录
final ASSETS_DIR = IS_RELEASE ? 'data/flutter_assets/assets' : 'assets';

//自定义窗口标题栏高度
final CUS_WIN_TITLEBAR_HEIGHT = 30.0;

// app name
final APP_NAME = 'VVibe';
