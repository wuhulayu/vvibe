import 'package:vvibe/pages/Index/Index_view.dart';
import 'package:vvibe/pages/home/home.binding.dart';
import 'package:vvibe/pages/home/home_view.dart';
import 'package:vvibe/pages/login/login_binding.dart';
import 'package:vvibe/pages/login/login_view.dart';
import 'package:vvibe/pages/notfound/notfound_view.dart';
import 'package:vvibe/pages/proxy/proxy_view.dart';
import 'package:get/get.dart';
import 'package:vvibe/window/window_widgets.dart';
part 'app_routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.Index;

  static final routes = [
    GetPage(
      name: AppRoutes.Index,
      page: () => WindowScaffold(IndexPage()),
    ),
    GetPage(
      name: AppRoutes.Login,
      page: () => WindowScaffold(LoginPage()),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.Home,
      page: () => WindowScaffold(HomePage()),
      binding: HomeBinding(),
    ),
  ];

  static final unknownRoute = GetPage(
    name: AppRoutes.NotFound,
    page: () => WindowScaffold(NotfoundPage()),
  );

  static final proxyRoute = GetPage(
    name: AppRoutes.Proxy,
    page: () => WindowScaffold(ProxyPage()),
  );
}
