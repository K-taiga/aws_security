# Service-Linkedロール
# aws configを使用する際に自動で作られるロール terraformだと自動で作成されないため作成
resource "aws_iam_service_linked_role" "config" {
  aws_service_name = "config.amazonaws.com"
}

# 設定レコーダー
resource "aws_config_configuration_recorder" "default" {
  name     = "default"
  role_arn = aws_iam_service_linked_role.config.arn

  recording_group {
    # サポートされているすべてのリソースを記録
    all_supported = true
    # globalリソースも記録
    include_global_resource_types = true
  }
}

# 配信チャネル
resource "aws_config_delivery_channel" "default" {
  name           = aws_config_configuration_recorder.default.name
  s3_bucket_name = module.config_log_bucket.name
  depends_on     = [aws_config_configuration_recorder.default]
}

# 設定レコーダーのステータス
resource "aws_config_configuration_recorder_status" "default" {
  name       = aws_config_configuration_recorder.default.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.default]
}
