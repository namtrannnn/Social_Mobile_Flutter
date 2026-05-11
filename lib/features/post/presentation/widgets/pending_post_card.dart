import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/models/PendingPostModel.dart';

class PendingPostCard extends StatelessWidget {
  final PendingPostModel pendingPost;
  final VoidCallback onDelete;
  final VoidCallback onRetry;
  const PendingPostCard({
    super.key,
    required this.pendingPost,
    required this.onDelete,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.12),
                  child: pendingPost.isFailed
                      ? const Icon(Icons.error, color: Colors.red)
                      : const Icon(
                          Icons.cloud_upload_outlined,
                          color: Color(0xFF2563EB),
                        ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pendingPost.isFailed
                            ? 'Đăng bài thất bại'
                            : 'Đang đăng bài...',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        pendingPost.isFailed
                            ? 'Vui lòng thử lại'
                            : 'Bài viết sẽ xuất hiện sau khi tải lên',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (pendingPost.isUploading)
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: LinearProgressIndicator(
                minHeight: 4,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          if (pendingPost.isFailed)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDelete,
                      child: const Text('Xóa'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRetry,
                      child: const Text('Thử lại'),
                    ),
                  ),
                ],
              ),
            ),
          // IMAGE
          if (pendingPost.imagePaths.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(pendingPost.imagePaths.first),
                width: double.infinity,
                height: 320,
                fit: BoxFit.cover,
              ),
            ),

          // CAPTION
          if (pendingPost.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Text(
                pendingPost.caption,
                style: const TextStyle(fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}
