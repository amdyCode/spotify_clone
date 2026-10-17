import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotify_clone/utils/app_colors.dart';

class SpotifyLogo extends StatelessWidget {
  final double size;

  const SpotifyLogo({
    super.key,
    this.size = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    return FaIcon(
      FontAwesomeIcons.spotify,
      size: size,
      color: AppColors.spotifyGreen,
    );
  }
}
