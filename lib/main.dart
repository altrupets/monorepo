import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class HorizontalImageList extends StatelessWidget {
  final int itemCount;

  const HorizontalImageList({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network('https://picsum.photos/300/200'),
          );
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Two Carousels'),
        ),
        body: const Column(
          children: [
            HorizontalImageList(itemCount: 4),
            SizedBox(height: 16),
            HorizontalImageList(itemCount: 6),
          ]
        )
      )
    );
  }
}