package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
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

	t.Run("TestDevEnvironment", SubtestDevEnvironment)
}

func SubtestDevEnvironment(t *testing.T) {
	defer TeardownDevEnvironment(t)
	SetUpDevEnvironment(t)
	ValidateDevEnvironment(t)
}

func SetUpProject(t *testing.T, projectName string) {
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "set-up-project", fmt.Sprintf("PROJECT_NAME=%s", projectName)},
		WorkingDir: "../",
	})
}

func SetUpAccount(t *testing.T) {
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "set-up-account"},
		WorkingDir: "../",
	})
}

func SetUpAppBackends(t *testing.T, projectName string) {
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "set-up-app-backends", fmt.Sprintf("PROJECT_NAME=%s", projectName)},
		WorkingDir: "../",
	})
}

func SetUpBuildRepository(t *testing.T, projectName string) {
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "set-up-app-build-repository", fmt.Sprintf("PROJECT_NAME=%s", projectName)},
		WorkingDir: "../",
	})
}

func SetUpDevEnvironment(t *testing.T) {

}

func ValidateAccountBackend(t *testing.T, region string, projectName string) {
	expectedTfStateBucket := fmt.Sprintf("%s-368823044688-%s-tf-state", projectName, region)
	expectedTfStateKey := "infra/account.tfstate"
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

func ValidateAppBackends(t *testing.T) {
	// TODO
}

func ValidateBuildRepository(t *testing.T, projectName string) {
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
}

func ValidateDevEnvironment(t *testing.T) {
	// Wait for service to be stable
	appName := "app"
	environmentName := "dev"
	serviceName := fmt.Sprintf("%s-%s", appName, environmentName)
	shell.RunCommand(t, shell.Command{
		Command:    "aws",
		Args:       []string{"ecs", "wait", "services-stable", "--cluster", serviceName, "--services", serviceName},
		WorkingDir: "../../",
	})

	// Get current commit hash, which should be the one that was deployed as part of validating the build-repository
	imageTag := shell.RunCommandAndGetOutput(t, shell.Command{
		Command:    "git",
		Args:       []string{"rev-parse", "HEAD"},
		WorkingDir: "./",
	})

	// Hit the service endpoint to see if it returns status 200
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../infra/app/envs/dev/",
		Vars: map[string]interface{}{
			"image_tag": imageTag,
		},
	})
	serviceEndpoint := terraform.Output(t, terraformOptions, "service_endpoint")
	http_helper.HttpGetWithRetryWithCustomValidation(t, serviceEndpoint, nil, 5, 1*time.Second, func(responseStatus int, responseBody string) bool {
		return responseStatus == 200
	})
}

func TeardownAccount(t *testing.T) {
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "destroy-account"},
		WorkingDir: "../",
	})
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
