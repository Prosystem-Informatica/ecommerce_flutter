import 'package:ecommerce/app/modules/home/home_page.dart';
import 'package:ecommerce/app/modules/home/modules/cart/add_cart_page.dart';
import 'package:ecommerce/app/modules/profile/modules/customer/customer_page.dart';
import 'package:ecommerce/app/modules/profile/modules/orders_finish/orders_finish_page.dart';
import 'package:ecommerce/app/modules/profile/modules/orders_open/orders_open_page.dart';
import 'package:get/get.dart';
import 'modules/login/login_page.dart';

class Routes {
  static const INITIAL = "/login";
  static const HOME = "/home";
  static const ORDERS_OPEN = "/orders_open";
  static const ORDERS_FINISH = "/orders_finish";
  static const CUSTOMER = "/customer";
  static const ADD_CART = "/add_cart";
}

class AppPages {
  static final pages = [
    GetPage(name: Routes.INITIAL, page: () => const LoginPage()),
    GetPage(name: Routes.HOME, page: () => const HomePage()),
    GetPage(name: Routes.ORDERS_OPEN, page: () => const OrdersOpenPage()),
    GetPage(name: Routes.ORDERS_FINISH, page: () => const OrdersFinishPage()),
    GetPage(name: Routes.CUSTOMER, page: () => const CustomerPage()),
    GetPage(name: Routes.ADD_CART, page: () => ProductListPage()),
  ];
}
