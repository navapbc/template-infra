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
	t.Run("TestBuildRepository", SubtestBuildRepository)
}

func ValidateAccount(t *testing.T) {
	projectName := projectName
	accountId := "368823044688"
	region := "us-east-1"
	ValidateAccountBackend(t, region, projectName)
	ValidateGithubActionsAuth(t, accountId, projectName)
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
	fmt.Println("::group::Configuring project")
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "set-up-project", fmt.Sprintf("PROJECT_NAME=%s", projectName)},
		WorkingDir: "../",
	})
	fmt.Println("::endgroup::")
}

func SetUpAccount(t *testing.T) {
	fmt.Println("::group::Setting up account")
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"infra-set-up-account", "ACCOUNT_NAME=prod"},
		WorkingDir: "../",
	})
	fmt.Println("::endgroup::")
}

func SetUpBuildRepository(t *testing.T, projectName string) {
	fmt.Println("::group::Creating build repository resources")
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"infra-configure-app-build-repository", "APP_NAME=app"},
		WorkingDir: "../",
	})
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"infra-update-app-build-repository", "APP_NAME=app"},
		Env:        map[string]string{"TF_CLI_ARGS_apply": "-input=false -auto-approve"},
		WorkingDir: "../",
	})
	fmt.Println("::endgroup::")
}

func SetUpDevEnvironment(t *testing.T) {
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"infra-configure-app-service", "APP_NAME=app", "ENVIRONMENT=dev"},
		WorkingDir: "../",
	})

	// Get current commit hash, which should be the one that was deployed as part of validating the build-repository
	imageTag := shell.RunCommandAndGetOutput(t, shell.Command{
		Command:    "git",
		Args:       []string{"rev-parse", "HEAD"},
		WorkingDir: "./",
	})

	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"infra-update-app-service", "APP_NAME=app", "ENVIRONMENT=dev"},
		Env:        map[string]string{"TF_CLI_ARGS_apply": fmt.Sprintf("-input=false -auto-approve -var=image_tag=%s", imageTag)},
		WorkingDir: "../",
	})
}

func ValidateAccountBackend(t *testing.T, region string, projectName string) {
	fmt.Println("::group::Validating terraform backend for account")
	expectedTfStateBucket := fmt.Sprintf("%s-368823044688-%s-tf", projectName, region)
	expectedTfStateKey := "infra/account.tfstate"
	aws.AssertS3BucketExists(t, region, expectedTfStateBucket)
	_, err := aws.GetS3ObjectContentsE(t, region, expectedTfStateBucket, expectedTfStateKey)
	assert.NoError(t, err, fmt.Sprintf("Failed to get tfstate object from tfstate bucket %s", expectedTfStateBucket))
	fmt.Println("::endgroup::")
}

func ValidateGithubActionsAuth(t *testing.T, accountId string, projectName string) {
	fmt.Println("::group::Validating that GitHub actions can authenticate with AWS account")
	githubActionsRole := fmt.Sprintf("arn:aws:iam::%s:role/%s-github-actions", accountId, projectName)
	// Check that GitHub Actions can authenticate with AWS
	err := shell.RunCommandE(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "check-github-actions-auth", fmt.Sprintf("GITHUB_ACTIONS_ROLE=%s", githubActionsRole)},
		WorkingDir: "../",
	})
	assert.NoError(t, err, "GitHub actions failed to authenticate")
	fmt.Println("::endgroup::")
}

func ValidateBuildRepository(t *testing.T, projectName string) {
	fmt.Println("::group::Validating ability to publish build artifacts to build repository")

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

	fmt.Println("::endgroup::")
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

	// Hit the service endpoint to see if it returns status 200
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../infra/app/service/",
	})
	serviceEndpoint := terraform.Output(t, terraformOptions, "service_endpoint")
	http_helper.HttpGetWithRetryWithCustomValidation(t, serviceEndpoint, nil, 10, 3*time.Second, func(responseStatus int, responseBody string) bool {
		return responseStatus == 200
	})
}

func TeardownAccount(t *testing.T) {
	fmt.Println("::group::Destroying account resources")
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "destroy-account"},
		WorkingDir: "../",
	})
	fmt.Println("::endgroup::")
}

func TeardownBuildRepository(t *testing.T) {
	fmt.Println("::group::Destroying build repository resources")
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "destroy-app-build-repository"},
		WorkingDir: "../",
	})
	fmt.Println("::endgroup::")
}

func TeardownDevEnvironment(t *testing.T) {
	fmt.Println("::group::Destroying dev environment resources")
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "destroy-app-service"},
		WorkingDir: "../",
	})
	fmt.Println("::endgroup::")
}

func GetCurrentCommitHash(t *testing.T) string {
	return shell.RunCommandAndGetOutput(t, shell.Command{
		Command:    "git",
		Args:       []string{"rev-parse", "HEAD"},
		WorkingDir: "./",
	})
}
