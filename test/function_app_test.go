package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformAzureFunctionAppExample(t *testing.T) {
	t.Parallel()

	// subscriptionID is overridden by the environment variable "ARM_SUBSCRIPTION_ID"
	subscriptionID := ""

	// website::tag::1:: Configure Terraform setting up a path to Terraform code.
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/function-app-example",
	}
	// website::tag::5:: At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// website::tag::2:: Run `terraform init` and `terraform apply`. Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// website::tag::3:: Run `terraform output` to get the values of output variables
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	appName := terraform.Output(t, terraformOptions, "function_app_name")

	appId := terraform.Output(t, terraformOptions, "function_app_id")
	appDefaultHostName := terraform.Output(t, terraformOptions, "default_hostname")
	appKind := terraform.Output(t, terraformOptions, "function_app_kind")

	storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
	storageAccountTier := terraform.Output(t, terraformOptions, "storage_account_account_tier")
	storageAccountKind := terraform.Output(t, terraformOptions, "storage_account_account_kind")

	// website::tag::4:: Assert
	assert.True(t, azure.AppExists(t, appName, resourceGroupName, ""))
	site := azure.GetAppService(t, appName, resourceGroupName, "")

	assert.Equal(t, appId, *site.ID)
	assert.Equal(t, appDefaultHostName, *site.DefaultHostName)
	assert.Equal(t, appKind, *site.Kind)

	assert.NotEmpty(t, *site.OutboundIPAddresses)
	assert.Equal(t, "Running", *site.State)

	// website::tag::4:: Verify storage account properties and ensure it matches the output.
	storageAccountExists := azure.StorageAccountExists(t, storageAccountName, resourceGroupName, subscriptionID)
	assert.True(t, storageAccountExists, "storage account does not exist")

	accountKind := azure.GetStorageAccountKind(t, storageAccountName, resourceGroupName, subscriptionID)
	assert.Equal(t, storageAccountKind, accountKind, "storage account kind mismatch")

	skuTier := azure.GetStorageAccountSkuTier(t, storageAccountName, resourceGroupName, subscriptionID)
	assert.Equal(t, storageAccountTier, skuTier, "sku tier mismatch")
}
