package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"testing"
)

// Test the Terraform module in examples/complete using Terratest
func TestExamplesComplete(t *testing.T)  {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../../examples/complete",
		Upgrade: true,
		VarFiles: []string{"fixtures.us-east-1.tfvars"},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApplyAndIdempotent(t, terraformOptions)

	regionEnvVar := terraformOptions.EnvVars["region"]
	expectedDashboardUrlFormat := "https://console.aws.amazon.com/cloudwatch/home?region=%s#dashboards:name=%s"

	// Assume '-' for delimiter
	expectedCombinedDashboardUrl := fmt.Sprintf(expectedDashboardUrlFormat, regionEnvVar, "cis-benchmark-statistics-combined")
	expectedIndividualDashboardUrl := fmt.Sprintf(expectedDashboardUrlFormat, regionEnvVar, "cis-benchmark-statistics-individual")

	combinedDashboardUrl := terraform.Output(t, terraformOptions, "dashboard_combined")
	individualDashboardUrl := terraform.Output(t, terraformOptions, "dashboard_individual")

	assert.Contains(t, combinedDashboardUrl, expectedCombinedDashboardUrl)
	assert.Contains(t, individualDashboardUrl, expectedIndividualDashboardUrl)
}
