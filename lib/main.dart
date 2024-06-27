import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_mongodb_realm/auth/credentials/credentials.dart';
import 'package:flutter_mongodb_realm/mongo_realm_client.dart';
import 'package:flutter_mongodb_realm/realm_app.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/root_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Environment.init(
    apiBaseUrl: 'https://example.com',
  );
  setPathUrlStrategy();
  await RealmApp.init("application-0-gzruo");

  runApp(const RootApp());
}
