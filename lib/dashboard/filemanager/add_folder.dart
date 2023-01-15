import 'dart:convert';

import 'package:fluffy_board/utils/theme_data_utils.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:uuid/uuid.dart';
import 'file_manager_types.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddFolder extends StatefulWidget {
  final String parent;
  final RefreshController _refreshController;
  final Directories directories;

  AddFolder(this.parent, this._refreshController,
      this.directories);

  @override
  _AddFolderState createState() => _AddFolderState();
}

class _AddFolderState extends State<AddFolder> {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.createFolder),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return (FractionallySizedBox(
                      widthFactor: 0.5,
                      child: AddFolderForm(
                          widget.parent,
                          widget._refreshController,
                          widget.directories)));
                } else {
                  return (AddFolderForm(
                      widget.parent,
                      widget._refreshController,
                      widget.directories));
                }
              },
            ),
          ),
        )));
  }
}

class AddFolderForm extends StatefulWidget {
  final String parent;
  final RefreshController _refreshController;
  final Directories directories;

  AddFolderForm(this.parent, this._refreshController,
      this.directories);

  @override
  _AddFolderFormState createState() => _AddFolderFormState();
}

class _AddFolderFormState extends State<AddFolderForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = new TextEditingController();
  final LocalStorage storage = new LocalStorage('account');
  final LocalStorage settingsStorage = new LocalStorage('settings');
  final LocalStorage fileManagerStorage = new LocalStorage('filemanager');

  _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.errorCreateFolder),
        backgroundColor: Colors.red));
  }

  var uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
            TextFormField(
              onFieldSubmitted: (value) => _addFolder(),
              controller: nameController,
              decoration: InputDecoration(
                errorMaxLines: 5,
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.email_outlined),
                  hintText: AppLocalizations.of(context)!.enterDirectoryName,
                  labelText: AppLocalizations.of(context)!.enterDirectoryName,),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.enterDirectoryName;
                } else if (value.length > 50) {
                  return AppLocalizations.of(context)!.nameSmaller;
                }
                return null;
              },
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                child: ElevatedButton(
                  style: ThemeDataUtils.getFullWithElevatedButtonStyle(),
                    onPressed: () => _addFolder(),
                    child: Text(AppLocalizations.of(context)!.createFolder)))
          ])),
    );
  }

  _addFolder() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.tryingCreateFolder)));
      await storage.ready;
      widget.directories.list.add(new Directory(
          uuid.v4(),
          storage.getItem('id') ?? "",
          widget.parent,
          nameController.text,
          DateTime.now().millisecond));
      fileManagerStorage
          .setItem("directories", widget.directories.toJSONEncodable())
          .then((value) => {
        Navigator.pop(context),
        widget._refreshController.requestRefresh()
      });
    }
  }
}
