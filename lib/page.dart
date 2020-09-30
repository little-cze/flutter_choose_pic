import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'core/lru_map.dart';
import 'image_item_widget.dart';
import 'pic_page.dart';

class PageDemo extends StatefulWidget {
  @override
  _PageDemoState createState() => _PageDemoState();
}

class _PageDemoState extends State<PageDemo> {
  List<AssetPathEntity> list;
  RequestType type = RequestType.image;
  var hasAll = true;
  var onlyAll = false;
  String minWidth = "0";
  String maxWidth = "10000";
  String minHeight = "0";
  String maxHeight = "10000";
  int index = 0;

  AssetPathEntity get path => list[index];

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

  @override
  void initState() {
    list = [];
    getData();
    super.initState();
  }

  Future<void> getData() async {
    final option = makeOption();
    if (option == null) {
      assert(option != null);
      return;
    }

    var galleryList = await PhotoManager.getAssetPathList(
      type: type,
      hasAll: hasAll,
      onlyAll: onlyAll,
      filterOption: option,
    );

    galleryList.sort((s1, s2) {
      return s2.assetCount.compareTo(s1.assetCount);
    });

    this.list.clear();
    this.list.addAll(galleryList);
    setState(() {});
    print(list);
  }

  FilterOptionGroup makeOption() {
    SizeConstraint sizeConstraint;
    try {
      final minW = int.tryParse(minWidth);
      final maxW = int.tryParse(maxWidth);
      final minH = int.tryParse(minHeight);
      final maxH = int.tryParse(maxHeight);
      sizeConstraint = SizeConstraint(
        minWidth: minW,
        maxWidth: maxW,
        minHeight: minH,
        maxHeight: maxH,

        ///忽略图片尺寸
        ignoreSize: true,
      );
    } catch (e) {
      print("===========>>>>>>>>>>>>>>>Cannot convert your size.");
      return null;
    }

//    DurationConstraint durationConstraint = DurationConstraint(
//      min: minDuration,
//      max: maxDuration,
//    );

    final option = FilterOption(
      sizeConstraint: sizeConstraint,
//      durationConstraint: durationConstraint,
      needTitle: true,
    );

//    final dtCond = DateTimeCond(
//      min: startDt,
//      max: endDt,
//      asc: asc,
//    );

    ////对图片进行筛选
    return FilterOptionGroup()
      ..setOption(AssetType.video, option)
      ..setOption(AssetType.image, option)
      ..setOption(AssetType.audio, option);
//      ..dateTimeCond = dtCond
//      ..containsEmptyAlbum = _containsEmptyAlbum;
  }

  void showPicDialog() {
    final format = ThumbFormat.jpeg;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
              children: List.generate(
                  list.length,
                  (item) => GestureDetector(
                        onTap: () {
                          setState(() {
                            Navigator.pop(context);
                            index = item;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            buildContent(format, index),
                            Text("${list[item].name}"),
                            Text("${list[item].assetCount}")
                          ],
                        ),
                      )),
            )));
  }
  Widget buildContent(ThumbFormat format,index) {
    final AssetEntity entity = picList[index];
    if (entity.type == AssetType.audio) {
      return Center(
        child: Icon(
          Icons.audiotrack,
          size: 30,
        ),
      );
    }
    final item = entity;
    final size = 60;
    final u8List = ImageLruCache.getData(item, size, format);

    Widget image;
    if (u8List != null) {
      return _buildImageWidget(item, u8List, size);
    } else {
      image = FutureBuilder<Uint8List>(
        future: item.thumbDataWithSize(size, size),
        builder: (context, snapshot) {
          Widget w;
          if (snapshot.hasError) {
            w = Center(
              child: Text("load error, error: ${snapshot.error}"),
            );
          }
          if (snapshot.hasData) {
            ImageLruCache.setData(item, size, format, snapshot.data);
            w = _buildImageWidget(item, snapshot.data, size);
          } else {
            w = Center(
              child: CircularProgressIndicator(),
            );
          }

          return w;
        },
      );
    }

    return image;
  }
  Widget _buildImageWidget(AssetEntity entity, Uint8List uint8list, num size) {
    return Image.memory(
      uint8list,
      width: size.toDouble(),
      height: size.toDouble(),
      fit: BoxFit.cover,
    );
  }
  Widget _buildItem(context, index) {
    final entity = picList[index];

    return Stack(
      children: [
        ImageItemWidget(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${list.isEmpty?"pic":list[index].name}",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.send), onPressed: () => showPicDialog())
        ],
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
}
