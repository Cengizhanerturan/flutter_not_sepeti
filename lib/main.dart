import 'package:flutter/material.dart';

import 'pages/not_listesi.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Not Sepeti',
      home: NotListesi(),
    );
  }
}
