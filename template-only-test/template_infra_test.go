package test

import (
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

var projectName = os.Getenv("PROJECT_NAME")
var imageTag = os.Getenv("IMAGE_TAG")

func TestEndToEnd(t *testing.T) {
	defer TeardownAccount(t)
	SetUpProject(t, projectName)
	t.Run("SetUpAccount", SetUpAccount)
	t.Run("ValidateAccount", ValidateAccount)
	t.Run("Network", SubtestNetwork)
}

func ValidateAccount(t *testing.T) {
	projectName := projectName
	accountId := "533267424629"
	region := "us-east-1"
	ValidateAccountBackend(t, region, projectName)
	ValidateGithubActionsAuth(t, accountId, projectName)
}

func SubtestNetwork(t *testing.T) {
	defer TeardownNetwork(t)
	t.Run("SetUpNetwork", SetUpNetwork)
	t.Run("BuildRepository", SubtestBuildRepository)
}

func SubtestBuildRepository(t *testing.T) {
	defer TeardownBuildRepository(t)
	t.Run("SetUpBuildRepository", SetUpBuildRepository)
	t.Run("ValidateBuildRepository", ValidateBuildRepository)
	t.Run("Service", SubtestDevEnvironment)
}

func SubtestDevEnvironment(t *testing.T) {
	defer TeardownDevEnvironment(t)
	t.Run("SetUpDevEnvironment", SetUpDevEnvironment)
	t.Run("ValidateDevEnvironment", ValidateDevEnvironment)
}

func SetUpProject(t *testing.T, projectName string) {
	fmt.Println("::group::Configuring project")
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "set-up-project"},
		WorkingDir: "../",
	})
	fmt.Println("::endgroup::")
}

func SetUpAccount(t *testing.T) {
	fmt.Println("::group::Setting up account")
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"infra-set-up-account", "ACCOUNT_NAME=dev"},
		WorkingDir: "../",
	})
	fmt.Println("::endgroup::")
}

func SetUpNetwork(t *testing.T) {
	fmt.Println("::group::Creating network resources")
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"infra-configure-network", "NETWORK_NAME=dev"},
		WorkingDir: "../",
	})
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"infra-update-network", "NETWORK_NAME=dev"},
		Env:        map[string]string{"TF_CLI_ARGS_apply": "-input=false -auto-approve"},
		WorkingDir: "../",
	})
	fmt.Println("::endgroup::")
}

func SetUpBuildRepository(t *testing.T) {
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
	fmt.Println("::group::Creating web service dev environment")
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"infra-configure-app-service", "APP_NAME=app", "ENVIRONMENT=dev"},
		WorkingDir: "../",
	})

	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"infra-update-app-service", "APP_NAME=app", "ENVIRONMENT=dev"},
		Env:        map[string]string{"TF_CLI_ARGS_apply": fmt.Sprintf("-input=false -auto-approve -var=image_tag=%s", imageTag)},
		WorkingDir: "../",
	})
	fmt.Println("::endgroup::")
}

func ValidateAccountBackend(t *testing.T, region string, projectName string) {
	fmt.Println("::group::Validating terraform backend for account")
	expectedTfStateBucket := fmt.Sprintf("%s-533267424629-%s-tf", projectName, region)
	expectedTfStateKey := "infra/account.tfstate"
	aws.AssertS3BucketExists(t, region, expectedTfStateBucket)
	_, err := aws.GetS3ObjectContentsE(t, region, expectedTfStateBucket, expectedTfStateKey)
	assert.NoError(t, err, fmt.Sprintf("Failed to get tfstate object from tfstate bucket %s", expectedTfStateBucket))
	fmt.Println("::endgroup::")
}

func ValidateGithubActionsAuth(t *testing.T, accountId string, projectName string) {
	fmt.Println("::group::Validating that GitHub actions can authenticate with AWS account")
	// Check that GitHub Actions can authenticate with AWS
	err := shell.RunCommandE(t, shell.Command{
		Command:    "make",
		Args:       []string{"infra-check-github-actions-auth", "ACCOUNT_NAME=dev"},
		WorkingDir: "../",
	})
	assert.NoError(t, err, "GitHub actions failed to authenticate")
	fmt.Println("::endgroup::")
}

func ValidateBuildRepository(t *testing.T) {
	fmt.Println("::group::Validating ability to publish build artifacts to build repository")

	err := shell.RunCommandE(t, shell.Command{
		Command:    "make",
		Args:       []string{"release-build", "APP_NAME=app", fmt.Sprintf("IMAGE_TAG=%s", imageTag)},
		WorkingDir: "../",
	})
	assert.NoError(t, err, "Could not build release")

	err = shell.RunCommandE(t, shell.Command{
		Command:    "make",
		Args:       []string{"release-publish", "APP_NAME=app", fmt.Sprintf("IMAGE_TAG=%s", imageTag)},
		WorkingDir: "../",
	})
	assert.NoError(t, err, "Could not publish release")

	fmt.Println("::endgroup::")
}

func ValidateDevEnvironment(t *testing.T) {
	fmt.Println("::group::Validating ability to call web service endpoint")

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
	// Not checking the /health endpoint as we don't deploy the database for
	// this testing, so that endpoint will fail as currently coded
	http_helper.HttpGetWithRetryWithCustomValidation(t, serviceEndpoint, nil, 10, 3*time.Second, func(responseStatus int, responseBody string) bool {
		return responseStatus == 200
	})

	// Hit feature flags endpoint to make sure Evidently integration is working
	featureFlagsEndpoint := fmt.Sprintf("%s/feature-flags", serviceEndpoint)
	http_helper.HttpGetWithRetryWithCustomValidation(t, featureFlagsEndpoint, nil, 10, 3*time.Second, func(responseStatus int, responseBody string) bool {
		return responseStatus == 200
	})

	fmt.Println("::endgroup::")
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

func TeardownNetwork(t *testing.T) {
	fmt.Println("::group::Destroying network resources")
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "destroy-network"},
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
