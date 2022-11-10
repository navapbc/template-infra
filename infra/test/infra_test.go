package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestDev(t *testing.T) {
	BuildAndPublish(t)

	uniqueId := strings.ToLower(random.UniqueId())
	workspaceName := fmt.Sprintf("t-%s", uniqueId)
	imageTag := shell.RunCommandAndGetOutput(t, shell.Command{
		Command:    "git",
		Args:       []string{"rev-parse", "HEAD"},
		WorkingDir: "./",
	})
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../app/envs/dev/",
		Vars: map[string]interface{}{
			"image_tag": imageTag,
		},
	})

	defer DestroyDevEnvironmentAndWorkspace(t, terraformOptions, workspaceName)
	CreateDevEnvironmentInWorkspace(t, terraformOptions, workspaceName)
	WaitForServiceToBeStable(t, workspaceName)
	RunEndToEndTests(t, terraformOptions)
}

func BuildAndPublish(t *testing.T) {
	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"release-build"},
		WorkingDir: "../../",
	})

	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"release-publish"},
		WorkingDir: "../../",
	})
}

func CreateDevEnvironmentInWorkspace(t *testing.T, terraformOptions *terraform.Options, workspaceName string) {
	terraform.WorkspaceSelectOrNew(t, terraformOptions, workspaceName)
	terraform.InitAndApply(t, terraformOptions)
}

func WaitForServiceToBeStable(t *testing.T, workspaceName string) {
	appName := "app"
	environmentName := "dev"
	serviceName := fmt.Sprintf("%s-%s-%s", workspaceName, appName, environmentName)
	shell.RunCommand(t, shell.Command{
		Command:    "aws",
		Args:       []string{"ecs", "wait", "services-stable", "--cluster", serviceName, "--services", serviceName},
		WorkingDir: "../../",
	})
}

func RunEndToEndTests(t *testing.T, terraformOptions *terraform.Options) {
	serviceEndpoint := terraform.Output(t, terraformOptions, "service_endpoint")
	http_helper.HttpGetWithRetry(t, serviceEndpoint, nil, 200, "Hello, World!", 5, 1*time.Second)
}

func DestroyDevEnvironmentAndWorkspace(t *testing.T, terraformOptions *terraform.Options, workspaceName string) {
	terraform.Destroy(t, terraformOptions)
	terraform.WorkspaceDelete(t, terraformOptions, workspaceName)
}
