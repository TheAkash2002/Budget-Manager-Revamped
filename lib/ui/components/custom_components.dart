import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/**
 * Widget for a row of ExpenseCard / TargetCard.
 */
class RowWidget extends StatelessWidget {
  final String text;
  final Icon? icon;
  final bool isHeader;

  const RowWidget(this.text, {Key? key, this.isHeader = false, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) icon!,
          Flexible(
            child: Text(
              text,
              style: isHeader
                  ? const TextStyle(
                      fontSize: 24,
                    )
                  : null,
            ),
          )
        ],
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

class ResizableIconButton extends StatelessWidget {
  final String tooltip;
  final Icon icon;
  final void Function() onPressed;

  ResizableIconButton(
      {required this.tooltip, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return IconButton(
        tooltip: tooltip,
        icon: icon,
        onPressed: onPressed,
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      label: Text(tooltip),
      icon: icon,
    );
  }
}
