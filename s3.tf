resource "aws_s3_bucket" "log" {
  # 一意のバケット名
  bucket = "kumaeers-log"

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

# S3へのアクセスが非公開でも保存しているオブジェクトが公開設定の場合にアクセスできない設定
resource "aws_s3_bucket_public_access_block" "log" {
  bucket                  = aws_s3_bucket.log.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

