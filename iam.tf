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
