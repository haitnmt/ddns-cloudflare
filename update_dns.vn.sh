#!/bin/bash

# Token API (Khuyến nghị)
auth_token="xxxxxxxxxxxxxxxxxxxxxxx-Token"

# Domain và DNS record để đồng bộ
zone_identifier="xxxxxxxxxxxxxxxxxxxxx-Identifier" # Tìm trong tab "Overview" của domain
record_name="ip.domain.com"           # Record cần đồng bộ

# KHÔNG SỬA DƯỚI ĐÂY

# Bắt đầu script
echo "Bắt đầu kiểm tra"

# Kiểm tra IP mạng ngoài hiện tại
ip=$(curl -s4 https://icanhazip.com/)
if [[ -z "$ip" ]]; then
  ip=$(curl -s4 https://ifconfig.me/)
  if [[ -z "$ip" ]]; then
    echo "Lỗi mạng, không lấy được IP." >&2
    exit 1
  fi
fi
echo "  > IP mạng ngoài hiện tại: $ip"

# Header xác thực
header_auth_param=( -H "Authorization: Bearer $auth_token" )

# Lấy bản ghi DNS
record=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$record_name&type=A" "${header_auth_param[@]}" -H "Content-Type: application/json")

# Kiểm tra xem lấy bản ghi DNS có thành công không
if [[ -z "$record" ]] || [[ "$record" == *'"count":0'* ]]; then
  echo "Bản ghi không tồn tại, đang tạo bản ghi mới..."
  
  # Tạo bản ghi mới
  create_record=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records" \
    "${header_auth_param[@]}" -H "Content-Type: application/json" \
    --data '{"type":"A","name":"'$record_name'","content":"'$ip'","ttl":3600,"proxied":true}')
  
  # Kiểm tra kết quả tạo bản ghi mới
  if [[ "$create_record" == *'"success":true'* ]]; then
    echo "Tạo bản ghi mới thành công."
    exit 0
  else
    echo "Tạo bản ghi mới thất bại. KẾT QUẢ:\n$create_record" >&2
    exit 1
  fi
fi

# Lấy mã bản ghi và địa chỉ IP hiện tại từ bản ghi DNS
record_identifier=$(echo "$record" | sed -n 's/.*"id":"\([^"]*\).*/\1/p')
old_ip=$(echo "$record" | sed -n 's/.*"content":"\([^"]*\).*/\1/p')
echo "  > Giá trị bản ghi DNS hiện tại: $old_ip"

# So sánh IP hiện tại với IP mới
if [[ "$ip" == "$old_ip" ]]; then
  echo "Không cần cập nhật IP  cho '$record_name'. IP không thay đổi."
  exit 0
fi
echo "  > IP khác nhau, đang đồng bộ..."

# Cập nhật bản ghi DNS
update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
  "${header_auth_param[@]}" -H "Content-Type: application/json" \
  --data '{"id":"'$zone_identifier'","type":"A","proxied":true,"name":"'$record_name'","content":"'$ip'","ttl":3600}')

# Kiểm tra kết quả cập nhật
if [[ "$update" == *'"success":true'* ]]; then
  echo -e "Cập nhật cho A record '$record_name ($record_identifier)' thành công.\n  - Giá trị cũ: $old_ip\n  + Giá trị mới: $ip"
else
  echo "Cập nhật cho A record '$record_name ($record_identifier)' thất bại. KẾT QUẢ:\n$update" >&2
  exit 1
fi
