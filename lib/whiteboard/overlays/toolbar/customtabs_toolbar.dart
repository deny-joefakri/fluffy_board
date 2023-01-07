import 'package:fluffy_board/utils/own_icons_icons.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

import '../toolbar.dart' as Toolbar;
import 'draw_options.dart';

class CustomTabsOptions extends DrawOptions {
  int selectedBackground;

  CustomTabsOptions(
      this.selectedBackground,
      List<Color> colors,
      double strokeWidth,
      StrokeCap strokeCap,
      int currentColor,
      dynamic Function(DrawOptions) onBackgroundChange)
      : super(colors, strokeWidth, strokeCap, currentColor, onBackgroundChange);
}

class CustomTabsToolbar extends StatefulWidget {
  final Toolbar.ToolbarOptions toolbarOptions;
  final Toolbar.OnChangedToolbarOptions onChangedToolbarOptions;
  final Axis axis;

  CustomTabsToolbar(
      {required this.toolbarOptions,
      required this.onChangedToolbarOptions,
      required this.axis});

  @override
  _CustomTabsToolbarState createState() => _CustomTabsToolbarState();
}

class _CustomTabsToolbarState extends State<CustomTabsToolbar> {
  // late List<bool> selectedBackgroundTypeList;

  @override
  void initState() {
    // TODO: implement initState
    // selectedBackgroundTypeList = List.generate(
    //     3,
    //     (i) => i == widget.toolbarOptions.backgroundOptions.selectedBackground
    //         ? true
    //         : false);

    Navigator.pushNamed(context, "/webview-sample");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }

  Future<void> _launchURL(BuildContext context) async {
    final theme = Theme.of(context);
    try {
      await launch(
        'https://flutter.dev',
        customTabsOption: CustomTabsOption(
          toolbarColor: theme.primaryColor,
          enableDefaultShare: true,
          enableUrlBarHiding: true,
          showPageTitle: true,
          animation: CustomTabsSystemAnimation.slideIn(),
          extraCustomTabs: const <String>[
            // ref. https://play.google.com/store/apps/details?id=org.mozilla.firefox
            'org.mozilla.firefox',
            // ref. https://play.google.com/store/apps/details?id=com.microsoft.emmx
            'com.microsoft.emmx',
          ],
        ),
        safariVCOption: SafariViewControllerOption(
          preferredBarTintColor: theme.primaryColor,
          preferredControlTintColor: Colors.white,
          barCollapsingEnabled: true,
          entersReaderIfAvailable: false,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );
    } catch (e) {
      // An exception is thrown if browser app is not installed on Android device.
      debugPrint(e.toString());
    }
  }
}
