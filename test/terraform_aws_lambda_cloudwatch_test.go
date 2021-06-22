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

	"github.com/aws/aws-sdk-go/service/lambda"
	"github.com/stretchr/testify/require"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
)

func TestTerraformSimpleExample(t *testing.T) {
	t.Parallel()

	region := os.Getenv("AWS_DEFAULT_REGION")
	require.NotEmpty(t, region, "missing environment variable AWS_DEFAULT_REGION")

	testName := fmt.Sprintf("tt-lf-cw-trigger-%s", strings.ToLower(random.UniqueId()))

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/cloudwatch-trigger",
		Vars: map[string]interface{}{
			"test_name": testName,
			"tags": map[string]interface{}{
				"Automation": "Terraform",
				"Terratest":  "yes",
				"Test":       "TestTerraformCloudwatchTrigger",
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

	lambdaFunctionName := terraform.Output(t, terraformOptions, "lambda_function_name")
	s := session.Must(session.NewSession())

	c := lambda.New(s, aws.NewConfig().WithRegion(region))

	invokeOutput, invokeError := c.Invoke(&lambda.InvokeInput{
		FunctionName: aws.String(lambdaFunctionName),
		Payload:      []byte("{}"),
	})

	require.NoError(t, invokeError)
	payload := string(invokeOutput.Payload)
	require.Equal(t, payload, "\"hello world\"")

}
