import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mongodb_realm/flutter_mongo_realm.dart';
import 'package:web_admin/constants/dimens.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/theme/theme_extensions/app_color_scheme.dart';
import 'package:web_admin/theme/theme_extensions/app_data_table_theme.dart';
import 'package:web_admin/views/screens/edit_item.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

import '../../dio/api_admin.dart';
import '../../dio/dio_client.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dataTableHorizontalScrollController = ScrollController();

  @override
  void dispose() {
    _dataTableHorizontalScrollController.dispose();

    super.dispose();
  }

  Future initDataFirebase() async {
    final RealmApp app = RealmApp();
    await app.login(Credentials.anonymous());
    final MongoRealmClient client = MongoRealmClient();
    var collection = client.getDatabase("appClone").getCollection("app_clone");
    var docs = await collection.find();
    return docs.map((e) => e.map).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);
    final appColorScheme = Theme.of(context).extension<AppColorScheme>()!;
    final appDataTableTheme = Theme.of(context).extension<AppDataTableTheme>()!;
    final size = MediaQuery.of(context).size;

    return PortalMasterLayout(
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CardHeader(
                    title: "App Citi",
                    showDivider: false,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double dataTableWidth =
                            max(kScreenWidthMd, constraints.maxWidth);

                        return Scrollbar(
                          controller: _dataTableHorizontalScrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _dataTableHorizontalScrollController,
                            child: SizedBox(
                              width: dataTableWidth,
                              child: Theme(
                                data: themeData.copyWith(
                                  cardTheme: appDataTableTheme.cardTheme,
                                  dataTableTheme:
                                      appDataTableTheme.dataTableThemeData,
                                ),
                                child: FutureBuilder(
                                    future: initDataFirebase(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      final data = snapshot.data;
                                      return DataTable(
                                        showCheckboxColumn: false,
                                        showBottomBorder: true,
                                        headingRowColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.grey[200]!),
                                        columns: const [
                                          DataColumn(
                                              label: Text('STT'),
                                              numeric: true),
                                          DataColumn(label: Text('Name')),
                                          DataColumn(label: Text('H5')),
                                          DataColumn(
                                              label: Flexible(
                                            child: Text('Download'),
                                          )),
                                          DataColumn(
                                              label: Flexible(
                                            child: Text('Open app'),
                                          )),
                                          DataColumn(
                                              label: Flexible(
                                                child: Text('Logo change'),
                                              ),
                                              numeric: true),
                                          DataColumn(
                                              label: Text('Edit'),
                                              numeric: true),
                                        ],
                                        rows: List.generate(data!.length,
                                            (index) {
                                          return DataRow.byIndex(
                                            index: index,
                                            cells: [
                                              DataCell(Text('#${index + 1}')),
                                              DataCell(
                                                  Text(data[index]['name'])),
                                              DataCell(Text(data[index]['h5'])),
                                              DataCell(Text(data[index]
                                                      ['download_app']
                                                  .toString())),
                                              DataCell(Text(data[index]
                                                      ['open_app']
                                                  .toString())),
                                              DataCell(Text(data[index]['super']
                                                  .toString())),
                                              DataCell(
                                                IconButton(
                                                  onPressed: () {
                                                    final dialog =
                                                        AwesomeDialog(
                                                            context: context,
                                                            dialogType:
                                                                DialogType
                                                                    .noHeader,
                                                            width: kDialogWidth,
                                                            body: EditItem(
                                                              data: data[index],
                                                              id: "",
                                                            ),
                                                            btnOkText:
                                                                Lang.of(context)
                                                                    .loginNow,
                                                            btnOkOnPress: null);
                                                    dialog.show().then((value) {
                                                      setState(() {});
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      );
                                    }),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final double width;

  const SummaryCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 120.0,
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: backgroundColor,
        child: Stack(
          children: [
            Positioned(
              top: kDefaultPadding * 0.5,
              right: kDefaultPadding * 0.5,
              child: Icon(
                icon,
                size: 80.0,
                color: iconColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                    child: Text(
                      value,
                      style: textTheme.headlineMedium!.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    style: textTheme.labelLarge!.copyWith(
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
