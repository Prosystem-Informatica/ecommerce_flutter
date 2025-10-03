import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String nome = "Nome pendente";
  String email = "Email pendente";
  String? imagem64;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nome = prefs.getString('userFantasia') ?? "Nome pendente";
      email = prefs.getString('userEmail') ?? "Email pendente";
      imagem64 = prefs.getString('userImagem64');
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg-login.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                color: Colors.transparent,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colorScheme.primary,
                      child: imagem64 != null
                          ? ClipOval(
                        child: Image.memory(
                          base64Decode(imagem64!),
                          fit: BoxFit.cover,
                          width: 56,
                          height: 56,
                        ),
                      )
                          : const Icon(Icons.person, size: 32, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nome,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
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
                      title: const Text("Consultar Produtos"),
                      onTap: () => Get.toNamed("/ConsultProduct"),
                    ),
                    ListTile(
                      leading: Icon(Icons.attach_money, color: colorScheme.primary),
                      title: const Text("Comissão"),
                      onTap: () => Get.toNamed("/Commission"),
                    ),
                    ListTile(
                      leading: Icon(Icons.person_search_rounded, color: colorScheme.primary),
                      title: const Text("Clientes"),
                      onTap: () => Get.toNamed("/customer"),
                    ),
                    ListTile(
                      leading: Icon(Icons.star_rate, color: colorScheme.primary),
                      title: const Text("Avaliar App"),
                      onTap: () {},
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.exit_to_app, color: colorScheme.primary),
                      title: const Text("Sair"),
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('userLogin');
                        await prefs.remove('userFantasia');
                        await prefs.remove('userEmail');
                        await prefs.remove('userImagem64');
                        Get.offAllNamed("/login");
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
