# Cài đặt các thư viện cần thiết
library(sparklyr)
library(dplyr)

# Kết nối Spark
sc <- spark_connect(master = "local")

# Đọc dữ liệu từ file CSV
df <- spark_read_csv(sc, path = "C:/Users/hieum/Downloads/hotel_booking_balanced.csv", 
                     infer_schema = TRUE, header = TRUE)

# Kiểm tra danh sách cột
print(colnames(df))

# Chia dữ liệu thành train (80%) và test (20%)
df_split <- sdf_random_split(df, training = 0.8, testing = 0.2, seed = 123)
df_train <- df_split$training
df_test <- df_split$testing

# Huấn luyện mô hình Random Forest trên tập train
rf_model <- df_train %>%
  ml_random_forest(is_canceled ~ ., type = "classification")

# Lấy danh sách đặc trưng quan trọng
importance_df <- ml_feature_importances(rf_model)

# Kiểm tra danh sách đặc trưng quan trọng
print(importance_df)

# Sắp xếp theo mức độ quan trọng và chọn 20 đặc trưng quan trọng nhất
selected_features <- importance_df %>%
  arrange(desc(importance)) %>%
  slice_head(n = 20) %>%
  pull(feature)

# Giữ lại các cột đã chọn và nhãn "is_canceled"
df_train_selected <- df_train %>%
  select(any_of(c(selected_features, "is_canceled")))

df_test_selected <- df_test %>%
  select(any_of(c(selected_features, "is_canceled")))

# Huấn luyện lại mô hình với đặc trưng tối ưu trên tập train
rf_model_optimized <- df_train_selected %>%
  ml_random_forest(is_canceled ~ ., type = "classification")

# Kiểm tra số lượng đặc trưng thực sự được sử dụng
print(paste("Số đặc trưng mô hình sử dụng:", rf_model_optimized$model_parameters$num_features))

# Dự đoán trên tập test
predictions <- ml_predict(rf_model_optimized, df_test_selected)

# Đánh giá mô hình (AUC - Area Under Curve)
auc <- ml_binary_classification_evaluator(predictions,
                                          label_col = "is_canceled",
                                          metric_name = "areaUnderROC")

print(paste("AUC trên tập test:", auc))
