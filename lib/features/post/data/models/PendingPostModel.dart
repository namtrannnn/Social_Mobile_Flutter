class PendingPostModel {
  final String tempId;
  final String caption;
  final String location;
  final List<String> imagePaths;

  final bool allowComments;
  final bool hideLikeCount;
  final bool hideShare;
  final String visibility;
  final List<String> allowedUsers;
  final List<String> mentions;

  bool isUploading;
  bool isFailed;

  PendingPostModel({
    required this.tempId,
    required this.caption,
    required this.location,
    required this.imagePaths,
    required this.allowComments,
    required this.hideLikeCount,
    required this.hideShare,
    required this.visibility,
    required this.allowedUsers,
    required this.mentions,
    this.isUploading = true,
    this.isFailed = false,
  });
}
