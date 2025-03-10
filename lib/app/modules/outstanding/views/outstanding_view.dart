import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/outstanding_controller.dart';

class OutstandingView extends GetView<OutstandingController> {
  const OutstandingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SPORTIFY'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Tab bar
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['Tất cả', 'Cầu lông', 'Tennis', 'Bóng đá', 'Bóng rổ']
                    .map((category) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Chip(
                            label: Text(category),
                            backgroundColor: category == 'Tất cả'
                                ? Colors.blueAccent
                                : Colors.grey[300],
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            // Danh sách bài viết
            Expanded(
              child: ListView.builder(
                itemCount: 3, // Giả sử có 3 bài viết
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Cầu lông',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Thắng lợi của tuyển Việt Nam tại giải đấu đồng đội hỗn hợp châu Á 2025',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('3 giờ trước',
                                  style: TextStyle(color: Colors.grey)),
                              Row(
                                children: [
                                  Icon(Icons.favorite_border, size: 16),
                                  SizedBox(width: 4),
                                  Text('24'),
                                  SizedBox(width: 8),
                                  Icon(Icons.comment, size: 16),
                                  SizedBox(width: 4),
                                  Text('8'),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
