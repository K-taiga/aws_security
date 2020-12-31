
resource "aws_cloudtrail" "default" {
  name           = "default"
  enable_logging = true
  # 全リージョンの証跡ログを保存
  is_multi_region_trail = true
  # IAMなどのグローバルなサービスも追跡
  include_global_service_events = true
  enable_log_file_validation    = true
  # cloudwatch logsに配信するためarnを渡す
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.logs.arn}:*"
  cloud_watch_logs_role_arn  = module.cloudtrail_iam_role.arn
  s3_bucket_name             = module.cloudtrail_log_bucket.name
  depends_on                 = [aws_s3_bucket_policy.cloudtrail_log]
}
