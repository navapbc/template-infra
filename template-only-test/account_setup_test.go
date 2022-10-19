package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/stretchr/testify/assert"
)

// An example of how to test the simple Terraform module in examples/terraform-basic-example using Terratest.
func TestAccountSetup(t *testing.T) {
	t.Parallel()

	// Note: projectName can't be too long since S3 bucket names have a 63 character max length
	projectName := "platform-test-account"
	accountId := 368823044688
	githubActionsRole := fmt.Sprintf("arn:aws:iam::%s:role/%s-github-actions", accountId, projectName)

	region := "us-east-1"
	expectedTfStateBucket := "platform-template-infra-368823044688-us-east-1-tf-state"
	expectedTfStateKey := "platform-template-infra/infra/account.tfstate"

	defer shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "destroy-account"},
		WorkingDir: "../",
	})

	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "set-up-account", fmt.Sprintf("PROJECT_NAME=%s", projectName)},
		WorkingDir: "../",
	})

	aws.AssertS3BucketExists(t, region, expectedTfStateBucket)
	_, err := aws.GetS3ObjectContentsE(t, region, expectedTfStateBucket, expectedTfStateKey)
	assert.NoError(t, err, "Failed to get tfstate object from tfstate bucket")

	// Check that GitHub Actions can authenticate with AWS
	err = shell.RunCommandE(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "check-github-actions-auth", fmt.Sprintf("GITHUB_ACTIONS_ROLE=%s", githubActionsRole)},
		WorkingDir: "../",
	})
	assert.NoError(t, err, "GitHub actions failed to authenticate")
}
