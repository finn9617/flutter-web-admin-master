import 'package:flutter/material.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:web_admin/views/widgets/portal_master_layout/sidebar.dart';

final sidebarMenuConfigs = [
  SidebarMenuConfig(
    uri: RouteUri.dashboard,
    icon: Icons.dashboard_rounded,
    title: (context) => Lang.of(context).dashboard,
  ),
];

const localeMenuConfigs = [
  LocaleMenuConfig(
    languageCode: 'en',
    name: 'English',
  ),
  // LocaleMenuConfig(
  //   languageCode: 'zh',
  //   scriptCode: 'Hans',
  //   name: '中文 (简体)',
  // ),
  // LocaleMenuConfig(
  //   languageCode: 'zh',
  //   scriptCode: 'Hant',
  //   name: '中文 (繁體)',
  // ),
];
