import 'package:ecommerce/app/modules/profile/modules/orders_finish/orders_finish_page.dart';
import 'package:ecommerce/app/modules/profile/modules/orders_open/orders_open_page.dart';
import 'package:ecommerce/app/modules/profile/modules/orders_wait/orders_wait_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? userLogin;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _children = [
    const Dashboard(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserLogin();
  }

  String formatCamelCase(String text){
    if (text.isEmpty) return text;

    final words = text.split(' ');
    return words.map((word){
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  Future<void> _loadUserLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString('userLogin');

    setState(() {
      userLogin = login;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;


    return Scaffold(
      appBar: AppBar(
    /*leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
    ),*/
        title: Text(
          userLogin != null ? 'Bem-vindo , ${formatCamelCase(userLogin!)}' : 'Bem-vindo',
        ), actions: [
      ],
        backgroundColor: colorScheme.primary,
      ),
      backgroundColor: colorScheme.onPrimary,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed("/add_cart");
        },
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        fixedColor: colorScheme.primary,
        backgroundColor: colorScheme.onPrimary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      body: _children[_currentIndex],
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final tabs = ["Pedidos a enviar", "Pedidos em Aberto", "Pedidos Concluídos"];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Container(
                  padding: const EdgeInsets.all(1),
                  child: TabBar(
                    isScrollable: true,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                    indicator: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: colorScheme.onPrimary,
                    unselectedLabelColor: colorScheme.shadow,
                    dividerColor: Colors.transparent,
                    tabs: tabs.map((title) => Tab(text: title)).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Expanded(
                child: TabBarView(
                  children: [
                    OrdersWaitPage(),
                    OrdersOpenPage(),
                    OrdersFinishPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
