package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/shell"
)

// An example of how to test the simple Terraform module in examples/terraform-basic-example using Terratest.
func TestAccountSetup(t *testing.T) {
	t.Parallel()

	defer shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "destroy-account"},
		WorkingDir: "../",
	})

	shell.RunCommand(t, shell.Command{
		Command:    "make",
		Args:       []string{"-f", "template-only.mak", "bootstrap-account"},
		WorkingDir: "../",
	})
}
