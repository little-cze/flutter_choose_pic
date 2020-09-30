import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'image_item_widget.dart';

class GalleryContentListPage extends StatefulWidget {
  final AssetPathEntity path;

  const GalleryContentListPage({Key key, this.path}) : super(key: key);

  @override
  _GalleryContentListPageState createState() => _GalleryContentListPageState();
}

class _GalleryContentListPageState extends State<GalleryContentListPage> {
  AssetPathEntity get path => widget.path;

//  PhotoProvider get photoProvider => Provider.of<PhotoProvider>(context);

//  AssetPathProvider get provider =>
//      Provider.of<PhotoProvider>(context).getOrCreatePathProvider(path);

  List<AssetEntity> checked = [];
  int loadCount = 50;
  bool isInit = false;

  AssetPathEntity picPath;
  List<AssetEntity> picList = [];

  var page = 0;

  int get showItemCount {
    if (picList.length == path.assetCount) {
      return path.assetCount;
    } else {
      return path.assetCount;
    }
  }

  Future onRefresh() async {
    await path.refreshPathProperties();

    final list = await path.getAssetListPaged(0, loadCount);
    print("list=>>$list");
    picList.clear();
    picList.addAll(list);
    isInit = true;
    print("刷新成功====》》》》$picList");
//    printListLength("onRefresh");
    return;
  }

  Future<void> onLoadMore() async {
    if (showItemCount > path.assetCount) {
      print("already max");
      return;
    }
    final list = await path.getAssetListPaged(page + 1, loadCount);
    page = page + 1;
    picList.addAll(list);
    print("加载成功====》》》》$picList");
//    printListLength("loadmore");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${path.name}",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder(
        future: onRefresh(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              print('还没有开始网络请求');
              return Text('还没有开始网络请求');

            case ConnectionState.active:
              print('active');
              return Text('ConnectionState.active');
            case ConnectionState.waiting:
              print('waiting');
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              print('done');
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              return GridView.builder(
                itemBuilder: _buildItem,
                itemCount: path.assetCount,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
              );

            default:
              return null;
          }
        },
      ),
    );
  }


  Widget _buildItem(context, index) {
    final entity = picList[index];


    return  Stack(
      children: [
        ImageItemWidget(
          key: ValueKey(entity),
          entity: entity,
        ),
//        Align(
//          alignment: Alignment.topRight,
//          child: Checkbox(
//            value: checked.contains(entity),
//            onChanged: (value) {
//              if (checked.contains(entity)) {
//                checked.remove(entity);
//              } else {
//                checked.add(entity);
//              }
//              setState(() {});
//            },
//          ),
//        ),
      ],
    );
  }
}
