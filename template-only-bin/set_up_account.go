package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"regexp"
	"strings"
)

type Config struct {
	ProjectName      string
	Account          string
	GithubRepository string
}

func main() {
	config := GetConfiguration()
	SetUpAccount(config)
}

func GetConfiguration() Config {
	projectName := os.Args[1]
	account := os.Args[2]

	// Get the "org/repo" string (e.g. "navapbc/template-infra") by first
	// getting the repo URL (e.g. "git@github.com:navapbc/template-infra.git"
	// or "https://github.com/navapbc/template-infra.git"), then searching
	// for the "org/repo" string at the end of the URL
	repoUrl := RunOutput("git", "remote", "get-url", "origin")
	repoRegex := regexp.MustCompile(`([-_\w]+/[-_\w]+)(.git)?$`)
	githubRepository := repoRegex.FindStringSubmatch(repoUrl)[1]

	fmt.Println("Account configuration")
	fmt.Println("=====================")
	fmt.Printf("PROJECT_NAME=%s\n", projectName)
	fmt.Printf("ACCOUNT=%s\n", account)
	fmt.Printf("REPO_URL=%s\n", repoUrl)
	fmt.Printf("GITHUB_REPOSITORY=%s\n", githubRepository)
	fmt.Println()

	return Config{
		ProjectName:      projectName,
		Account:          account,
		GithubRepository: githubRepository,
	}
}

func SetUpAccount(config Config) {
	// Run the rest of the commands from the account directory
	os.Chdir(fmt.Sprintf("infra/accounts/%s", config.Account))

	DeployAccountResources(config.ProjectName, config.GithubRepository)
	ReconfigureTerraformBackend()
}

func DeployAccountResources(projectName, githubRepository string) {
	fmt.Println("------------------------")
	fmt.Println("Deploy account resources")
	fmt.Println("------------------------")

	// First replace the placeholders value in main.tf:
	ReplacePlaceholders("main.tf", map[string]string{
		// The project name is used to define unique names for the infrastructure
		"<PROJECT_NAME>": projectName,

		// The repository name is used to set up the GitHub OpenID Connect provider
		// in AWS which allows GitHub Actions to authenticate with our AWS account
		// when called from our repository only.
		"<GITHUB_REPOSITORY>": githubRepository,
	})

	// Create the infrastructure for the terraform backend such as the S3 bucket
	// for storing tfstate files and the DynamoDB table for tfstate locks.
	Run("terraform", "init")
	Run("terraform", "apply", "-auto-approve")
}

func ReconfigureTerraformBackend() {

	fmt.Println("-------------------------------------------")
	fmt.Println("Reconfigure Terraform backend to S3 backend")
	fmt.Println("-------------------------------------------")

	// Get the name of the S3 bucket that was created to store the tf state
	// and the name of the DynamoDB table that was created for tf state locks.
	// This will be used to configure the S3 backend in main.tf
	tfStateBucketName := RunOutput("terraform", "output", "-raw", "tf_state_bucket_name")
	tfLocksTableName := RunOutput("terraform", "output", "-raw", "tf_locks_table_name")

	// Configure the S3 backend in main.tf by replacing the placeholder
	// values with the actual values from the previous step, then
	// uncomment the S3 backend block
	ReplacePlaceholders("main.tf", map[string]string{
		"<TF_STATE_BUCKET_NAME>": tfStateBucketName,
		"<TF_LOCKS_TABLE_NAME>":  tfLocksTableName,
		"#uncomment# ":           "",
	})

	// Re-initialize terraform with the new backend and copy the tfstate
	// to the new backend in S3
	Run("terraform", "init", "-force-copy")
}

func ReplacePlaceholders(filename string, replacements map[string]string) {
	file, err := os.ReadFile(filename)
	if err != nil {
		log.Fatal(err)
	}

	fileStr := string(file)
	for old, new := range replacements {
		fileStr = strings.ReplaceAll(fileStr, old, new)
	}

	os.WriteFile(filename, []byte(fileStr), 0644)
}

func Run(name string, arg ...string) {
	cmd := exec.Command(name, arg...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		log.Fatal(err)
	}
}

func RunOutput(name string, arg ...string) string {
	cmd := exec.Command(name, arg...)
	out, err := cmd.Output()
	if err != nil {
		log.Fatal(err)
	}
	return strings.TrimSpace(string(out))
}
