import 'package:flutter/material.dart';

import 'app/bloc_injector.dart';
import 'app/core/config/application_config.dart';

void main() async {
  await ApplicationConfig().configure();
  runApp(BlocInjection());
}