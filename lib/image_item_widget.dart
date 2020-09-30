import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'core/lru_map.dart';
import 'watch_pic.dart';

class ImageItemWidget extends StatefulWidget {
  final AssetEntity entity;

  const ImageItemWidget({
    Key key,
    this.entity,
  }) : super(key: key);

  @override
  _ImageItemWidgetState createState() => _ImageItemWidgetState();
}

class _ImageItemWidgetState extends State<ImageItemWidget> {
  @override
  Widget build(BuildContext context) {
    final format = ThumbFormat.jpeg;
    return buildContent(format);
  }

  Widget buildContent(ThumbFormat format) {
    if (widget.entity.type == AssetType.audio) {
      return Center(
        child: Icon(
          Icons.audiotrack,
          size: 30,
        ),
      );
    }
    final item = widget.entity;
    final size = 130;
    final u8List = ImageLruCache.getData(item, size, format);

    Widget image;

    if (u8List != null) {
      print("nullllll");
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
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ImageDetail(bytes: uint8list))),
      child: Image.memory(
        uint8list,
        width: size.toDouble(),
        height: size.toDouble(),
        fit: BoxFit.cover,
      ),
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
