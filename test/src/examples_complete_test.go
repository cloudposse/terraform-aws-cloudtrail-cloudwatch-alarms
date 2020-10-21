package test

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"testing"
)

// Test the Terraform module in examples/complete using Terratest
func TestExamplesComplete(t *testing.T)  {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/complete",
		TerraformBinary: "terraform",
		//Upgrade: true,
		VarFiles: []string{"fixtures.us-east-1.tfvars"},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApplyAndIdempotent(t, terraformOptions)


	mainDashboardUrl := terraform.Output(t, terraformOptions, "")
	expectedMainDashboardUrlPrefix := "https://console.aws.amazon.com/cloudwatch/home?region="

	assert.Contains(t, mainDashboardUrl, expectedMainDashboardUrlPrefix)
}