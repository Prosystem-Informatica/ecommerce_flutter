import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            color: Colors.white,
            child: Row(
              children: [
                 CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.primary,
                  child: Icon(Icons.person, size: 32, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Prosystem",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "cid@prosysteminformatica.com.br",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.content_paste_search, color: colorScheme.primary),
                  title: Text("Consultar Produtos"),
                  onTap: () {
                    Get.toNamed("/ConsultProduct");
                  },
                ),
                ListTile(
                  leading: Icon(Icons.attach_money, color: colorScheme.primary),
                  title: Text("Comissão"),
                  onTap: () {
                    Get.toNamed("/commission");
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person_search_rounded, color: colorScheme.primary),
                  title: Text("Clientes"),
                  onTap: () {
                    Get.toNamed("/customer");
                  },
                ),
                ListTile(
                  leading: Icon(Icons.star_rate, color: colorScheme.primary),
                  title: Text("Avaliar App"),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: colorScheme.primary),
                  title: Text("Sair"),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('userLogin');

                    Get.offAllNamed("/login");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
