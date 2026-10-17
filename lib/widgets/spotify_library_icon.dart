import 'package:flutter/material.dart';

class SpotifyLibraryIcon extends StatelessWidget {
  final Color color;
  final double size;

  const SpotifyLibraryIcon({
    super.key,
    required this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 3.5,
        children: [
          Container(
            width: 3.0,
            height: size * 0.85,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1.0),
            ),
          ),
          Container(
            width: 3.0,
            height: size * 0.85,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1.0),
            ),
          ),
          Transform.rotate(
            angle: -0.30,
            child: Container(
              width: 3.0,
              height: size * 0.85,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
