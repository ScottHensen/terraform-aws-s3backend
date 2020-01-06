# create least privileged IAM role that another AWS acct can assume 
#  in order to use this backend 
# 
# grants permissions for storing state files in S3, 
#  and getting/deleting records in dynamoDB for locking purposes

data "aws_caller_identity" "current" {}

locals {
    principal_arn = var.principal_arn != null ? var.principal_arn : data.aws_caller_identity.current.arn 
}

resource "aws_iam_role" "iam_role" {
    name = "${var.namespace}-tf-assume-role"
    force_detach_policies = true 
    assume_role_policy = <<-EOF
        {
            "Version" : "2012-10-17",
            "Statement" : [
                {
                    "Action" : "sts:AssumeRole",
                    "Principal" : {
                        "AWS" : "${local.principal_arn}"
                    },
                    "Effect" : "Allow"
                }
            ]
        }
    EOF

    tags = {
        ResourceGroup = var.namespace
    }
}

data "aws_iam_policy_document" "policy_doc" {
    statement {
        actions = [
            "s3:LlistBucket"
        ]
        resources = [
            aws_s3_bucket.aws_s3_bucket.arn 
        ]
    }

    statement {
        actions = [
            "s3:GetObject", 
            "s3:PutObject"
        ]
        resources = [ 
            "${aws_s3_bucket.aws_s3_bucket.arn}/*"
        ]
    }

    statement {
        actions = [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:DeleteItem"
        ]
        resource = [
            aws_dynamodb_table.dynamodb_table.arn 
        ]
    }
}

resource "aws_iam_policy" "iam_policy" {
    name   = "${var.namespace}-tf-policy"
    path   = "/"
    policy = data.aws_iam_policy_document.policy_doc.json
}

resource "aws_iam_role_policy_attachment" "policy_attach" {
    role       = aws_iam_role.iam_role.name
    policy_arn = aws_iam_policy.iam_policy.arn 
}