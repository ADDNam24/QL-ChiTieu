# Run Optimization

## Nguyên tắc chạy lệnh

- `flutter pub get`: tối đa 3 phút.
- `flutter analyze`: tối đa 3 phút.
- `flutter test`: tối đa 3 phút.
- `flutter build apk --debug`: tối đa 5 phút.
- Không chạy `flutter clean` trừ khi thật sự cần vì làm chậm vòng lặp.
- Ưu tiên `dart format lib test` trước `flutter analyze` để giảm lỗi format/lint.

## Lệnh khuyến nghị

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

## Ghi chú môi trường

- Project không dùng FVM trong thư mục hiện tại.
- Không đổi `applicationId`/package Android.
- Không thêm package native cấu hình phức tạp nếu không cần thiết.

## Kết quả chạy gần nhất

- `flutter pub get`: hoàn tất trong khoảng 7 giây.
- `dart format lib test`: hoàn tất trong khoảng 5 giây.
- `flutter analyze`: sạch lỗi, hoàn tất trong khoảng 8 giây.
- `flutter test`: pass, hoàn tất trong khoảng 10 giây.
- `flutter build apk --debug`: build thành công trong khoảng 163 giây, dưới giới hạn 5 phút.
- Lần chỉnh UI/chart gần nhất: `dart format lib test` hoàn tất khoảng 5 giây, `flutter analyze` sạch lỗi khoảng 10 giây, `flutter test` pass khoảng 7 giây.

