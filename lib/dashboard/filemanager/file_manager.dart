import 'package:fluffy_board/dashboard/filemanager/web_dav_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:localstorage/localstorage.dart';
import '../action_buttons.dart';
import 'package:uuid/uuid.dart';
import '../avatar_icon.dart';
import 'file_action_manager.dart';
import 'file_manager_types.dart';
import 'whiteboard_data_manager.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FileManager extends StatefulWidget {


  @override
  _FileManagerState createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  Directories directories = new Directories([]);
  Whiteboards whiteboards = new Whiteboards([]);
  ExtWhiteboards extWhiteboards = new ExtWhiteboards([]);
  OfflineWhiteboards offlineWhiteboards = new OfflineWhiteboards([]);
  Set<String> offlineWhiteboardIds = Set.of([]);
  String currentDirectory = "";
  List<Directory> currentDirectoryPath = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  static const double fontSize = 25;
  static const double fileIconSize = 100;
  final LocalStorage fileManagerStorageIndex =
      new LocalStorage('filemanager-index');
  final LocalStorage fileManagerStorage = new LocalStorage('filemanager');
  var uuid = Uuid();
  final LocalStorage settingsStorage = new LocalStorage('settings');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> directoryAndWhiteboardButtons = [];
    List<BreadCrumbItem> breadCrumbItems = [];
    FileActionManager.mapDirectories(
        context,
        true,
        directoryAndWhiteboardButtons,
        directories,
        fileIconSize,
        "",
        currentDirectory,
        _refreshController, (directory) {
      currentDirectory = directory!.id;
      currentDirectoryPath.add(directory);
    });
    FileActionManager.mapBreadCrumbs(
        context, breadCrumbItems, fontSize, "", (directory) {
      if (directory == null) {
        currentDirectory = "";
        currentDirectoryPath.clear();
      } else {
        currentDirectory = directory.id;
      }
    }, _refreshController, currentDirectoryPath);
    FileActionManager.mapWhiteboards(
        context,
        directoryAndWhiteboardButtons,
        whiteboards,
        fileIconSize,
        "",
        "",
        currentDirectory,
        offlineWhiteboards,
        offlineWhiteboardIds,
        _refreshController);
    FileActionManager.mapExtWhiteboards(
        context,
        directoryAndWhiteboardButtons,
        extWhiteboards,
        fileIconSize,
        offlineWhiteboards,
        offlineWhiteboardIds,
        currentDirectory,
        "",
        "",
        true,
        _refreshController);
    FileActionManager.mapOfflineWhiteboards(
        context,
        directoryAndWhiteboardButtons,
        offlineWhiteboards,
        fileIconSize,
        "",
        "",
        true,
        _refreshController,
        offlineWhiteboardIds);

    Widget body = Container(
        child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            BreadCrumb(
              items: breadCrumbItems,
              divider: Icon(Icons.chevron_right),
              overflow: WrapOverflow(
                keepLastDivider: false,
                direction: Axis.horizontal,
              ),
            ),
          ],
        ),
      ),
      Divider(),
      Expanded(
          child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              controller: _refreshController,
              onRefresh: () async {
                await WhiteboardDataManager.getDirectoriesAndWhiteboards(
                    false,
                    currentDirectory,
                    "",
                    _refreshController,
                    directories,
                    whiteboards,
                    extWhiteboards,
                    offlineWhiteboardIds,
                    offlineWhiteboards, (directories,
                        whiteboards,
                        extWhiteboards,
                        offlineWhiteboardIds,
                        offlineWhiteboards) {
                  setState(() {
                    this.directories = directories;
                    this.whiteboards = whiteboards;
                    this.extWhiteboards = extWhiteboards;
                    this.offlineWhiteboardIds = offlineWhiteboardIds;
                    this.offlineWhiteboards = offlineWhiteboards;
                  });
                });

              },
              child: GridView.extent(
                maxCrossAxisExtent: 200,
                children: directoryAndWhiteboardButtons,
              )))
    ]));

    Widget actionButtons = Expanded(
      child: ActionButtons(
          currentDirectory,
          _refreshController,
          offlineWhiteboards,
          offlineWhiteboardIds,
          directories),
    );

    Widget scaffold = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > 1100) {
          return Scaffold(
              appBar: AppBar(
                  title: Row(
                    children: [Text(AppLocalizations.of(context)!.dashboard), actionButtons],
                  ),
                  actions: [EasyDynamicThemeBtn(), AvatarIcon()]),
              body: body);
        } else {
          return Scaffold(
              appBar: AppBar(
                  title: Row(
                    children: [
                      Text(AppLocalizations.of(context)!.dashboard),
                    ],
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(kToolbarHeight),
                    // you can put any value here
                    child: actionButtons,
                  ),
                  actions: [EasyDynamicThemeBtn(), AvatarIcon()]),
              body: body);
        }
      },
    );

    return scaffold;
  }
}
