# SPORTIFY

## Cấu trúc dự án

```
lib/
├── main.dart                  # Điểm khởi đầu của ứng dụng
├── root.dart                  # Component gốc của ứng dụng
└── app/
    ├── core/                  # Các thành phần cốt lõi
    │   ├── styles/            # Định nghĩa styles và themes
    │   └── utilities/         # Các tiện ích và hàm trợ giúp
    ├── data/
    │   ├── http_client/       # Quản lý HTTP client
    │   ├── models/            # Định nghĩa các models
    │   ├── providers/         # Các providers cho dữ liệu
    │   └── services/          # Các services
    ├── modules/               # Các module chức năng của ứng dụng
    │   ├── change-password/   # Module đổi mật khẩu
    │   ├── dashboard/         # Màn hình dashboard chính
    │   ├── home/              # Tab trang chủ
    │   ├── list/              # Tab danh sách
    │   ├── login/             # Màn hình đăng nhập
    │   ├── messages/          # Chức năng tin nhắn
    │   ├── notifications/     # Chức năng thông báo
    │   ├── outstanding/       # Tab nổi bật
    │   ├── profile/           # Tab tài khoản người dùng
    │   ├── register/          # Màn hình đăng ký
    │   ├── splash/            # Màn hình khởi động
    │   └── welcome/           # Màn hình chào mừng
    ├── routes/                # Định nghĩa các routes
    ├── widgets/               # Các widget dùng chung
    └── packages/              # Các package tùy chỉnh
```

## Kiến trúc ứng dụng

Ứng dụng được thiết kế theo kiến trúc GetX với mô hình MVC:
````
1. **Model**: Quản lý dữ liệu và logic nghiệp vụ
2. **View**: Hiển thị UI và phản hồi hành động của người dùng
3. **Controller**: Điều khiển luồng dữ liệu và xử lý logic

Mỗi module trong ứng dụng đều được tổ chức thành:
- **views/**: Chứa các component UI
- **controllers/**: Chứa các controllers xử lý logic
- **bindings/**: Cung cấp dependency injection

## Tính năng chính

1. **Tab Navigation**: Ứng dụng sử dụng TabBarView để quản lý điều hướng giữa các tab chính:
   - **Trang chủ**: Màn hình chính của ứng dụng
   - **Danh sách**: Hiển thị danh sách các mục
   - **Nổi bật**: Hiển thị các nội dung nổi bật
   - **Tài khoản**: Quản lý thông tin người dùng

2. **Xác thực người dùng**:
   - Đăng nhập
   - Đăng ký
   - Đổi mật khẩu

3. **Thông báo**: Hỗ trợ gửi và nhận thông báo

4. **Tin nhắn**: Chức năng gửi và nhận tin nhắn (đang nghiên cứu phát triển)

## Công nghệ sử dụng

- **Flutter**: Framework chính để phát triển ứng dụng
- **GetX**: State management, dependency injection, và routing
- **Firebase**: Authentication, Analytics, Crashlytics và Cloud Messaging
- **Dio**: HTTP client cho REST API
- **SharedPreferences**: Lưu trữ dữ liệu cục bộ
- **Flutter Local Notifications**: Quản lý thông báo cục bộ

## Cài đặt và chạy dự án

### Yêu cầu

- Flutter SDK: >=2.18.4 <3.0.0
- Dart SDK: Tương thích với Flutter SDK

### Cài đặt

1. Clone repository:
   ```bash
   git clone <repository-url>
   cd sportify
   ```
2. Choose flavor
    dev
    prod

3. Cài đặt dependencies:
   ```bash
   flutter pub get
   ```

4. Chạy ứng dụng:
   ```bash
   flutter run
   ```

## Quản lý trạng thái

Ứng dụng sử dụng GetX để quản lý trạng thái với các lợi ích:

- **State Management**: Reactive programming với Rx types
- **Dependency Injection**: Quản lý dependency với Get.put() và Get.find()
- **Route Management**: Điều hướng dễ dàng với GetX router

