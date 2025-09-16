# Troubleshooting Guide for Template Infra

## Template CI Infra Checks fails on main

If the [Template CI Infra Checks (template-only-ci-infra.yml)](https://github.com/navapbc/template-infra/actions/workflows/template-only-ci-infra.yml) workflow fails on the main branch and there isn't a bug in the code, it may mean that a prior run of the workflow did not properly clean up account resources.

### Preventing the problem from getting worse

If you notice Template CI Infra Checks failing on main, tell people to pause on doing anything that would trigger a Template CI Infra Check run, since further runs will just create more issues you have to look into and more things you have to clean up.

Things that trigger Template CI Infra Checks runs include:

* Pushes to main branch  
* Opening PRs or updating PRs with new commits on template-infra

### Diagnosing the immediate problem

Look in the GitHub logs for the Template CI Infra check that failed. The logs are very long and therefore are collapsed into groups.

Errors that may indicate a problem with cleanup include:

* "OIDC provider already exists" during the SetUpAccount step  
* "IAM role already exists" during the SetUpDevEnvironment step  
* "SNS topic already exists" during the SetUpDevEnvironment step

### Diagnosing the root cause

If you have good reason to believe this is a one time thing, then you can skip this step and proceed to clean up the AWS account to unblock the Template CI Infra Checks workflow. Otherwise, it is important to find out what caused the test to not properly clean up and fix that first so that you don't end up repeating the problem.

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

See :lock: [template changes fail to apply](https://navasage.atlassian.net/wiki/spaces/tss/pages/2011922659/Platform+Ecosystem#template-*-changes-fail-to-apply) for help troubleshooting this issue.
