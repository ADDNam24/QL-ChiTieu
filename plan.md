# Plan Nâng cao

## Mục tiêu

Nâng cấp `expense_manager_app` thành bản Nâng cao với UI cao cấp, nhiều ví, ngân sách, mục tiêu tiết kiệm, giao dịch định kỳ, báo cáo, nhắc nhở, bảo mật PIN và theme sáng/tối.

## Các bước

1. Đọc/tạo tài liệu chạy tối ưu.
2. Tạo/cập nhật plan và lịch sử thay đổi.
3. Nâng cấp dependency an toàn: thêm `shared_preferences` cho PIN/theme.
4. Mở rộng SQLite bằng migration an toàn, không xóa giao dịch cũ.
5. Thêm models/providers/repositories cho ví, danh mục, ngân sách, mục tiêu, định kỳ, nhắc nhở, theme, security.
6. Cập nhật transaction để thuộc ví và hỗ trợ filter nâng cao.
7. Nâng cấp dashboard Nâng cao.
8. Thêm màn quản lý ví, danh mục, ngân sách, mục tiêu, định kỳ, báo cáo, nhắc nhở, bảo mật, giao diện.
9. Nâng cấp thống kê bằng nhiều chart và insight.
10. Chạy `flutter pub get`, format, analyze, test/build trong giới hạn thời gian.

## Trạng thái

- Đã thêm migration SQLite version 3 và các bảng Nâng cao.
- Đã thêm provider cho ví, danh mục, ngân sách, mục tiêu, định kỳ, nhắc nhở, bảo mật, theme.
- Đã nâng dashboard, thống kê, profile và thêm các màn quản lý Nâng cao.
- Đã chạy `flutter pub get`, `dart format`, `flutter analyze`, `flutter test`, `flutter build apk --debug`.
- Hoàn thành trong phạm vi nâng cấp an toàn.
- Đã xử lý yêu cầu mới: bỏ chữ VIP/Pro và cải thiện biểu đồ thống kê.
- Đã xử lý lọc tháng: chỉ chọn tháng/năm ở Giao dịch và Thống kê.
- Đã bỏ bộ lọc tuần/tháng/năm dư thừa ở Thống kê, thay bằng chọn theo tháng hoặc theo năm.

