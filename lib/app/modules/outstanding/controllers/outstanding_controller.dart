import 'package:get/get.dart';

class Article {
  final String id;
  final String category;
  final String title;
  final String description;
  final String imageUrl;
  final String timeAgo;
  final int likes;
  final int comments;

  Article({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.timeAgo,
    required this.likes,
    required this.comments,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      timeAgo: json['time_ago'] ?? '',
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
    );
  }
}

class OutstandingController extends GetxController {
  final RxString selectedCategory = 'Tất cả'.obs;
  final RxList<Article> articles = <Article>[].obs;
  final RxList<String> categories = <String>['Tất cả', 'Cầu lông', 'Tennis', 'Bóng đá', 'Bóng rổ'].obs;

  @override
  void onInit() {
    super.onInit();
    fetchArticles();
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
    fetchArticles();
  }

  void fetchArticles() {
    // This would normally be an API call
    // For now, we'll use mock data
    final mockData = [
      {
        'id': '1',
        'category': 'Cầu lông',
        'title': 'Cầu lông Malaysia do Leong Jun Hao dẫn đầu không lọt vào tứ kết đồng đội hỗn hợp...',
        'description': 'Đội tuyển Malaysia đã phải dừng bước ở vòng bảng sau khi để thua trước các đối thủ mạnh lỡ Trung...',
        'image_url': 'assets/images/badminton1.jpg',
        'time_ago': '1 giờ trước',
        'likes': 24,
        'comments': 8,
      },
      {
        'id': '2',
        'category': 'Cầu lông',
        'title': 'Thắng lợi của tuyển Việt Nam tại giải đấu đồng đội hỗn hợp châu Á 2025',
        'description': 'Đội tuyển Việt Nam gây bất ngờ lớn khi đánh bại Thái Lan để tiến vào vòng tứ kết giải đấu năm nay.',
        'image_url': 'assets/images/badminton2.jpg',
        'time_ago': '3 giờ trước',
        'likes': 42,
        'comments': 15,
      },
      {
        'id': '3',
        'category': 'Cầu lông',
        'title': '5 bài tập nâng cao kỹ thuật đánh cầu lông cho người mới bắt đầu',
        'description': 'Những bài tập cơ bản giúp người mới chơi cầu lông có thể nhanh chóng nắm bắt kỹ thuật và tự tin hơn...',
        'image_url': 'assets/images/badminton3.jpg',
        'time_ago': '6 giờ trước',
        'likes': 0,
        'comments': 0,
      },
    ];

    if (selectedCategory.value == 'Tất cả') {
      articles.value = mockData.map((item) => Article.fromJson(item)).toList();
    } else {
      articles.value = mockData
          .where((item) => item['category'] == selectedCategory.value)
          .map((item) => Article.fromJson(item))
          .toList();
    }
  }
}
