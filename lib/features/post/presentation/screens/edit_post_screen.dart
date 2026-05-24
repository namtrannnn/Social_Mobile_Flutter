import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../data/models/post_model.dart';
import '../controllers/post_controller.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../../user/data/models/simple_user_model.dart';
import '../../../user/presentation/screens/user_picker_screen.dart';

class EditPostScreen extends StatefulWidget {
  final PostModel post;

  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late final TextEditingController _captionController;
  late final TextEditingController _locationController;

  late bool _allowComments;
  late bool _hideLikeCount;
  late bool _hideShare;
  late String _visibility;
  late List<String> _allowedUsers;
  late List<String> _mentions;
  final ImagePicker _picker = ImagePicker();

  late List<PostMediaModel> _currentMedia;
  final List<XFile> _newImages = [];

  final List<SimpleUserModel> _selectedAllowedUsers = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentMedia = List<PostMediaModel>.from(widget.post.media);
    _captionController = TextEditingController(text: widget.post.caption);
    _locationController = TextEditingController(text: widget.post.location);

    _allowComments = widget.post.allowComments;
    _hideLikeCount = widget.post.hideLikeCount;

    // Nếu PostModel bạn chưa thêm hideShare thì tạm để false.
    _hideShare = widget.post.hideShare;

    // Nếu PostModel bạn chưa thêm visibility thì tạm để public.
    _visibility = widget.post.visibility;

