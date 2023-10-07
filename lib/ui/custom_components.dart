import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RowWidget extends StatelessWidget {
  final String text;

  const RowWidget(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(text)],
      ),
    );
  }
}

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.fourRotatingDots(
          color: Theme.of(context).colorScheme.background, size: 60),
    );
  }
}
