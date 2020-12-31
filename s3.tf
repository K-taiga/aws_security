module "log_bucket" {
  source = "./bucket_module"
  name   = "kumaeers-log"
}

module "cloudtrail_log_bucket" {
  source = "./bucket_module"
  name   = "kumaeers-cloudtrail-log"
}

# cloudtrail用のバケットのpolicy
data "aws_iam_policy_document" "cloudtrail_log" {
  # Getの許可
  statement {
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [module.cloudtrail_log_bucket.arn]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  # Putの許可
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${module.cloudtrail_log_bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_log" {
  bucket     = module.cloudtrail_log_bucket.name
  policy     = data.aws_iam_policy_document.cloudtrail_log.json
  depends_on = [module.cloudtrail_log_bucket]
}