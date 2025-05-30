# Azure DevOps Knowledge Base

An Azure-related knowledge base. Includes general knowledge, problems and solutions, as well as useful resources.

TODO:
- Write about any topic you encounter in your daily work! Do NOT reveal any Caspeco-related configuration!
- Write about private DNS zones and Redis cache (primarily in Redis cache section, cross reference in Networking & Security)
- Write about private endpoints and virtual network links to private DNS zones
- Write about application insights checks from locations vs. generic check
- Write about Container Apps Environments with workload profiles
- Write about cost optimization for SQL databases?


## Table of Contents

- [Azure DevOps Knowledge Base](#azure-devops-knowledge-base)
  - [Table of Contents](#table-of-contents)
  - [Azure Resource Management](#azure-resource-management)
    - [Resource Groups](#resource-groups)
    - [Subscriptions \& Management Groups](#subscriptions--management-groups)
    - [Tags \& Governance](#tags--governance)
  - [Azure DevOps Pipelines](#azure-devops-pipelines)
    - [Build Pipelines](#build-pipelines)
    - [Release Pipelines](#release-pipelines)
    - [Service Connections](#service-connections)
    - [Variable Groups \& Secrets](#variable-groups--secrets)
  - [Infrastructure as Code (IaC)](#infrastructure-as-code-iac)
    - [Bicep](#bicep)
    - [Terraform](#terraform)
  - [Networking \& Security](#networking--security)
    - [Virtual Networks](#virtual-networks)
    - [Network Security Groups](#network-security-groups)
    - [Application Gateway \& Load Balancers](#application-gateway--load-balancers)
    - [VPN \& ExpressRoute](#vpn--expressroute)
  - [Monitoring \& Logging](#monitoring--logging)
    - [Azure Monitor](#azure-monitor)
    - [Log Analytics](#log-analytics)
    - [Application Insights](#application-insights)
    - [Alerts \& Notifications](#alerts--notifications)
  - [Container Services](#container-services)
    - [Azure Container Registry (ACR)](#azure-container-registry-acr)
    - [Azure Kubernetes Service (AKS)](#azure-kubernetes-service-aks)
    - [Container Instances](#container-instances)
  - [Database Services](#database-services)
    - [Azure SQL Database](#azure-sql-database)
    - [Cosmos DB](#cosmos-db)
    - [Redis Cache](#redis-cache)
  - [Identity \& Access Management](#identity--access-management)
    - [Azure Active Directory](#azure-active-directory)
    - [Service Principals](#service-principals)
    - [RBAC \& Permissions](#rbac--permissions)
  - [Cost Optimization](#cost-optimization)
    - [Resource Sizing](#resource-sizing)
    - [Reserved Instances](#reserved-instances)
    - [Cost Monitoring](#cost-monitoring)
  - [Troubleshooting](#troubleshooting)
    - [Common Error Messages](#common-error-messages)
      - [Error: "The subscription is not registered to use namespace"](#error-the-subscription-is-not-registered-to-use-namespace)
    - [Debugging Techniques](#debugging-techniques)
    - [Performance Issues](#performance-issues)
  - [Useful Scripts \& Commands](#useful-scripts--commands)
    - [Common Azure CLI Commands](#common-azure-cli-commands)
    - [PowerShell Snippets](#powershell-snippets)
    - [ARM Template Patterns](#arm-template-patterns)
  - [External Resources](#external-resources)
    - [Official Documentation](#official-documentation)
    - [Community Resources](#community-resources)
    - [Tools \& Extensions](#tools--extensions)
  - [Contributing to This Document](#contributing-to-this-document)
    - [Adding New Entries](#adding-new-entries)
    - [Maintenance](#maintenance)

## Azure Resource Management

### Resource Groups

### Subscriptions & Management Groups

### Tags & Governance

## Azure DevOps Pipelines

### Build Pipelines

### Release Pipelines
<!-- Add release pipeline issues here -->

### Service Connections
<!-- Add service connection issues here -->

### Variable Groups & Secrets
<!-- Add secrets management issues here -->

## Infrastructure as Code (IaC)

### Bicep
<!-- Add Bicep-related issues here -->

### Terraform
<!-- Add Terraform on Azure issues here -->

## Networking & Security

### Virtual Networks
<!-- Add VNet issues here -->

### Network Security Groups
<!-- Add NSG issues here -->

### Application Gateway & Load Balancers
<!-- Add load balancing issues here -->

### VPN & ExpressRoute
<!-- Add connectivity issues here -->

## Monitoring & Logging

### Azure Monitor
<!-- Add monitoring issues here -->

### Log Analytics
<!-- Add logging issues here -->

### Application Insights
<!-- Add APM issues here -->

### Alerts & Notifications
<!-- Add alerting issues here -->

## Container Services

### Azure Container Registry (ACR)
<!-- Add ACR issues here -->

### Azure Kubernetes Service (AKS)
<!-- Add AKS issues here -->

### Container Instances
<!-- Add ACI issues here -->

## Database Services

### Azure SQL Database
<!-- Add SQL Database issues here -->

**Problem** 

Unable to move databases into an SQL elastic pool due to mismatch in `preferredEnclaveType` property.

**Description and Solution**

I encountered this error when trying to move the databases into the sqlep-dev-ne elastic pool:

```bash
| Polling failed: the Azure API returned the following error: 
│ 
│ Status: "VBSEnclaveResourcePoolInvalidCombination" 
│ Code: "" 
│ Message: "Adding a database with 'Default' preferredEnclaveType to an elastic pool '<NAME>' with 'No' preferredEnclaveType is not supported. 
| Before adding the database to the elastic pool, ensure that the preferredEnclaveType is the same for both the database and the elastic pool. 
| More information can be found on https://aka.ms/AlwaysEncryptedEnableSecureEnclaves"
```

I ran the following to check the elastic pool configuration:

```bash
C:\Users\aljaz.kovac> az sql elastic-pool list --resource-group <NAME> --server <NAME>
```
The reply I got showed this property:
```bash
"preferredEnclaveType": null,
```

I googled around and found this github issue: 
https://github.com/hashicorp/terraform-provider-azurerm/issues/24195

It seems this issue was caused because the elastic pool was created with an older API which set the elastic pool to "null" instead of to "default".

I then ran what a user suggested there:

```bash
az sql elastic-pool update -n <NAME> -g <RG-NAME> --server <NAME> --preferred-enclave-type Default
```

This manually updated the elastic pool's problematic property to the required value. I was then able to apply my Terraform configuration and move the databases into the pool.

**Resources**

- https://github.com/hashicorp/terraform-provider-azurerm/issues/24195

### Cosmos DB
<!-- Add Cosmos DB issues here -->

### Redis Cache
<!-- Add caching issues here -->

## Identity & Access Management

### Azure Active Directory
<!-- Add AAD issues here -->

### Service Principals
<!-- Add service principal issues here -->

### RBAC & Permissions
<!-- Add permission issues here -->

## Cost Optimization

### Resource Sizing
<!-- Add sizing recommendations here -->

### Reserved Instances
<!-- Add RI strategies here -->

### Cost Monitoring
<!-- Add cost management issues here -->

## Troubleshooting

### Common Error Messages
#### Error: "The subscription is not registered to use namespace"
**Solution:**
```bash
az provider register --namespace Microsoft.ContainerService
```
**Context:** Occurs when trying to use a service for the first time

### Debugging Techniques
<!-- Add debugging approaches here -->

### Performance Issues
<!-- Add performance troubleshooting here -->

## Useful Scripts & Commands

### Common Azure CLI Commands
```bash
# List all resource groups
az group list --output table

# Get resource group details
az group show --name myResourceGroup

# Delete resource group (with confirmation)
az group delete --name myResourceGroup --yes --no-wait
```

### PowerShell Snippets
```powershell
# Connect to Azure
Connect-AzAccount

# Get all VMs in subscription
Get-AzVM | Select-Object Name, ResourceGroupName, Location
```

### ARM Template Patterns
```json
{
  "// Common ARM template patterns here"
}
```

## External Resources

### Official Documentation
- [Azure Documentation](https://docs.microsoft.com/azure/)
- [Azure DevOps Documentation](https://docs.microsoft.com/azure/devops/)

### Community Resources
- [Azure Updates](https://azure.microsoft.com/updates/)
- [Azure Blog](https://azure.microsoft.com/blog/)

### Tools & Extensions
- [Azure CLI](https://docs.microsoft.com/cli/azure/)
- [Azure PowerShell](https://docs.microsoft.com/powershell/azure/)
- [VS Code Azure Extensions](https://marketplace.visualstudio.com/search?term=azure&target=VSCode)

---

## Contributing to This Document

### Adding New Entries
1. Identify the appropriate section
2. Use the standard format (Problem/Solution/Context/Related)
3. Include code examples where applicable
4. Update the table of contents if adding new sections

### Maintenance
- Review and update solutions quarterly
- Remove outdated information
- Add new Azure services as they become relevant

**Last Updated:** [Current Date]
**Version:** 1.0