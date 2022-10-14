# Destroy infrastructure

To destroy everything you'll need to undeploy all the infrastructure in reverse order that they were created. In particular, the account root module(s) need to be destroyed last.

## Instructions

1. First destroy all your environments by running `terraform destroy` in each of your environment module folders

    ```bash
    # within each env folder in /infra/envs/ (dev, stage, etc)
    terraform destroy
    ```

2. Then to destroy the backends, first you'll need to add `force_destroy = true` to the S3 buckets, and update the lifecycle block to set `prevent_destroy = false`. Then run `terraform apply`. The reason we need to do this is because S3 buckets by default are protected from destruction to avoid loss of data. See [Terraform: Destroy/Replace Buckets](https://medium.com/interleap/terraform-destroy-replace-buckets-cf9d63d0029d) for a more in depth explanation.

    ```terraform
    # infra/modules/modules/terraform-backend-s3/main.tf

    resource "aws_s3_bucket" "tf_state" {
      bucket = var.state_bucket_name

      force_destroy = true

      # Prevent accidental destruction a developer executing terraform destory in the wrong directory. Contains terraform state files.
      lifecycle {
        prevent_destroy = false
      }
    }

    ...

    resource "aws_s3_bucket" "tf_log" {
      bucket = var.tf_logging_bucket_name
      force_destroy = true
    }
    ```

3. Then since we're going to be destroying the tfstate buckets, you'll want to move the tfstate file out of S3 and back to your local system. Comment out or delete the s3 backend configuration and run `terraform init -force-copy` to copy the tfstate back to a local tfstate file.

    ```terraform
    # infra/accounts/account/main.tf

    # Comment out or delete the backend block
    backend "s3" {
      ...
    }
    ```

4. Finally, you can run `terraform destroy` within the backend account folders.

    ```bash
    terraform destroy
    ```
