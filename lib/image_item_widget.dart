import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'core/lru_map.dart';
import 'watch_pic.dart';

class ImageItemWidget extends StatefulWidget {
  final AssetEntity entity;
final size;
  const ImageItemWidget({
    Key key,
    this.entity, this.size = 100,
  }) : super(key: key);

  @override
  _ImageItemWidgetState createState() => _ImageItemWidgetState();
}

class _ImageItemWidgetState extends State<ImageItemWidget> {
  @override
  Widget build(BuildContext context) {
    final format = ThumbFormat.jpeg;
    return buildContent(format,widget.size);
  }

  Widget buildContent(ThumbFormat format,size) {
    final item = widget.entity;

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

    return FutureBuilder(
      future: widget.entity.thumbDataWithSize(1000, 1000),
      builder: (context,snap){
        return Container(
          child: GestureDetector(
            onTap: (){

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ImageDetail(bytes:  snap.data??uint8list)));
            },
            child: Image.memory(
              uint8list,
              width: size.toDouble(),
              height: size.toDouble(),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(ImageItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entity.id != oldWidget.entity.id) {
      setState(() {});
    }
  }
}
