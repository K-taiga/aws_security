data "aws_iam_policy_document" "cloudwatch_access" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
    ]
  }
}

module "chatbot_iam_role" {
  source     = "./iam_role_module"
  name       = "chatbot"
  identifier = "chatbot.amazonaws.com"
  policy     = data.aws_iam_policy_document.cloudwatch_access.json
}

resource "aws_sns_topic" "chatbot" {
  name = "chatbot"
}

data "aws_iam_policy_document" "chatbot" {
  statement {
    effect    = "Allow"
    resources = [aws_sns_topic.chatbot.arn]
    actions   = ["sns:Publish"]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "cloudwatch.amazonaws.com"
      ]
    }
  }
}

resource "aws_sns_topic_policy" "chatbot" {
  arn    = aws_sns_topic.chatbot.arn
  policy = data.aws_iam_policy_document.chatbot.json
}


# terraformとAWS CLIから作れないため、CloudFormationで作成
resource "aws_cloudformation_stack" "chatbot" {
  name = "chatbot"

  template_body = yamlencode({
    Description = "Managed by Terraform"
    Resources = {
      AlertNotifications = {
        Type = "AWS::Chatbot::SlackChannelConfiguration"
        Properties = {
          ConfigurationName = "AlertNotifications"
          SlackWorkspaceId  = "T2X9S1TR9"
          SlackChannelId    = "C01JB14L6BX"
          IamRoleArn        = module.chatbot_iam_role.arn
          SnsTopicArns      = [aws_sns_topic.chatbot.arn]
        }
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "chatbot" {
  target_id = "chatbot"
  rule      = aws_cloudwatch_event_rule.guardduty.name
  arn       = aws_sns_topic.chatbot.arn
}