    _allowedUsers = List<String>.from(widget.post.allowedUsers);
    _mentions = List<String>.from(widget.post.mentions);
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 85);

    if (images.isEmpty) return;

    final totalCurrent = _currentMedia.length + _newImages.length;
    final remainingSlots = 10 - totalCurrent;

    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Một bài viết chỉ được tối đa 10 ảnh')),
      );
      return;
    }

    final imagesToAdd = images.take(remainingSlots).toList();

    if (images.length > remainingSlots) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chỉ thêm được tối đa 10 ảnh')),
      );
    }

    setState(() {
      _newImages.addAll(imagesToAdd);
    });
  }

  Future<void> _pickAllowedUsers() async {
    final result = await Navigator.push<List<SimpleUserModel>>(
      context,
      MaterialPageRoute(
        builder: (_) => UserPickerScreen(
          title: 'Chọn người được xem',
          initialSelectedUsers: _selectedAllowedUsers,
          multiple: true,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _selectedAllowedUsers
        ..clear()
        ..addAll(result);

      _allowedUsers
        ..clear()
        ..addAll(result.map((user) => user.id));
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _savePost() async {
    final caption = _captionController.text.trim();
    final location = _locationController.text.trim();

    if (caption.isEmpty && _currentMedia.isEmpty && _newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bài viết cần caption hoặc ít nhất 1 ảnh'),
        ),
      );
      return;
    }

    final token = await SecureStorageService.getValidToken();

    if (token == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập để sửa bài viết')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });
    final keepMediaIds = _currentMedia.map((media) => media.id).toList();
    final imagePaths = _newImages.map((image) => image.path).toList();
    final success = await context.read<PostController>().editPost(
      token: token,
      postId: widget.post.id,
      caption: caption,
      location: location,
      allowComments: _allowComments,
      hideLikeCount: _hideLikeCount,
      hideShare: _hideShare,
      visibility: _visibility,
      allowedUsers: _visibility == 'custom' ? _allowedUsers : [],
      mentions: _mentions,
      keepMediaIds: keepMediaIds,
      imagePaths: imagePaths,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cập nhật bài viết')));

      Navigator.pop(context, true);
    } else {
      final error = context.read<PostController>().error;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Cập nhật bài viết thất bại')),
      );
    }
  }

  void _showAdvancedOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Cài đặt nâng cao',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _allowComments,
                    onChanged: (value) {
                      setState(() => _allowComments = value);
                      setModalState(() {});
                    },
                    title: const Text(
                      'Cho phép bình luận',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text('Người xem có thể bình luận bài viết'),
                    secondary: const Icon(Icons.mode_comment_outlined),
                  ),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _hideLikeCount,
                    onChanged: (value) {
                      setState(() => _hideLikeCount = value);
                      setModalState(() {});
                    },
                    title: const Text(
                      'Ẩn số lượt thích',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text('Chỉ bạn thấy số lượt thích'),
                    secondary: const Icon(Icons.favorite_border),
                  ),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _hideShare,
                    onChanged: (value) {
                      setState(() => _hideShare = value);
                      setModalState(() {});
                    },
                    title: const Text(
                      'Ẩn lượt chia sẻ',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Người khác không thấy số lượt chia sẻ',
                    ),
                    secondary: const Icon(Icons.share_outlined),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildMediaPreview() {
    final total = _currentMedia.length + _newImages.length;

    if (total == 0) {
      return GestureDetector(
        onTap: _pickImages,
        child: Container(
          height: 280,
          margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 38,
                    color: Color(0xFF2563EB),
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Thêm ảnh cho bài viết',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 4),
                Text('Tối đa 10 ảnh', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 330,
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: PageView.builder(
        itemCount: total,
        itemBuilder: (context, index) {
          final isOldMedia = index < _currentMedia.length;

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: isOldMedia
                    ? Image.network(
                        _currentMedia[index].url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 42,
                              ),
                            ),
                          );
                        },
                      )
                    : Image.file(
                        File(_newImages[index - _currentMedia.length].path),
                        fit: BoxFit.cover,
                      ),
              ),

              Positioned(
                left: 12,
                right: 12,
                top: 12,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isOldMedia) {
                            _currentMedia.removeAt(index);
                          } else {
                            _newImages.removeAt(index - _currentMedia.length);
                          }
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),

                    const Spacer(),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${index + 1}/$total',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOldMedia ? 'Ảnh hiện tại' : 'Ảnh mới',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              Positioned(
                right: 12,
                bottom: 12,
                child: GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Thêm ảnh',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVisibilitySelector() {
    return Row(
      children: [
        const CircleAvatar(
          backgroundColor: Color(0xFFF3F4F6),
          child: Icon(Icons.visibility_outlined, color: Colors.black87),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quyền riêng tư',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 2),
              Text(
                'Chọn ai có thể xem bài viết',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        DropdownButton<String>(
          value: _visibility,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(value: 'public', child: Text('Công khai')),
            DropdownMenuItem(value: 'followers', child: Text('Người theo dõi')),
            DropdownMenuItem(value: 'friends', child: Text('Bạn bè')),
            DropdownMenuItem(value: 'private', child: Text('Riêng tư')),
            DropdownMenuItem(value: 'custom', child: Text('Tùy chỉnh')),
          ],
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _visibility = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCustomAudienceInfo() {
    if (_visibility != 'custom') {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: _pickAllowedUsers,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFF3F4F6),
              child: Icon(Icons.group_add_outlined, color: Colors.black87),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedAllowedUsers.isNotEmpty
                    ? _selectedAllowedUsers
                          .map((user) => '@${user.username}')
                          .join(', ')
                    : _allowedUsers.isEmpty
                    ? 'Chọn người được xem'
                    : '${_allowedUsers.length} người được xem',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionSwitches() {
    final descriptions = [
      if (!_allowComments) 'Tắt bình luận',
      if (_hideLikeCount) 'Ẩn lượt thích',
      if (_hideShare) 'Ẩn lượt chia sẻ',
    ];

    return _sectionCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFF3F4F6),
          child: Icon(Icons.tune_outlined, color: Colors.black87),
        ),
        title: const Text(
          'Cài đặt nâng cao',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          descriptions.isEmpty
              ? 'Bình luận, lượt thích và chia sẻ'
              : descriptions.join(' • '),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: _showAdvancedOptions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        title: const Text(
          'Sửa bài viết',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _savePost,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Lưu',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildMediaPreview(),

            _sectionCard(
              child: TextField(
                controller: _captionController,
                maxLines: 5,
                minLines: 3,
                maxLength: 2200,
                decoration: const InputDecoration(
                  hintText: 'Viết chú thích...',
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),

            _sectionCard(
              child: TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_on_outlined),
                  hintText: 'Thêm vị trí',
                  border: InputBorder.none,
                ),
              ),
            ),

            _sectionCard(
              child: Column(
                children: [
                  _buildVisibilitySelector(),
                  _buildCustomAudienceInfo(),
                ],
              ),
            ),

            _buildOptionSwitches(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
