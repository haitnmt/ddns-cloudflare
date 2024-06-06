# Cloudflare DNS Updater

Một script đơn giản để tự động cập nhật các bản ghi DNS của Cloudflare với địa chỉ IP hiện tại. Thích hợp cho việc duy trì các bản ghi DNS luôn cập nhật đối với các địa chỉ IP động.

## Mục lục

- [Giới thiệu](#giới-thiệu)
- [Tính năng](#tính-năng)
- [Cài đặt](#cài-đặt)
- [Sử dụng](#sử-dụng)
- [Cấu hình](#cấu-hình)
- [Thiết lập Cron Job](#thiết-lập-cron-job)
- [Giấy phép](#giấy-phép)

## Giới thiệu

Cloudflare DNS Updater là một script bash giúp kiểm tra địa chỉ IP bên ngoài hiện tại và cập nhật một bản ghi DNS cụ thể trên Cloudflare. Script này được thiết kế để chạy định kỳ, chẳng hạn như mỗi 5 phút, bằng cách sử dụng cron jobs. Nó đặc biệt hữu ích cho người dùng có địa chỉ IP động cần giữ cho các bản ghi DNS của họ chính xác.

## Tính năng

- Lấy địa chỉ IP bên ngoài hiện tại.
- So sánh địa chỉ IP hiện tại với bản ghi DNS hiện tại.
- Cập nhật bản ghi DNS trên Cloudflare nếu địa chỉ IP đã thay đổi.
- Sử dụng API của Cloudflare để cập nhật một cách an toàn và hiệu quả.
- Có thể thiết lập để chạy tự động bằng cron jobs.
- Bao gồm script dịch vụ OpenRC để dễ dàng thiết lập trên Alpine Linux.

## Cài đặt

1. Tải script về và đặt vào một thư mục phù hợp, chẳng hạn như `/usr/local/bin/`.
2. Đảm bảo script có quyền thực thi:
```sh
    chmod +x /usr/local/bin/update_dns.sh
```
## Sử dụng
1. Cấu hình script: Mở script và điền các thông tin cần thiết như auth_token, zone_identifier, và record_name.
2. Chạy script: Thực thi script để kiểm tra và cập nhật bản ghi DNS:
```sh
    /usr/local/bin/update_dns.vn.sh
```
## Cấu hình
Sửa đổi các giá trị sau trong script để phù hợp với cấu hình của bạn:
```sh
    # Token API của Cloudflare
    auth_token="YOUR_CLOUDFLARE_API_TOKEN"

    # Chi tiết miền và bản ghi DNS
    zone_identifier="YOUR_ZONE_IDENTIFIER"
    record_name="ip.domain.com"
```
## Thiết lập Cron Job
Để chạy script mỗi 5 phút, hãy thiết lập một cron job:
1. Mở trình chỉnh sửa crontab:
```sh
    export EDITOR=nano
    crontab -e
```
2. Thêm dòng sau vào tệp crontab:
```sh
    */5 * * * * /usr/local/bin/update_dns.sh
```
## Giấy phép
Dự án này được cấp phép theo giấy phép MIT. Xem tệp [GIAYPHEP](https://github.com/haitnmt/ddns-cloudflare/blob/main/GIAYPHEP) để biết thêm chi tiết.

---
Chúc các bạn thành công!!!

