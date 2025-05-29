import 'package:flutter/material.dart';

class OptionsBottomSheet extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const OptionsBottomSheet({
    super.key,
    required this.onShare,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              context,
              icon: Icons.share_outlined,
              title: 'Share',
              onTap: () {
                Navigator.pop(context);
                onShare();
              },
            ),
            _buildOptionTile(
              context,
              icon: Icons.file_download_outlined,
              title: 'Download as PDF',
              onTap: () {
                Navigator.pop(context);
                onDownload();
              },
            ),
            _buildOptionTile(
              context,
              icon: Icons.delete_outline,
              title: 'Delete',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.black),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
