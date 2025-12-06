# Azure Workbook Deployment

## Overview

This directory contains the Bicep template and workbook definition for deploying the **AI Services Observability** workbook to Azure.

## Files

- **`workbook.bicep`** - Bicep template for deploying the Azure Workbook resource
- **`workbook-template.json`** - Workbook definition containing visualizations and queries
- **`workbook.json`** - Compiled ARM template (generated from `workbook.bicep`)

## Workbook Features

The AI Services Observability workbook provides the following visualizations:

### 1. Request Volume
- Time-series chart showing request volume over time (5-minute bins)
- Tracks total number of requests to AI services

### 2. Latency Percentiles
- Multi-line chart displaying P50, P90, P95, and P99 latency metrics
- Helps identify performance issues and outliers
- Measured in milliseconds

### 3. Operations Breakdown
- Table view showing breakdown by operation name
- Includes:
  - Total request count
  - Average duration
  - Success rate (%) with visual indicators
    - Green: ≥95% success rate
    - Yellow: 80-95% success rate
    - Red: <80% success rate

### 4. Content Safety Logs
- Table displaying Content Safety analysis logs
- Shows timestamp, severity level, message, and operation ID
- Filters for logs starting with "ContentSafety"

## Deployment

### Prerequisites

- Azure CLI installed
- Bicep CLI installed (or use Azure CLI with Bicep support)
- An existing Log Analytics workspace
- Appropriate permissions to create workbooks in the resource group

### Deploy the Workbook

```powershell
# Set variables
$resourceGroup = "rg-zavastorefront-dev-centralus"
$workspaceId = "/subscriptions/<subscription-id>/resourceGroups/$resourceGroup/providers/Microsoft.OperationalInsights/workspaces/law-zavastorefront-dev-centralus"
$location = "centralus"

# Deploy using Azure CLI
az deployment group create `
  --resource-group $resourceGroup `
  --template-file infra/workbook.bicep `
  --parameters logAnalyticsWorkspaceId=$workspaceId `
  --parameters location=$location
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `workbookName` | string | No | Internal name for the workbook (default: "AI Services Observability") |
| `workbookDisplayName` | string | No | Display name shown in Azure Portal (default: "AI Services Observability") |
| `location` | string | No | Azure region (default: resource group location) |
| `logAnalyticsWorkspaceId` | string | Yes | Resource ID of the Log Analytics workspace |
| `tags` | object | No | Tags to apply to the workbook resource |

## Customizing the Workbook

To customize the queries or visualizations:

1. Edit `workbook-template.json`
2. Modify the KQL queries in the `query` fields
3. Update visualization settings in the `chartSettings` or `gridSettings` objects
4. Redeploy using the Bicep template

### Example: Adding a New Query

Add a new item to the `items` array in `workbook-template.json`:

```json
{
  "type": 3,
  "content": {
    "version": "KqlItem/1.0",
    "query": "AppExceptions\n| where TimeGenerated {TimeRange}\n| summarize ExceptionCount = count() by bin(TimeGenerated, 5m)\n| order by TimeGenerated asc",
    "size": 0,
    "title": "Exception Rate",
    "timeContextFromParameter": "TimeRange",
    "queryType": 0,
    "resourceType": "microsoft.operationalinsights/workspaces",
    "visualization": "timechart"
  },
  "name": "query - exceptions"
}
```

## Accessing the Workbook

After deployment:

1. Navigate to the Azure Portal
2. Go to **Monitor** > **Workbooks**
3. Select the **AI Services** category
4. Open **AI Services Observability**

Alternatively, access directly via the resource ID output from the deployment.

## Data Sources

The workbook queries the following Application Insights tables:

- **`AppRequests`** - HTTP requests to the application
- **`AppTraces`** - Application trace logs (including Content Safety logs)

Ensure your Application Insights is configured to send data to the Log Analytics workspace specified in the deployment.

## Troubleshooting

### No Data Appearing

1. **Check Time Range**: Adjust the time range parameter in the workbook
2. **Verify Data Source**: Ensure Application Insights is connected to the Log Analytics workspace
3. **Check Query Scope**: Verify the workspace ID is correct
4. **Diagnostic Settings**: Ensure diagnostic settings are enabled for AI services

### Query Errors

- Ensure the Log Analytics workspace has the required tables (`AppRequests`, `AppTraces`)
- Verify the workspace ID parameter is the full resource ID, not just the workspace name
- Check that you have read permissions on the Log Analytics workspace

## Related Resources

- [Azure Workbooks Documentation](https://learn.microsoft.com/azure/azure-monitor/visualize/workbooks-overview)
- [KQL Query Language Reference](https://learn.microsoft.com/azure/data-explorer/kusto/query/)
- [Application Insights Data Model](https://learn.microsoft.com/azure/azure-monitor/app/data-model-complete)
