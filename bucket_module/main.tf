variable "name" {}

resource "aws_s3_bucket" "this" {
  bucket = var.name
  force_destroy = true

  # バージョニングを有効にしオブジェクトの復元を可能とする
  versioning {
    enabled = true
  }

  # オブジェクト保存時に暗号化、参照時には復号する
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # 180日後に自動で削除
  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

output "arn" {
  value = aws_s3_bucket.this.arn
}

output "name" {
  value = aws_s3_bucket.this.id
}
