import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/outstanding_controller.dart';

class OutstandingView extends GetView<OutstandingController> {
  const OutstandingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Color(0xFF2B7A78),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF2B7A78).withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset('assets/images/logo.png',
                    width: 20, height: 20, color: Colors.white)),
            SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SPORTIFY',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B7A78),
                  ),
                ),
                Text(
                  'BADMINTON',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF3AAFA9),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Custom tab bar
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.black12, width: 1),
                  ),
                ),
                padding: const EdgeInsets.only(left: 8),
                height: 50,
                child: Obx(() => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.categories.length,
                      itemBuilder: (context, index) {
                        final category = controller.categories[index];
                        final isSelected =
                            category == controller.selectedCategory.value;

                        return GestureDetector(
                          onTap: () => controller.changeCategory(category),
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isSelected
                                      ? const Color(0xFF2E7D61)
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF2E7D61)
                                      : Colors.black87,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )),
              ),

              // Article list
              Expanded(
                child: Obx(() => ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.articles.length,
                      itemBuilder: (context, index) {
                        final article = controller.articles[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Article image without category tag
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE3F2F0),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: Image.asset(
                                    article.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      color: const Color(0xFFE3F2F0),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.image_not_supported,
                                                color: Colors.grey.shade400,
                                                size: 40),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Không thể tải hình ảnh',
                                              style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Article content
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      article.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      article.description,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          article.timeAgo,
                                          style: const TextStyle(
                                            color: Colors.black45,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.favorite_border,
                                                size: 16,
                                                color: Colors.black45),
                                            const SizedBox(width: 4),
                                            Text(
                                              article.likes.toString(),
                                              style: const TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 12),
                                            ),
                                            const SizedBox(width: 12),
                                            const Icon(
                                                Icons.chat_bubble_outline,
                                                size: 16,
                                                color: Colors.black45),
                                            const SizedBox(width: 4),
                                            Text(
                                              article.comments.toString(),
                                              style: const TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )),
              ),
            ],
          ),

          // AI Chat Button
          Positioned(
            right: 16,
            bottom: 16,
            child: GestureDetector(
              onTap: () => Get.toNamed('/chat'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text(
                      'Deep research',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D61),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.smart_toy_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
