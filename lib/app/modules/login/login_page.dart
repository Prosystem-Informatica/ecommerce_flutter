import 'package:ecommerce/app/modules/login/cubit/login_bloc_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ui/helpers/messages.dart';
import '../../core/ui/widget/input_widget.dart';
import 'cubit/login_bloc_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with Messages<LoginPage> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkApplication();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<LoginBlocCubit, LoginBlocState>(
      listener: (context, state) {
        state.status.matchAny(
          success: () async {
            showSuccess("Login efetuado com sucesso");

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString("user", loginController.text);
            await prefs.setString("token", "123456");

            Get.offAllNamed("/home");
          },
          error: () {
            showError(state.errorMessage ?? "Erro não informado");
          }, any: () {  },
        );
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text("Login")),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                child: Column(
                  children: [
                    Image.asset("assets/logo-pro.png"),
                    const SizedBox(height: 10),
                    buildInput('Login*', controller: loginController),
                    const SizedBox(height: 10),
                    buildInput(
                      'Senha*',
                      obscureText: true,
                      controller: senhaController,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () async {
                          await context.read<LoginBlocCubit>().login(
                            loginController.text,
                            senhaController.text,
                          );
                        },
                        child: Text(
                          'LOGIN',
                          style: TextStyle(color: colorScheme.onPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Versão • 1.0.0",
                      style: TextStyle(color: colorScheme.surface),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _checkApplication() async {
    await context.read<LoginBlocCubit>().checkUrl();
  }
}
