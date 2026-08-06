import 'package:flutter/material.dart';
import 'package:plant_ai/theme/app_theme.dart';

class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: context.borderColor),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.emeraldLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        secondary: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: context.mutedColor,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: AppColors.emeraldLight),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: context.primaryText)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11.5, color: context.secondaryText)),
      ),
    );
  }
}

class SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool destructive;

  const SettingsActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.danger : (iconColor ?? AppColors.emeraldLight);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: context.borderColor),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: destructive ? AppColors.danger.withOpacity(0.12) : context.mutedColor,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: destructive ? color : context.primaryText)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11.5, color: context.secondaryText)),
        trailing: Icon(Icons.chevron_right_rounded, color: context.secondaryText),
      ),
    );
  }
}
