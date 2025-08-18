# Troubleshooting Guide for Template Infra

## Template CI Infra Checks fails on main

If the [Template CI Infra Checks (template-only-ci-infra.yml)](https://github.com/navapbc/template-infra/actions/workflows/template-only-ci-infra.yml) workflow fails on the main branch and there isn’t a bug in the code, it may mean that a prior run of the workflow did not properly clean up account resources.

### Preventing the problem from getting worse

If you notice Template CI Infra Checks failing on main, tell people to pause on doing anything that would trigger a Template CI Infra Check run, since further runs will just create more issues you have to look into and more things you have to clean up.

Things that trigger Template CI Infra Checks runs include:

* Pushes to main branch  
* Opening PRs or updating PRs with new commits on template-infra

### Diagnosing the immediate problem

Look in the GitHub logs for the Template CI Infra check that failed. The logs are very long and therefore are collapsed into groups.

Errors that may indicate a problem with cleanup include:

* “OIDC provider already exists” during the SetUpAccount step  
* “IAM role already exists” during the SetUpDevEnvironment step  
* “SNS topic already exists” during the SetUpDevEnvironment step

### Diagnosing the root cause

If you have good reason to believe this is a one time thing, then you can skip this step and proceed to clean up the AWS account to unblock the Template CI Infra Checks workflow. Otherwise, it is important to find out what caused the test to not properly clean up and fix that first so that you don’t end up repeating the problem.

Look at the GitHub logs for previous runs of the Template CI Infra Checks workflow that also failed, starting from the one you were initially looking into.

Look in the following Teardown\* steps for errors:

* TeardownAccount  
* TeardownBuildRepository  
* TeardownDevEnvironment

Causes for errors in these steps may include:

* Inability to delete non-empty buckets. In order to delete non-empty buckets, you first need to set force\_destroy \= true and prevent\_destroy \= false for the bucket and run a terraform apply before running terraform destroy.  
* Bugs in the template\_infra\_test.go file  
* Bugs in template-only-bin/destroy-\* scripts

### Clean up the AWS account

Login to the [nava-platform AWS account](https://nava-platform.signin.aws.amazon.com/console) and check for the following to clean up:

* [ECS clusters](https://us-east-1.console.aws.amazon.com/ecs/v2/getStarted?region=us-east-1) for the service  
* [Load balancers](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#LoadBalancers:) for the service  
* [SNS topics](https://us-east-1.console.aws.amazon.com/sns/v3/home?region=us-east-1#/homepage) for monitoring alerts  
* [IAM roles](https://us-east-1.console.aws.amazon.com/iamv2/home?region=us-east-1#/roles) for GitHub actions, the service, and others  
* [S3 buckets](https://s3.console.aws.amazon.com/s3/get-started?region=us-east-1) for terraform state file, terraform logs, and load balancer access logs  
* [DynamoDB tables](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#service) for terraform state locks  
* [Identity providers](https://us-east-1.console.aws.amazon.com/iamv2/home?region=us-east-1#/identity_providers) for the GitHub OIDC provider

Note: The Template CI Infra does not currently spin up any databases.

Note: Loren has a branch called `lorenyu/clean` with two scripts that you can use:

* `template-only-bin/clean-account.sh`  
* `template-only-bin/destroy-vpc.sh`

### Verify solution

Re-run Template CI Infra Checks on main branch

## Platform test repo(s) do not have the latest changes from template-infra

If the platform test repo does not have the latest changes from template-infra check the infra template’s [Template Deploy](https://github.com/navapbc/template-infra/actions/workflows/template-only-cd.yml) workflow to see if there was any failure in deploying the template to the platform-test, platform-test-flask, or platform-test-nextjs repos.

### Failure due to merge conflict with files that have changed on the project

If the Template Deploy failed during the “git apply” command with a “patch does not apply” error, it probably means that there was a merge conflict and you will have to apply the change manually. This is because template-infra has files that will have changed on the platform test repos, and therefore a patch in those files might not apply cleanly. Files that might cause merge conflicts include:

* [.github/workflows/cd-app.yml](https://github.com/navapbc/template-infra/blob/main/.github/workflows/cd-app.yml#L7-L14) – push trigger is commented out in template-infra but uncommented in platform-test\* repos  
* [.github/workflows/ci-infra-service.yml](https://github.com/navapbc/template-infra/blob/main/.github/workflows/ci-infra-service.yml#L4-L16) – push trigger is commented out in template-infra but uncommented in platform-test\* repos  
* [infra/project-config/main.tf](https://github.com/navapbc/template-infra/blob/main/infra/project-config/main.tf) – placeholders in template-infra’s version will be replaced with actual values for the platform-test\* repos  
* [infra/app/app-config/main.tf](https://github.com/navapbc/template-infra/blob/main/infra/app/app-config/main.tf#L6) – on platform-test and platform-test-flask (but not platform-test-nextjs), has\_database will be set to true, but it defaults to false in template-infra

### Failure due to bugs in update-template.sh script

It’s also possible that there is a failure in the [update-template.sh script](https://github.com/navapbc/template-infra/blob/main/template-only-bin/update-template.sh). If so, make sure to fix the bug and make sure that all changes from the templates have been propagated to the platform test repos so that they stay in sync with the templates and so that future changes can continue to propagate successfully.

### Deploy template changes to platform test repos

Sometimes changes to templates need to be manually applied to the platform test repos ([platform-test](https://github.com/navapbc/platform-test), [platform-test-flask](https://github.com/navapbc/platform-test-flask), [platform-test-nextjs](https://github.com/navapbc/platform-test-nextjs)).

Broadly speaking there are three methods to manually update the platform test repos from the template:

Step 0\. First, make sure you’re on the main branch of each repo and that you pull the latest changes of the template and of the platform test repo:

```bash
platform-test$ git checkout main
platform-test@main$ git pull
template-infra$ git checkout main
template-infra@main$ git pull
```

#### **Method 1: Try running update-template.sh again and see what fails**

Run a version of template-infra/template-only-bin/update-template.sh that you have downloaded locally from the platform-test repo’s root directory

```bash
platform-test@main$ <path/to/template-infra>/template-only-bin/update-template.sh
```

If it fails due to a merge conflict, it will indicate which file(s) it fails on. The patch will still live in a newly checked out template-infra folder in \`./template-infra/update.patch\`. You can re-apply this patch, excluding the failed files:

```bash
platform-test@main$ git apply template-infra/update.patch --exclude=<excluded-path>
```

If that succeeds, you can then manually apply the changes in the excluded file by copying over the file and examining the diff and updating accordingly. 

Once you’re done, note that the .template-version file will be updated the latest commit hash of template-infra’s main branch.

#### **Method 2: Run install-template.sh again and manually inspect the diff**

You can run through the installation instructions again:

```bash
platform-test@main$ curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/download-and-install-template.sh | bash -s
```

Then manually inspect the diff to make sure you don’t revert things like the uncommented blocks in cd-app.yml or ci-infra-service.yml or the filled in project-config/main.tf file.

**Deleted files:** This method will not properly handle deleted files or renamed files. You will need to manually remove those.

Once you’re done, note that the .template-version file will be updated with the latest commit hash of template-infra’s main branch.

#### **Method 3: Manually copy over the changes**

This method involves manually viewing the changed/renamed/moved files and manually copying the changes over.

Once you’re done, update the .template-version file with the latest commit hash of template-infra’s main branch.

```bash
platform-test@main$ cd template-infra
platform-test@main$ TEMPLATE_VERSION=$(git rev-parse HEAD)
platform-test@main$ cd ..
platform-test@main$ echo "$TEMPLATE_VERSION" > .template-version
```
