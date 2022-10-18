package test

import (
	"fmt"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/environment"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/stretchr/testify/assert"
)

// An example of how to test the simple Terraform module in examples/terraform-basic-example using Terratest.
func TestAccountSetup(t *testing.T) {
	t.Parallel()

	environment.RequireEnvVar(t, "PROJECT_NAME")
	projectName := os.Getenv("PROJECT_NAME")

	region := "us-east-1"
	expectedTfStateBucket := fmt.Sprintf("%s-368823044688-us-east-1-tf-state", projectName)
	expectedTfStateKey := fmt.Sprintf("%s/infra/account.tfstate", projectName)

	defer shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "destroy-account"},
		WorkingDir: "../",
	})

	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "set-up-account"},
		WorkingDir: "../",
	})

	aws.AssertS3BucketExists(t, region, expectedTfStateBucket)
	_, err := aws.GetS3ObjectContentsE(t, region, expectedTfStateBucket, expectedTfStateKey)
	assert.NoError(t, err, fmt.Sprintf("Failed to get tfstate object from tfstate bucket %s", expectedTfStateBucket))

	// Check that GitHub Actions can authenticate with AWS
	err = shell.RunCommandE(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "check-github-actions-auth"},
		WorkingDir: "../",
	})
	assert.NoError(t, err, "GitHub actions failed to authenticate")
}
