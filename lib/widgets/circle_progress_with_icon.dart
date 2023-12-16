import 'package:flutter/material.dart';

class CircleProgressWithIcon extends StatelessWidget {
  final double progress;
  final IconData icon;

  const CircleProgressWithIcon({
    required this.progress,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        CircularProgressIndicator(
          color: Colors.grey[400],
          value: 1,
          strokeWidth: 4.0,
        ),
        CircularProgressIndicator(
          color: Colors.deepOrangeAccent,
          value: progress,
          strokeWidth: 4.0,
        ),
        Icon(
          icon,
          size: 25,
        ),
      ],
    );
  }
}
