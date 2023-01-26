resource "aws_iam_policy" "s3_policy" {
  name = "${var.app_name}_s3_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
      "Effect": "Allow",
      "Resource": [
                "arn:aws:s3:::${var.bucket_name}/*",
                "arn:aws:s3:::${var.bucket_name}"
            ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "pod_execution_role" {
   name = "${var.app_name}_pod_execution_role"

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy", aws_iam_policy.s3_policy.arn]

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks-fargate-pods.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  })
 
}