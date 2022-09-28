terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.32.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "pietto1"
}

locals {
  allowed_services_compute     = ["ec2", "ecr", "eks", "ecs", "lambda", "autoscaling", "elasticloadbalancing"]
  allowed_services_networking  = ["vpc", "route53", "route53domains", "route53resolver", "servicediscovery"]
  allowed_services_storage     = ["s3", "backup", "dynamo", "dms", "elasticfilesystem"]
  allowed_services_databases   = ["rds", "dynamo", "elasticache"]
  allowed_services_management  = ["cloudwatch", "events", "logs", "servicequotas", "ssm"]
  allowed_services_analytics   = ["es", "firehose", "kinesis", "kinesisanalytics", "redshift"]
  allowed_services_application = ["ses", "sns", "sqs", "xray", "applicationinsights", "application-autoscaling"]
  allowed_services_security    = ["iam", "acm", "kms", "secretsmanager"]

  allowed_services = concat(
    local.allowed_services_compute,
    local.allowed_services_networking,
    local.allowed_services_storage,
    local.allowed_services_databases,
    local.allowed_services_management,
    local.allowed_services_analytics,
    local.allowed_services_application,
    local.allowed_services_security
  )
}

module "iam_read_only_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-read-only-policy"

  name        = "e2g-read-only-policy"
  path        = "/"
  description = "Read-only-policy with access to services listed in allowed_services."

  allowed_services = local.allowed_services
  tags = {
    PolicyDescription = "Read-only-policy with access to services listed in allowed_services."
  }  
}


module "iam_assumable_role_custom_trust_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  create_role = true

  allow_self_assume_role = true

  role_name = "e2g-read-only-role"

  custom_role_trust_policy = data.aws_iam_policy_document.custom_trust_policy.json
  custom_role_policy_arns  = [module.iam_read_only_policy.arn]
}

data "aws_iam_policy_document" "custom_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}