# Lịch Sử Thay Đổi

## Nâng cao Upgrade

- Tạo `docs/run_optimization.md` để ghi cách chạy tối ưu.
- Tạo `plan.md` để theo dõi kế hoạch nâng cấp.
- Thêm dependency `shared_preferences` để lưu theme mode và PIN local.
- Nâng `AppDatabase` lên version 3, thêm bảng `wallets`, `categories`, `budgets`, `saving_goals`, `recurring_transactions`, `reminders`, `app_settings`; thêm `wallet_id` cho `transactions`.
- Thêm models: `WalletModel`, `BudgetModel`, `SavingGoalModel`, `RecurringTransactionModel`, `ReminderModel`.
- Thêm providers: wallet, category, budget, saving goal, recurring, reminder, theme, security.
- Nâng Dashboard với ví Nâng cao, thu/chi tháng này, tỷ lệ chi tiêu, quick actions 6 mục và cảnh báo ngân sách.
- Thêm màn: quản lý ví, danh mục, ngân sách, mục tiêu tiết kiệm, giao dịch định kỳ, nhắc nhở, bảo mật, giao diện, báo cáo.
- Nâng thống kê với biểu đồ đường xu hướng số dư, top 5 danh mục, so sánh tháng.
- Nâng Profile với avatar/menu Nâng cao và thống kê ví/giao dịch/mục tiêu.
- Chạy `flutter pub get`: thành công.
- Chạy `dart format lib test`: thành công.
- Chạy `flutter analyze`: không có issue.
- Chạy `flutter test`: tất cả test pass.
- Chạy `flutter build apk --debug`: thành công, tạo `build/app/outputs/flutter-apk/app-debug.apk`.
- Gỡ các chữ VIP/Pro khỏi UI/source và đổi widget thẻ dùng chung thành `PremiumCard`.
- Nâng lại các biểu đồ thống kê: donut chi tiêu có tổng tiền/legend phần trăm, cột thu chi rõ trục/tooltip, đường số dư có nhãn tiền và ngày.
- Chạy lại `dart format lib test`, `flutter analyze`, `flutter test`: thành công, không còn lỗi.
- Thay bộ lọc tháng ở màn Giao dịch và Thống kê bằng dialog chọn tháng/năm riêng, không dùng chọn ngày.
- Sửa dialog chọn tháng để nút tháng không che chữ; thống kê chuyển sang 2 chế độ `Theo tháng` và `Theo năm`.

