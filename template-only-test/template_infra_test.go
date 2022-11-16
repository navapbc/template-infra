package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Note: projectName can't be too long since S3 bucket names have a 63 character max length
var uniqueId = strings.ToLower(random.UniqueId())
var projectName = fmt.Sprintf("plt-tst-act-%s", uniqueId)

func TestSetUpAccount(t *testing.T) {
	defer TeardownAccount(t)
	SetUpProject(t, projectName)
	SetUpAccount(t)

	t.Run("ValidateAccount", ValidateAccount)
	t.Run("SetUpAppBackends", SubtestSetUpAppBackends)
}

func ValidateAccount(t *testing.T) {
	projectName := projectName
	accountId := "368823044688"
	region := "us-east-1"
	ValidateAccountBackend(t, region, projectName)
	ValidateGithubActionsAuth(t, accountId, projectName)
}

func SubtestSetUpAppBackends(t *testing.T) {
	projectName := projectName
	SetUpAppBackends(t, projectName)
	ValidateAppBackends(t)

	t.Run("TestBuildRepository", SubtestBuildRepository)
}

func SubtestBuildRepository(t *testing.T) {
	projectName := projectName
	defer TeardownBuildRepository(t)
	SetUpBuildRepository(t, projectName)
	ValidateBuildRepository(t, projectName)
}

func SetUpProject(t *testing.T, projectName string) {
	logger.Log(t, "::group::Configuring project")
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "set-up-project", fmt.Sprintf("PROJECT_NAME=%s", projectName)},
		WorkingDir: "../",
	})
	logger.Log(t, "::endgroup::")
}

func SetUpAccount(t *testing.T) {
	logger.Log(t, "::group::Setting up account")
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "set-up-account"},
		WorkingDir: "../",
	})
	logger.Log(t, "::endgroup::")
}

func SetUpAppBackends(t *testing.T, projectName string) {
	logger.Log(t, "::group::Configuring terraform backends for application modules")
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "set-up-app-backends", fmt.Sprintf("PROJECT_NAME=%s", projectName)},
		WorkingDir: "../",
	})
	logger.Log(t, "::endgroup::")
}

func SetUpBuildRepository(t *testing.T, projectName string) {
	logger.Log(t, "::group::Creating build repository resources")
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "set-up-app-build-repository", fmt.Sprintf("PROJECT_NAME=%s", projectName)},
		WorkingDir: "../",
	})
	logger.Log(t, "::endgroup::")
}

func ValidateAccountBackend(t *testing.T, region string, projectName string) {
	logger.Log(t, "::group::Validating terraform backend for account")
	expectedTfStateBucket := fmt.Sprintf("%s-368823044688-%s-tf-state", projectName, region)
	expectedTfStateKey := "infra/account.tfstate"
	aws.AssertS3BucketExists(t, region, expectedTfStateBucket)
	_, err := aws.GetS3ObjectContentsE(t, region, expectedTfStateBucket, expectedTfStateKey)
	assert.NoError(t, err, fmt.Sprintf("Failed to get tfstate object from tfstate bucket %s", expectedTfStateBucket))
	logger.Log(t, "::endgroup::")
}

func ValidateGithubActionsAuth(t *testing.T, accountId string, projectName string) {
	logger.Log(t, "::group::Validating that GitHub actions can authenticate with AWS account")
	githubActionsRole := fmt.Sprintf("arn:aws:iam::%s:role/%s-github-actions", accountId, projectName)
	// Check that GitHub Actions can authenticate with AWS
	err := shell.RunCommandE(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "check-github-actions-auth", fmt.Sprintf("GITHUB_ACTIONS_ROLE=%s", githubActionsRole)},
		WorkingDir: "../",
	})
	assert.NoError(t, err, "GitHub actions failed to authenticate")
	logger.Log(t, "::endgroup::")
}

func ValidateAppBackends(t *testing.T) {
	// TODO
}

func ValidateBuildRepository(t *testing.T, projectName string) {
	logger.Log(t, "::group::Validating ability to publish build artifacts to build repository")

	err := shell.RunCommandE(t, shell.Command{
		Command:    "make",
		Args:       []string{"release-build", fmt.Sprintf("PROJECT_NAME=%s", projectName)},
		WorkingDir: "../",
	})
	assert.NoError(t, err, "GitHub actions failed to authenticate")

	err = shell.RunCommandE(t, shell.Command{
		Command:    "make",
		Args:       []string{"release-publish", fmt.Sprintf("PROJECT_NAME=%s", projectName)},
		WorkingDir: "../",
	})
	assert.NoError(t, err, "GitHub actions failed to authenticate")

	logger.Log(t, "::endgroup::")
}

func TeardownAccount(t *testing.T) {
	logger.Log(t, "::group::Destroying account")
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "destroy-account"},
		WorkingDir: "../",
	})
	logger.Log(t, "::endgroup::")
}

func TeardownBuildRepository(t *testing.T) {
	terraform.Destroy(t, &terraform.Options{
		TerraformDir: "../infra/app/build-repository/",
	})
}

func TeardownDevEnvironment(t *testing.T) {
	terraform.Destroy(t, &terraform.Options{
		TerraformDir: "../infra/app/envs/dev/",
	})
}

func GetCurrentCommitHash(t *testing.T) string {
	return shell.RunCommandAndGetOutput(t, shell.Command{
		Command:    "git",
		Args:       []string{"rev-parse", "HEAD"},
		WorkingDir: "./",
	})
}
