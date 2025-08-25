import 'package:ecommerce/app/modules/login/cubit/login_bloc_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../core/ui/helpers/messages.dart';
import '../../core/ui/widget/input_widget.dart';
import 'cubit/login_bloc_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with Messages<LoginPage>{
  final TextEditingController servidorController = TextEditingController();
  final TextEditingController loginController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkApplication();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<LoginBlocCubit, LoginBlocState>(
      listener: (context, state) {
        // TODO: implement listener
        state.status.matchAny(
          success: () async {
            showSuccess("Login efetuado com sucesso");
            Get.toNamed("/home");
          },
          error: () {
            showError(state.errorMessage ?? "Erro não informado");
          },
          any: () {
            Get.toNamed("/home");
          },
        );
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 30,
                      ),
                      child: Column(
                        children: [
                          Image.asset("assets/logo-pro.png"),
                          SizedBox(height: 10),
                          buildInput('Login*', controller: loginController),
                          SizedBox(height: 10),
                          buildInput(
                            'Senha*',
                            obscureText: true,
                            controller: senhaController,
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () async {
                                print(
                                  "Login : ${loginController.text} Password: ${senhaController.text} ",
                                );
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
                          SizedBox(height: 20),
                          Text(
                            "Versão • 1.0.0",
                            style: TextStyle(color: colorScheme.surface),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
