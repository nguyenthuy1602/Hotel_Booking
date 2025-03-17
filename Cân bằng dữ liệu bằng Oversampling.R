library(dplyr)

# Kiểm tra số lượng mỗi nhóm
table(cleaned_data$is_canceled)

# Chia dữ liệu thành 2 nhóm
data_majority <- cleaned_data %>% filter(is_canceled == 0)
data_minority <- cleaned_data %>% filter(is_canceled == 1)

# Tăng số lượng nhóm thiểu số bằng cách nhân bản dữ liệu
set.seed(123)  # Đảm bảo kết quả tái lập
data_minority_oversampled <- data_minority %>%
  sample_n(nrow(data_majority), replace = TRUE)  # Nhân bản cho đủ số lượng

# Gộp lại thành tập dữ liệu mới
balanced_data <- bind_rows(data_majority, data_minority_oversampled)

# Kiểm tra lại số lượng
table(balanced_data$is_canceled)

# Lưu file mới
write_csv(balanced_data, "C:/Users/hieum/Downloads/hotel_booking_balanced.csv")

getwd()
