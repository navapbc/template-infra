resource "aws_iam_role" "backup" {
  name                 = "backup-${local.name}"
  path                 = "/delegatedadmin/developer/"
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/cms-cloud-admin/developer-boundary-policy"
  assume_role_policy   = data.aws_iam_policy_document.backup_assume_role.json
}

data "aws_iam_policy_document" "backup_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "backup" {
  role   = aws_iam_role.backup.name
  name   = "access-to-aws-backup"
  policy = data.aws_iam_policy_document.aws_backup_access.json
}
data "aws_iam_policy_document" "aws_backup_access" {
  statement {
    actions = [
      "backup:DescribeBackupVault",
      "backup:CopyIntoBackupVault"
    ]
    resources = [
       aws_backup_vault.vault.arn
    ]
  }
  statement {
    actions = [
        "kms:DescribeKey"
    ]
    resources = [ "*" ]
  }
}


resource "aws_iam_role_policy" "backup_rds" {
  role   = aws_iam_role.backup.name
  name   = "access-to-rds-backup"
  policy = data.aws_iam_policy_document.aws_rds_backup_access.json
}
data "aws_iam_policy_document" "aws_rds_backup_access" {
  statement {
    actions = [
      "rds:AddTagsToResource",
      "rds:ListTagsForResource",
      "rds:DescribeDBSnapshots",
      "rds:CreateDBSnapshot",
      "rds:CopyDBSnapshot",
      "rds:DescribeDBInstances",
      "rds:CreateDBClusterSnapshot",
      "rds:DescribeDBClusters",
      "rds:DescribeDBClusterSnapshots",
      "rds:CopyDBClusterSnapshot",
      "rds:DeleteDBSnapshot",
      "rds:ModifyDBSnapshotAttribute",
      "rds:DeleteDBClusterSnapshot",
      "rds:ModifyDBClusterSnapshotAttribute"
    ]
    resources = concat(var.resource_arns, [ 
      # At this time, there doesn't even seem to be a way to limit these via conditionals, the trailing ID is just 'job-<guid>'
      # Might be worth checking in the future though, since I think this would allow ADOs to mess with each others' snapshots?
      "arn:aws:rds:*:*:snapshot:awsbackup:*", 
      "arn:aws:rds:*:*:cluster-snapshot:awsbackup:*"
    ])
  }
}