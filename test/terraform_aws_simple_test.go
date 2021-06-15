// =================================================================
//
// Work of the U.S. Department of Defense, Defense Digital Service.
// Released as open source under the MIT License.  See LICENSE file.
//
// =================================================================

package test

import (
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"

	// "github.com/aws/aws-sdk-go/aws"
	// "github.com/aws/aws-sdk-go/aws/session"
	// "github.com/aws/aws-sdk-go/service/sqs"
)

func TestTerraformSimpleExample(t *testing.T) {
	t.Parallel()

	region := os.Getenv("AWS_DEFAULT_REGION")
	require.NotEmpty(t, region, "missing environment variable AWS_DEFAULT_REGION")

	testName := fmt.Sprintf("tt-lf-simple-%s", strings.ToLower(random.UniqueId()))

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/simple",
		Vars: map[string]interface{}{
			"test_name": testName,
			"tags": map[string]interface{}{
				"Automation": "Terraform",
				"Terratest":  "yes",
				"Test":       "TestTerraformSimpleExample",
			},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
	})

	if os.Getenv("TT_SKIP_DESTROY") != "1" {
		defer terraform.Destroy(t, terraformOptions)
	}

	terraform.InitAndApply(t, terraformOptions)

	// lambdaFunctionName := terraform.Output(t, terraformOptions, "lambda_function_name")
	// get the ip address of the instance
	publicIp := terraform.Output(t, terraformOptions, "public_ip")
	// Make an HTTP request to the instance & make sure we get back a 200 OK with expected body
	url := fmt.Sprintf("http://%s:8080", publicIp)
	http_helper.HttpGetWithRetry(t, url, nil, 200, "hello world", 30, 5*time.Second)

}
