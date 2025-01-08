data "aws_caller_identity" "current" {}

################################
#    Creating Role for EC2     # 
################################

resource "aws_iam_role" "ec2-instance-role" {
  name = "ec2-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name = "ec2-instance-role"
  }
}

resource "aws_iam_policy" "DBAndGrafanaAccessPolicy" {
  name        = "DBAndGrafanaAndSecretsAccessPolicy"
  description = "Allow EC2 instance to access Aurora DB, S3, and Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetMetricData",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSecurityGroups",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:RevokeSecurityGroupEgress"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "rds:DescribeDBClusters",
          "rds:DescribeDBInstances",
          "rds:DescribeDBSubnetGroups",
          "rds:Connect",
          "rds-data:ExecuteStatement",
          "rds-data:BatchExecuteStatement",
          "rds-data:BeginTransaction",
          "rds-data:CommitTransaction",
          "rds-data:RollbackTransaction"
        ],
        Resource = ["*"
          # "arn:aws:rds:${var.region}:${data.aws_caller_identity.current.account_id}:cluster:${aws_rds_cluster.de-aurora-cluster.cluster_identifier}",
          # "arn:aws:rds:${var.region}:${data.aws_caller_identity.current.account_id}:db:${aws_rds_cluster.de-aurora-cluster.cluster_identifier}:*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectAcl"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.book-recommendation-data-bucket.bucket}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.book-recommendation-data-bucket.bucket}"
        ]
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ec2-instance-role-policy-attachment" {
  role       = aws_iam_role.ec2-instance-role.name
  policy_arn = aws_iam_policy.DBAndGrafanaAccessPolicy.arn
}

resource "aws_iam_instance_profile" "ec2-instance-profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2-instance-role.name
}