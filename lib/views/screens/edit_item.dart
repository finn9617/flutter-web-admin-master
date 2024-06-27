import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mongodb_realm/flutter_mongo_realm.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/constants/dimens.dart';
import 'package:web_admin/dio/dio_client.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/providers/user_data_provider.dart';
import 'package:web_admin/theme/theme_extensions/app_button_theme.dart';
import 'package:web_admin/utils/app_focus_helper.dart';

import '../../dio/api_admin.dart';

class EditItem extends StatefulWidget {
  const EditItem({Key? key, required this.id, required this.data})
      : super(key: key);
  final String id;
  final Map<dynamic, dynamic> data;
  @override
  State<EditItem> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<EditItem> {
  final _passwordTextEditingController = TextEditingController();
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  var _isFormLoading = false;

  @override
  void initState() {
    _formData.h5 = widget.data['h5'];
    _formData.superH5 = widget.data['super'] ? 0 : 1;
    super.initState();
  }

  Future<void> _doRegisterAsync({
    required UserDataProvider userDataProvider,
    required void Function(String message) onSuccess,
    required void Function(String message) onError,
  }) async {
    AppFocusHelper.instance.requestUnfocus();

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      final RealmApp app = RealmApp();
      await app.login(Credentials.anonymous());
      final MongoRealmClient client = MongoRealmClient();
      var collection =
          client.getDatabase("appClone").getCollection("app_clone");
      collection.updateOne(
          filter: {'_id': widget.data['_id']},
          update: UpdateOperator.set({
            "h5": _formData.h5,
            "super": _formData.superH5 == 0 ? true : false,
          })).then((_) {
        onSuccess.call('Edit Item Success.');
      }).catchError((error) => print('Failed: $error'));
    }
  }

  void _onRegisterSuccess(BuildContext context, String message) {
    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      desc: message,
      width: kDialogWidth,
      btnOkText: 'OK',
      btnOkOnPress: () {
        Navigator.of(context).pop();
      },
    );

    dialog.show();
  }

  void _onRegisterError(BuildContext context, String message) {
    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      desc: message,
      width: kDialogWidth,
      btnOkText: 'OK',
      btnOkOnPress: () {},
    );

    dialog.show();
  }

  @override
  void dispose() {
    _passwordTextEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: kDefaultPadding * 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            widget.data['name'],
            style: themeData.textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: kDefaultPadding),
                FormBuilderTextField(
                  name: 'H5',
                  decoration: InputDecoration(
                    labelText: "H5",
                    hintText: "H5",
                    helperText: '',
                    border: const OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  controller: TextEditingController(text: _formData.h5),
                  enableSuggestions: false,
                  validator: FormBuilderValidators.required(),
                  onSaved: (value) => (_formData.h5 = value ?? ''),
                ),
                SizedBox(height: kDefaultPadding),
                Text("Logo change"),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Radio(
                        value: 0,
                        groupValue: _formData.superH5,
                        onChanged: (int? value) {
                          if (value != null) {
                            setState(() {
                              _formData.superH5 = value;
                            });
                          }
                        },
                      ),
                      const Text('True '),
                      Radio(
                        value: 1,
                        groupValue: _formData.superH5,
                        onChanged: (int? value) {
                          if (value != null) {
                            setState(() {
                              _formData.superH5 = value;
                            });
                          }
                        },
                      ),
                      const Text('Fasle '),
                    ],
                  ),
                ),
                SizedBox(height: kDefaultPadding),
                Padding(
                  padding: const EdgeInsets.only(bottom: kDefaultPadding),
                  child: SizedBox(
                    height: 40.0,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: themeData
                          .extension<AppButtonTheme>()!
                          .primaryElevated,
                      onPressed: (_isFormLoading
                          ? null
                          : () => _doRegisterAsync(
                                userDataProvider:
                                    context.read<UserDataProvider>(),
                                onSuccess: (message) =>
                                    _onRegisterSuccess(context, message),
                                onError: (message) =>
                                    _onRegisterError(context, message),
                              )),
                      child: const Text("Edit Item"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FormData {
  String h5 = '';
  int superH5 = 0;
}
