import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileService {
  // Show save or share dialog
  static Future<void> showSaveOrShareDialog(
    BuildContext context,
    File file,
    String fileName,
  ) async {
    final theme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surfaceDim,
        title: Text(
          'Export Complete',
          style: TextStyle(
            color: theme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your file has been created. What would you like to do with it?',
              style: TextStyle(color: theme.onSurface),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Save',
                    Icons.save_alt_rounded,
                    () => saveToDownloads(context, file, fileName),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Share',
                    Icons.share_rounded,
                    () => shareFile(context, file, fileName),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Show preview dialog with option to upgrade to premium
  static Future<void> showPreviewDialog(
    BuildContext context,
    File file,
    String fileName,
    bool isPremium,
  ) async {
    final theme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surfaceDim,
        title: Text(
          'Data Preview',
          style: TextStyle(
            color: theme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isPremium
                  ? 'Preview of your data export is ready.'
                  : 'This is a preview with sample data. Upgrade to premium to export your actual data.',
              style: TextStyle(color: theme.onSurface),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'View',
                    Icons.visibility_rounded,
                    () => _openFile(context, file),
                  ),
                ),
                if (!isPremium) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      'Upgrade',
                      Icons.workspace_premium_rounded,
                      () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/premium');
                      },
                      isPrimary: true,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Open file with default viewer
  static Future<void> _openFile(
    BuildContext context,
    File file,
  ) async {
    try {
      await shareFile(context, file, 'Preview');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening file: $e')),
        );
      }
    }
  }

  // Save file to downloads folder
  static Future<void> saveToDownloads(
    BuildContext context,
    File file,
    String fileName,
  ) async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        // For Android, save to Downloads folder
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        // For iOS, save to Documents folder
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final newFile = File('${directory.path}/$fileName');
        await file.copy(newFile.path);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File saved to ${directory.path}'),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving file: $e')),
        );
      }
    }
  }

  // Share file
  static Future<void> shareFile(
    BuildContext context,
    File file,
    String description,
  ) async {
    try {
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path)],
        text: description,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing file: $e')),
        );
      }
    }
  }

  // Build action button
  static Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool isPrimary = false,
  }) {
    final theme = Theme.of(context).colorScheme;

    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? theme.primary : theme.surfaceVariant,
        foregroundColor: isPrimary ? theme.onPrimary : theme.onSurfaceVariant,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
