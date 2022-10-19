package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/stretchr/testify/assert"
)

func TestAccountSetup(t *testing.T) {
	// Note: projectName can't be too long since S3 bucket names have a 63 character max length
	projectName := "platform-test-account"
	accountId := "368823044688"

	region := "us-east-1"

	defer TeardownAccount(t)
	SetUpAccount(t, projectName)
	ValidateTerraformBackend(t, region, projectName)
	ValidateGithubActionsAuth(t, accountId, projectName)
}

func ValidateTerraformBackend(t *testing.T, region string, projectName string) {
	expectedTfStateBucket := fmt.Sprintf("%s-368823044688-%s-tf-state", projectName, region)
	expectedTfStateKey := fmt.Sprintf("%s/infra/account.tfstate", projectName)
	aws.AssertS3BucketExists(t, region, expectedTfStateBucket)
	_, err := aws.GetS3ObjectContentsE(t, region, expectedTfStateBucket, expectedTfStateKey)
	assert.NoError(t, err, fmt.Sprintf("Failed to get tfstate object from tfstate bucket %s", expectedTfStateBucket))
}

func ValidateGithubActionsAuth(t *testing.T, accountId string, projectName string) {
	githubActionsRole := fmt.Sprintf("arn:aws:iam::%s:role/%s-github-actions", accountId, projectName)
	// Check that GitHub Actions can authenticate with AWS
	err := shell.RunCommandE(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "check-github-actions-auth", fmt.Sprintf("GITHUB_ACTIONS_ROLE=%s", githubActionsRole)},
		WorkingDir: "../",
	})
	assert.NoError(t, err, "GitHub actions failed to authenticate")
}

func SetUpAccount(t *testing.T, projectName string) {
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "set-up-account", fmt.Sprintf("PROJECT_NAME=%s", projectName)},
		WorkingDir: "../",
	})
}

func TeardownAccount(t *testing.T) {
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "destroy-account"},
		WorkingDir: "../",
	})
}
