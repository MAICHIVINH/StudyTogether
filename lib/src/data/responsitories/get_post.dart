// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:get/get.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class getPost {
  var userName = "".obs;
  var uid = "".obs;
  var id = "".obs;
  DateTime? createAt;
  var content = "".obs;
  var avatarUrl = "".obs;
  var media = <Map<String, dynamic>>[].obs;
  var shareContent = "".obs;
  var shareUid = "".obs;
  var avatarShare = "".obs;
  var postIdShare = "".obs;
  var userNameShare = "".obs;
  getPost? originalPost;

  getPost({
    required String userName,
    required String uid,
    required String id,
    required String createAt,
    required String content,
    required String avatarUrl,
    required List<Map<String, dynamic>> media,
    required String shareContent,
    required String postIdShare,
    required String avatarShare,
    required String shareUid,
    required String userNameShare,
  }) {
    this.userName.value = userName;
    this.uid.value = uid;
    this.id.value = id;
    this.content.value = content;
    this.avatarUrl.value = avatarUrl;
    this.media.value = media;
    this.shareContent.value = shareContent;
    this.avatarShare.value = avatarShare;
    this.postIdShare.value = postIdShare;
    this.shareUid.value = shareUid;
    this.userNameShare.value = userNameShare;
    try {
      this.createAt = DateTime.parse(createAt);
    } catch (e) {
      print("Lỗi parse createAt: $e");
      this.createAt = DateTime.now();
    }
  }

  void setPost({
    required String userName,
    required String uid,
    required String id,
    required String createAt,
    required String avatarUrl,
    String? content,
    List<Map<String, dynamic>>? media,
  }) {
    this.userName.value = userName;
    this.uid.value = uid;
    this.avatarUrl.value = avatarUrl;
    this.content.value = content ?? "";
    this.media.value = media ?? [];
    this.id.value = id;
    try {
      this.createAt = DateTime.parse(createAt);
    } catch (e) {
      print("Lỗi parse createAt: $e");
      this.createAt = DateTime.now();
    }
  }

  void clear() {
    userName.value = "";
    uid.value = "";
    avatarUrl.value = "";
    content.value = "";
    media.value = [];
    id.value = "";
    createAt = null;
  }

  factory getPost.formJson(Map data) {
    getPost? original;
    if (data.containsKey('postIdByShare')) {
      original = getPost(
        uid: data['uidByShare'] ?? '',
        userName: data['userNameByShare'] ?? '',
        avatarUrl: data['avatarByShare'] ?? '',
        content: data['contentByShare'] ?? '',
        createAt: data['createdAt'] ?? '',
        id: data['postIdByShare'] ?? '',
        shareContent: '',
        shareUid: '',
        avatarShare: '',
        postIdShare: '',
        userNameShare: '',
        media: [],
      );
    }

    return getPost(
      uid: data["uid"] ?? '',
      userName: data['username'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      content: data['content'] ?? '',
      createAt: data['createdAt'] ?? '',
      id: data['id'] ?? '',
      shareUid: data['uidByShare'] ?? '',
      avatarShare: data['avatarByShare'] ?? '',
      postIdShare: data['postIdByShare'] ?? '',
      userNameShare: data['userNameByShare'] ?? '',
      media:
          data['media'] is List
              ? (data['media'] as List)
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList()
              : [],
      shareContent: data['contentByShare'] ?? '',
    )..originalPost = original;
  }
}
