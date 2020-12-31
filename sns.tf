resource "aws_sns_topic" "mail" {
  name = "alert-mail"
}

data "aws_iam_policy_document" "cloudwatch_events" {
  statement {
    effect    = "Allow"
    resources = [aws_sns_topic.mail.arn]
    # cloudwatch eventsとcloudwatch alarmsへのpublishを許可
    actions = ["sns:Publish"]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "cloudwatch.amazonaws.com"
      ]
    }
  }
}

# policyをsnsに紐付け
resource "aws_sns_topic_policy" "cloudwatch_events" {
  arn    = aws_sns_topic.mail.arn
  policy = data.aws_iam_policy_document.cloudwatch_events.json
}

# メールのサブスクリプションはterraformで作れないため、cloudFormationからyaml形式をエンコードして作成
resource "aws_cloudformation_stack" "mail_subscription" {
  name = "mail-subscription"

  template_body = yamlencode({
    Description = "Managed by Terraform"
    Resources = {
      MailSubscription = {
        Type = "AWS::SNS::Subscription"
        Properties = {
          TopicArn = aws_sns_topic.mail.arn
          Protocol = "email"
          Endpoint = "kumaeers@gmail.com"
        }
      }
    }
  })
}
