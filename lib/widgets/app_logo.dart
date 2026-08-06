import 'package:flutter/material.dart';
import 'package:plant_ai/theme/app_theme.dart';

class AppLogoMark extends StatelessWidget {
  final double size;
  final double iconScale;

  const AppLogoMark({super.key, this.size = 48, this.iconScale = 0.58});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.forestDeep, AppColors.emeraldLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withOpacity(0.35),
            blurRadius: size * 0.35,
            offset: Offset(0, size * 0.16),
          ),
        ],
      ),
      child: Icon(
        Icons.eco_rounded,
        color: Colors.white,
        size: size * iconScale,
      ),
    );
  }
}
