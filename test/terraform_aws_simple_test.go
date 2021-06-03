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

	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sqs"
)

func TestTerraformSimpleExample(t *testing.T) {
	t.Parallel()

	region := os.Getenv("AWS_DEFAULT_REGION")
	require.NotEmpty(t, region, "missing environment variable AWS_DEFAULT_REGION")

	testName := fmt.Sprintf("terratest-sqs-queue-simple-%s", strings.ToLower(random.UniqueId()))

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

	queueURL := terraform.Output(t, terraformOptions, "queue_url")

	s := session.Must(session.NewSession())

	c := sqs.New(s, aws.NewConfig().WithRegion(region))

	messageBody := "test-"+strings.ToLower(random.UniqueId())

	_, sendMessageError := c.SendMessage(&sqs.SendMessageInput{
		QueueUrl:    aws.String(queueURL),
		MessageBody: aws.String(messageBody),
	})

	require.NoError(t, sendMessageError)

	waitTimeSeconds := int64(5)

	receiveMessageOutput, recieveMessageError := c.ReceiveMessage(&sqs.ReceiveMessageInput{
		QueueUrl:        aws.String(queueURL),
		WaitTimeSeconds: aws.Int64(waitTimeSeconds),
	})

	require.NoError(t, recieveMessageError)

	require.Len(t, receiveMessageOutput.Messages, 1)
	msg := receiveMessageOutput.Messages[0]
	require.NotNil(t, msg)
	require.Equal(t, aws.StringValue(msg.Body), messageBody, "input and output messages are not equal")
}
