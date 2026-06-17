import 'package:flutter/material.dart';
import '../../core/colors.dart';

class ManageItemTile extends StatelessWidget {
  final String       name;
  final Color        color;
  final Widget?      leadingWidget;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ManageItemTile({
    required this.name,
    required this.color,
    this.leadingWidget,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
BoxShadow(
  color: AppColors.black.withOpacity(
    Theme.of(context).brightness == Brightness.dark
        ? 0.25
        : 0.04,
  ),
  blurRadius: 6,
),
          ],
        ),
        child: Row(children: [
          leadingWidget ?? CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            radius: 18,
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:Text(
  name,
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).colorScheme.onSurface,
  ),
),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.goldDark.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_rounded,
                  color: AppColors.goldDark, size: 16),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.darkRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_rounded,
                  color: AppColors.darkRed, size: 16),
            ),
          ),
        ]),
      );
}

class ManageInputDialog extends StatelessWidget {
  final String               title;
  final String               hint;
  final TextEditingController ctrl;
  final String               confirmLabel;
  final VoidCallback         onConfirm;

  const ManageInputDialog({
    required this.title,
    required this.hint,
    required this.ctrl,
    required this.onConfirm,
    this.confirmLabel = 'Add',
  });

@override
Widget build(BuildContext context) => AlertDialog(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBlue
          : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.white
              : AppColors.darkGold,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.white
              : AppColors.black,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.grey
                : AppColors.black,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onSubmitted: (_) {
          onConfirm();
          Navigator.pop(context);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.white70
                  : AppColors.darkGold,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.goldDark,
            foregroundColor: AppColors.white,
          ),
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: Text(confirmLabel),
        ),
      ],
    );
}

class ManageConfirmDialog extends StatelessWidget {
  final String       title;
  final String       message;
  final VoidCallback onConfirm;

  const ManageConfirmDialog({
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  @override
Widget build(BuildContext context) => AlertDialog(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ?AppColors.darkBlue
          : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.white
              : AppColors.darkGold,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.white70
              : AppColors.darkGold,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.white70
                  : AppColors.darkGold,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkRed,
            foregroundColor: AppColors.white,
          ),
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: const Text('Delete'),
        ),
      ],
    );
}