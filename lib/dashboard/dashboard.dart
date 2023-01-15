import 'package:fluffy_board/dashboard/filemanager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();

  static Widget loading(String name, BuildContext context) {
    bool isDarkModeOn = Theme.of(context).brightness == Brightness.dark;
    return (Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          children: [
            isDarkModeOn
                ? Image.asset(
                    "assets/images/FluffyBoardIconDark.png",
                    height: 300,
                  )
                : Image.asset(
                    "assets/images/FluffyBoardIcon.png",
                    height: 300,
                  ),
            CircularProgressIndicator(),
          ],
        ),
      )),
    ));
  }
}

class _DashboardState extends State<Dashboard> {
  final LocalStorage accountStorage = new LocalStorage('account');
  final LocalStorage introStorage = new LocalStorage('intro');
  final LocalStorage settingsStorage = new LocalStorage('settings');
  bool storageReady = false;
  bool introStorageReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => {
          setState(() {
            accountStorage.ready.then((value) => {_setStorageReady()});
            introStorage.ready.then((value) => {_setIntroStorageReady()});
            settingsStorage.ready
                .then((value) => {print("Settingstorage is ready")});
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    String name = AppLocalizations.of(context)!.dashboard;
    print(storageReady);
    print(introStorageReady);

    return (FileManager());
  }

  _setStorageReady() {
    setState(() {
      this.storageReady = true;
    });
  }

  _setIntroStorageReady() {
    setState(() {
      this.introStorageReady = true;
    });
  }

}
