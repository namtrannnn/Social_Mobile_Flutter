// features/post/presentation/screens/create_post_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../controllers/post_controller.dart';

import '../../../user/data/models/simple_user_model.dart';
import '../../../user/presentation/screens/user_picker_screen.dart';
import '../../../user/presentation/controllers/user_search_controller.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  final List<SimpleUserModel> _allowedUsers = [];

  bool _allowComments = true;
  bool _hideLikeCount = false;
  String _visibility = 'public';
  bool _hideShare = false;

  bool _isPosting = false;
  final List<SimpleUserModel> _mentionedUsers = [];

  List<SimpleUserModel> _mentionSuggestions = [];
  bool _showMentionSuggestions = false;

  @override
  void initState() {
    super.initState();
    _captionController.addListener(_handleMentionSearch);
  }

  @override
  void dispose() {
    _captionController.removeListener(_handleMentionSearch);
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 85);

    if (images.isEmpty) return;

    final remainingSlots = 10 - _selectedImages.length;

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
      _selectedImages.addAll(imagesToAdd);
    });
  }

  Future<void> _submitPost() async {
    final caption = _captionController.text.trim();
    final location = _locationController.text.trim();

    if (caption.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bài viết cần caption hoặc ít nhất 1 ảnh'),
        ),
      );
      return;
    }

    final token = await SecureStorageService.getValidToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập để đăng bài')),
      );
      return;
    }

    final imagePaths = _selectedImages.map((image) => image.path).toList();

    context.read<PostController>().createPost(
      token: token,
      caption: caption,
      location: location,
      imagePaths: imagePaths,
      allowComments: _allowComments,
      hideLikeCount: _hideLikeCount,
      hideShare: _hideShare,
      visibility: _visibility,
      mentions: _mentionedUsers.map((user) => user.id).toList(),
      allowedUsers: _visibility == 'custom'
          ? _allowedUsers.map((user) => user.id).toList()
          : [],
    );

    if (!mounted) return;

    Navigator.pop(context, true);
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

  void _openImageViewer(int initialIndex) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Image Viewer',
      barrierColor: Colors.black.withOpacity(0.82),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) {
        final controller = PageController(initialPage: initialIndex);

        return SafeArea(
          child: Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.48,
              width: MediaQuery.of(context).size.width,
              child: PageView.builder(
                controller: controller,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {},
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        File(_selectedImages[index].path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImages.isEmpty) {
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
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 38,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Chọn ảnh cho bài viết',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tối đa 10 ảnh',
                  style: TextStyle(color: Colors.grey),
                ),
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
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _openImageViewer(index),
                  child: Image.file(
                    File(_selectedImages[index].path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Positioned(
                left: 12,
                right: 12,
                top: 12,
                child: Row(
                  children: [
                    _imageActionButton(
                      icon: Icons.close,
                      onTap: () {
                        setState(() {
                          _selectedImages.removeAt(index);
                        });
                      },
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
                        '${index + 1}/${_selectedImages.length}',
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

  Widget _imageActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
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
            setState(() => _visibility = value);
          },
        ),
      ],
    );
  }

  Future<void> _pickAllowedUsers() async {
    final result = await Navigator.push<List<SimpleUserModel>>(
      context,
      MaterialPageRoute(
        builder: (_) => UserPickerScreen(
          title: 'Chọn người được xem',
          initialSelectedUsers: _allowedUsers,
          multiple: true,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _allowedUsers
        ..clear()
        ..addAll(result);
    });
  }

  Future<void> _handleMentionSearch() async {
    final text = _captionController.text;

    final mentionRegex = RegExp(r'@(\w*)$');
    final match = mentionRegex.firstMatch(text);

    if (match == null) {
      setState(() {
        _showMentionSuggestions = false;
        _mentionSuggestions = [];
      });
      return;
    }

    final keyword = match.group(1) ?? '';

    if (keyword.isEmpty) {
      setState(() {
        _showMentionSuggestions = false;
        _mentionSuggestions = [];
      });
      return;
    }

    final token = await SecureStorageService.getValidToken();

    if (token == null) return;

    await context.read<UserSearchController>().searchUsers(
      token: token,
      keyword: keyword,
    );

    if (!mounted) return;

    final result = context.read<UserSearchController>().users;

    setState(() {
      _mentionSuggestions = result;
      _showMentionSuggestions = true;
    });
  }

  void _selectMention(SimpleUserModel user) {
    final text = _captionController.text;
    final mentionRegex = RegExp(r'@(\w*)$');

    final newText = text.replaceAll(mentionRegex, '@${user.username} ');

    _captionController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );

    if (!_mentionedUsers.any((item) => item.id == user.id)) {
      _mentionedUsers.add(user);
    }

    setState(() {
      _showMentionSuggestions = false;
      _mentionSuggestions = [];
    });
  }

  Widget _buildMentionSuggestions() {
    if (!_showMentionSuggestions || _mentionSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _mentionSuggestions.length,
        itemBuilder: (context, index) {
          final user = _mentionSuggestions[index];

          return ListTile(
            onTap: () => _selectMention(user),
            leading: CircleAvatar(
              child: user.avatar.isEmpty
                  ? const Icon(Icons.person)
                  : ClipOval(
                      child: Image.network(
                        user.avatar,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const Icon(Icons.person);
                        },
                      ),
                    ),
            ),
            title: Text(user.fullName),
            subtitle: Text('@${user.username}'),
          );
        },
      ),
    );
  }

  Widget _buildCustomAudienceTile() {
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
                _allowedUsers.isEmpty
                    ? 'Chọn người được xem'
                    : _allowedUsers
                          .map((user) => '@${user.username}')
                          .join(', '),
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
          [
                if (!_allowComments) 'Tắt bình luận',
                if (_hideLikeCount) 'Ẩn lượt thích',
                if (_hideShare) 'Ẩn lượt chia sẻ',
              ].isEmpty
              ? 'Bình luận, lượt thích và chia sẻ'
              : [
                  if (!_allowComments) 'Tắt bình luận',
                  if (_hideLikeCount) 'Ẩn lượt thích',
                  if (_hideShare) 'Ẩn lượt chia sẻ',
                ].join(' • '),
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
          'Tạo bài viết',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _submitPost,
            child: _isPosting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Đăng',
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
            _buildImagePreview(),

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

            _buildMentionSuggestions(),

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
                  if (_visibility == 'custom') _buildCustomAudienceTile(),
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
