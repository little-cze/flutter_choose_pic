import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageDetail extends StatefulWidget {
  final Uint8List bytes;

  const ImageDetail({Key key, this.bytes}) : super(key: key);
  @override
  _ImageDetailState createState() => _ImageDetailState();
}

class _ImageDetailState extends State<ImageDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
title: Text("Image Detail"),
        backgroundColor: Colors.black,
        actions: <Widget>[
          Icon(Icons.check_circle,color: Colors.green,)
        ],
      ),
      body: PhotoView(
        imageProvider: MemoryImage(widget.bytes),
      ),
    );
  }
}
