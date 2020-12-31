# adminのpolicy_documentをjsonで作成
data "aws_iam_policy_document" "admin_access" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

# documentをpolicyに紐付け
resource "aws_iam_policy" "admin_access" {
  name   = "admin-access"
  policy = data.aws_iam_policy_document.admin_access.json
}

# iamユーザー
resource "aws_iam_user" "terraform" {
  name          = "terraform"
  force_destroy = true
}

# iamグループ
resource "aws_iam_group" "admin" {
  name = "admin"
}

# groupにiamユーザーを関連付ける
resource "aws_iam_group_membership" "admin" {
  name  = aws_iam_group.admin.name
  group = aws_iam_group.admin.name
  users = [aws_iam_user.terraform.name]
}

# iamグループにもpolicyをアタッチし、グループで権限を付与できるようにする
resource "aws_iam_group_policy_attachment" "admin" {
  group      = aws_iam_group.admin.name
  policy_arn = aws_iam_policy.admin_access.arn
}


# IAMアカウントのパスワードポリシー(ルートユーザーには適用されない)
# resource "aws_iam_account_password_policy" "strict" {
#   minimum_password_length        = 32
#   require_uppercase_characters   = true
#   require_lowercase_characters   = true
#   require_numbers                = true
#   require_symbols                = true
#   allow_users_to_change_password = true
#   # パスワードの再利用禁止
#   password_reuse_prevention      = 24
#   # パスワードの有効期限 0は無期限
#   max_password_age               = 0
# }

module "ec2_role" {
  source     = "./iam_role_module"
  name       = "ec2-role"
  identifier = "ec2.amazonaws.com"
  policy     = data.aws_iam_policy_document.ec2_document.json
}

data "aws_iam_policy_document" "ec2_document" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }
}
