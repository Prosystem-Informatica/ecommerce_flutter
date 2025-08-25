import 'package:ecommerce/app/modules/home/modules/cart/cubit/order_bloc_cubit.dart';
import 'package:ecommerce/app/repositories/login/login_repository.dart';
import 'package:ecommerce/app/repositories/order/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_widget.dart';
import 'core/helpers/environments.dart';
import 'core/rest/http/http_rest_client.dart';
import 'core/rest/rest_client.dart';
import 'modules/login/cubit/login_bloc_cubit.dart';

class BlocInjection extends StatelessWidget {
  final RestClient _apiRestClient =
  HttpRestClient(baseUrl: Environments.get('BASE_URL') ?? "");
  late SharedPreferences prefs;

  BlocInjection({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider<LoginBlocCubit>(
        create: (_) => LoginBlocCubit(
            loginRepository: LoginRepository(rest: _apiRestClient)),
      ),
      BlocProvider<OrderBlocCubit>(
        create: (_) => OrderBlocCubit(
            orderRepository: OrderRepository(rest: _apiRestClient)),
      ),

    ], child: const AppWidget());
  }
}
