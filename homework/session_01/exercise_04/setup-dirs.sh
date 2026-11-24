#!/bin/bash
# ==============================================================================
# Script: setup-dirs.sh
# Mục tiêu: Thiết lập thư mục ứng dụng và phân quyền sở hữu tối giản (Least Privilege)
# Bài tập: Session 01 - Exercise 04
# Học viên: sonledev
# ==============================================================================

set -e

echo "[1/4] Tạo group và user hệ thống quickbite (nếu chưa có)..."
if ! getent group quickbite >/dev/null 2>&1; then
    sudo groupadd quickbite
fi

if ! id -u quickbite >/dev/null 2>&1; then
    sudo useradd -r -g quickbite -s /bin/false quickbite
fi

echo "[2/4] Tạo thư mục làm việc của dự án: /opt/quickbite/user-service..."
sudo mkdir -p /opt/quickbite/user-service

echo "[3/4] Thay đổi quyền sở hữu sang quickbite:quickbite..."
sudo chown -R quickbite:quickbite /opt/quickbite

echo "[4/4] Đặt quyền hạn truy cập tối giản 750 cho /opt/quickbite..."
sudo chmod -R 750 /opt/quickbite

echo "=== KIỂM TRA THUỘC TÍNH PHÂN QUYỀN THƯ MỤC ==="
ls -la /opt

# ==============================================================================
# GIẢI THÍCH Ý NGHĨA MÃ SỐ PHÂN QUYỀN 750 (drwxr-x---):
#
# Mã số 750 bao gồm 3 chữ số bát phân (Octal), tương ứng với 3 nhóm đối tượng:
# 1. Chữ số thứ nhất: 7 (Owner / Chủ sở hữu - user quickbite)
#    - Giá trị: 4 (Read - đọc) + 2 (Write - ghi/sửa/xóa) + 1 (Execute - thực thi/truy cập) = 7 (rwx)
#    - Ý nghĩa: Tiến trình user-service chạy dưới quyền user quickbite có toàn quyền quản lý
#      thư mục, đọc file JAR và ghi file log/tạm nếu cần.
#
# 2. Chữ số thứ hai: 5 (Group / Nhóm sở hữu - group quickbite)
#    - Giá trị: 4 (Read - đọc) + 0 (No Write) + 1 (Execute - thực thi/truy cập) = 5 (r-x)
#    - Ý nghĩa: Các thành viên thuộc nhóm quickbite có thể đọc file và truy cập vào thư mục,
#      nhưng không được phép sửa đổi hoặc xóa file cấu hình.
#
# 3. Chữ số thứ ba: 0 (Others / Tất cả người dùng khác trên hệ thống)
#    - Giá trị: 0 (No Read) + 0 (No Write) + 0 (No Execute) = 0 (---)
#    - Ý nghĩa: Bất kỳ người dùng nào khác trong hệ điều hành không có quyền truy cập, không thể
#      đọc trộm file cấu hình (application.yml, database password) hay can thiệp vào file JAR,
#      đáp ứng nghiêm ngặt nguyên tắc đặc quyền tối thiểu (Least Privilege).
# ==============================================================================
