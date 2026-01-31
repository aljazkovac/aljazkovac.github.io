# Azure DevOps Knowledge Base

An Azure-related knowledge base. Includes general knowledge, problems and solutions, as well as useful resources.

TODO:

- Write about any topic you encounter in your daily work! Do NOT reveal any Caspeco-related configuration!
- Write about private DNS zones and Redis cache (primarily in Redis cache section, cross reference in Networking & Security)
- Write about private endpoints and virtual network links to private DNS zones
- Write about application insights checks from locations vs. generic check
- Write about Container Apps Environments with workload profiles
- Write about cost optimization for SQL databases?
- Write about database access: control plane vs. data plane operations + include article about adding users to databases (Azure actually makes a check to see that the user exists)

## Table of Contents

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

### Quantify performance gains for a new container app deployment

Problem description: We had performance issues with one of our deployments (a very large system with several thousand employees). We decided to make a temporary deployment and have a couple of administrators (up to 6) work against that deployment instead. How to quantify the performance improvements?

Some ideas:

1. Compare average response times / latency (server side) for the standard deployment vs. temporary deployment
2. Compare P95 or P99 response times (server side latency)
3. Compare error rates (server side)
4. Compare uptime/availability
5. Compare request count and CPU/Memory Usage
6. Compare client-side performance (browser load times)

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

#### 🔧 Problem: Connection timeout issues with Azure SQL

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

#### 📋 How-To: Control Database Access

TODO: Fix this up and add information on adding users to databases!

Azure RBAC on the Database Server:

This is crucial for control plane operations. Azure Role-Based Access Control (RBAC) at the server or resource group level dictates who can manage the Azure SQL server itself (e.g., create or delete databases, configure server settings like firewalls, backups, auditing, or Azure AD authentication).
Examples of roles here include SQL Server Contributor, SQL Security Manager, or custom roles.
Database Users (in "Security" for each database):

This is for data plane operations – controlling who can access and interact with the data within a specific database.
These users are distinct from server-level logins (in older SQL Server models) and ideally should be contained database users. Contained database users are authenticated at the database level and make the database more portable, especially when using Azure AD.
Users Correspond to Azure AD Groups:

This is a best practice. Creating database users mapped to Azure AD security groups simplifies access management significantly. Instead of managing individual user permissions in each database, you manage group memberships in Azure AD. When a user is added to or removed from the AD group, their access to the database is automatically updated.
Database Users Have Memberships (e.g., db_owner):

Assigning database users (which are mapped to AD groups) to built-in database roles (like db_owner, db_datareader, db_datawriter) or custom database roles is the standard way to grant permissions within the SQL database using T-SQL.
Your understanding and implementation correctly separate management plane (Azure RBAC) and data plane (SQL users and permissions) security, leveraging Azure AD for centralized identity management.

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
