resource "aws_cloudwatch_log_group" "logs" {
  name = "CloudTrail/logs"
  # logの保存期間
  retention_in_days = 14
}
