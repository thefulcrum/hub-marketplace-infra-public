output "s3_access_policy" {
    value = aws_iam_policy.s3_policy.arn
}

output "pod_execution_role" {
    value = aws_iam_role.pod_execution_role.arn
}