// Parameters
param workbookName string = 'AI Services Observability'
param workbookDisplayName string = 'AI Services Observability'
param location string = resourceGroup().location
param logAnalyticsWorkspaceId string
param tags object = {}

// Generate a unique workbook ID
var workbookId = guid(resourceGroup().id, workbookName)

// Load the workbook template content
var workbookContent = loadTextContent('workbook-template.json')

resource workbook 'Microsoft.Insights/workbooks@2023-06-01' = {
  name: workbookId
  location: location
  tags: tags
  kind: 'shared'
  properties: {
    displayName: workbookDisplayName
    serializedData: workbookContent
    version: '1.0'
    sourceId: logAnalyticsWorkspaceId
    category: 'AI Services'
  }
}

output workbookId string = workbook.id
output workbookName string = workbook.name
