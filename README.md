# Azure DevTest Labs Infrastructure

A comprehensive Terraform-based infrastructure solution for provisioning Azure DevTest Labs with both Linux and Windows developer desktops. This solution enables developers to work in isolated VM environments with pre-configured artifacts and tools.

## 🎯 Purpose

This infrastructure creates a scalable DevTest Lab environment that provides:
- **Linux Developer VMs**: Ubuntu-based VMs for application development and containerized workloads
- **Windows Developer VMs**: Windows 11 VMs for desktop application development and testing
- **Artifact Management**: Pre-built artifacts for common development tools and agents
- **Secure Environment**: Integrated Key Vault for credential management and Log Analytics for monitoring

## 🏗️ Architecture Overview

### Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure DevTest Lab                       │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────────────────────┐ │
│  │   Linux VMs     │    │        Windows VMs              │ │
│  │  (Ubuntu 22.04) │    │      (Windows 11 Pro)          │ │
│  │                 │    │                                 │ │
│  │ • Docker        │    │ • Visual Studio Code           │ │
│  │ • Azure Monitor │    │ • Azure Monitor Agent          │ │
│  │ • DevOps Agent  │    │ • PowerShell                   │ │
│  └─────────────────┘    └─────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                Supporting Infrastructure                    │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ Key Vault   │  │ Log Analytics│  │  Resource Group     │ │
│  │             │  │  Workspace   │  │                     │ │
│  │ • VM Secrets│  │ • Monitoring │  │ • Centralized Mgmt  │ │
│  │ • RBAC      │  │ • Container  │  │ • Tagging           │ │
│  │ • Encryption│  │   Insights   │  │ • Lifecycle         │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (v2.0+)
- [Terraform](https://www.terraform.io/downloads.html) (v1.0+)
- [Azure Developer CLI](https://aka.ms/azd-install) (for azd workflows)
- Azure Subscription with Contributor role

## 🚀 Quick Start

### Using Azure Developer CLI (Recommended)

```bash
# Authenticate with Azure
azd auth login

# Initialize the project
azd init

# Provision infrastructure and deploy
azd up

# Clean up resources when done
azd down
```

### Using Terraform Directly

```bash
# Initialize Terraform
cd infra
terraform init

# Plan the deployment
terraform plan -var-file="main.tfvars.json"

# Apply the configuration
terraform apply -var-file="main.tfvars.json"

# Destroy when done
terraform destroy -var-file="main.tfvars.json"
```

## 🏢 Infrastructure Components

### 1. Resource Group
- **Purpose**: Centralized management of all resources
- **Naming**: `rg-dtl-{environment}-{location}`
- **Location**: Configurable (default: Switzerland North)

### 2. Azure DevTest Lab
- **Purpose**: Managed VM environment with cost controls and policies
- **Features**:
  - Automatic shutdown policies
  - Cost management
  - Artifact repository
  - Virtual network integration
- **Naming**: `dtl-dtl-{environment}-{location}`

### 3. Virtual Machines

#### Linux VMs
- **OS**: Ubuntu 22.04 LTS (minimal)
- **Size**: Standard_D4as_v5 (dev) / Standard_D8as_v5 (staging)
- **Storage**: Standard SSD (dev) / Premium SSD (staging)
- **Features**:
  - Docker support
  - Azure Monitor Agent
  - Azure DevOps Agent capability

#### Windows VMs
- **OS**: Windows 11 Pro (24H2)
- **Size**: Standard_D4as_v5 (dev) / Standard_D8as_v5 (staging)
- **Storage**: Standard SSD (dev) / Premium SSD (staging)
- **Features**:
  - Visual Studio Code ready
  - PowerShell 7+
  - Azure Monitor Agent

### 4. Key Vault
- **Purpose**: Secure storage of VM credentials and secrets
- **Features**:
  - RBAC authorization
  - Soft delete protection
  - Network access controls
  - Integration with VMs for password management

### 5. Log Analytics Workspace
- **Purpose**: Centralized monitoring and logging
- **Features**:
  - Container Insights solution
  - VM performance monitoring
  - Custom log collection

## 🔧 Terraform Modules

### DevTest Lab Module (`modules/devtestlab/`)
Creates and configures the Azure DevTest Lab environment.

**Key Features**:
- Lab storage type configuration (Standard/Premium)
- Virtual network setup with subnet overrides
- Announcement banner configuration
- Support contact information

**Variables**:
- `lab_name`: Name of the DevTest Lab
- `lab_storage_type`: Storage type (Standard/Premium)
- `announcement`: Lab announcement configuration
- `subnet_overrides`: Network configuration

### DevTest Lab VM Module (`modules/devtestlab_vm/`)
Deploys virtual machines within the DevTest Lab.

**Key Features**:
- Automatic password generation and Key Vault storage
- Gallery image reference support
- Artifact installation capability
- Log Analytics integration

**Variables**:
- `vm_name`: Virtual machine name
- `gallery_image_reference`: OS image configuration
- `vm_size`: VM size/SKU
- `artifacts`: List of artifacts to install

### Key Vault Module (`modules/key_vault/`)
Manages Azure Key Vault for secure credential storage.

**Key Features**:
- RBAC-based access control
- Network access policies
- Soft delete and purge protection
- Integration with Log Analytics

### Log Analytics Workspace Module (`modules/log_analytics_workspace/`)
Sets up centralized logging and monitoring.

**Key Features**:
- Solution installation (Container Insights)
- Configurable retention periods
- Workspace SKU management

### Storage Account Module (`modules/storage_account/`)
Provides storage for artifacts and VM images (currently commented out).

## 🎨 Available Artifacts

### Linux Artifacts
1. **Azure Monitor Agent (AMA)**
   - Installs latest Azure Monitor Agent for Linux
   - Enables VM monitoring and logging
   - File: `artifacts/ama-installer-linux/`

2. **Azure DevOps Agent**
   - Self-hosted agent for CI/CD pipelines
   - Configurable organization, PAT, and pool settings
   - File: `artifacts/linux-ado-agent-installer/`

### Windows Artifacts
1. **Azure Monitor Agent (AMA)**
   - Silent installation of Azure Monitor Agent for Windows
   - x64 architecture support
   - File: `artifacts/ama-installer-windows/`

## ⚙️ Configuration

### Environment Variables
The solution supports multiple environments with different configurations:

**Development Environment**:
- Smaller VM sizes (Standard_D4as_v5)
- Standard SSD storage
- Cost-optimized settings

**Staging Environment**:
- Larger VM sizes (Standard_D8as_v5)
- Premium SSD storage
- Production-like performance

### Customization Options

#### VM Configuration
```hcl
# Adjust VM counts
linux_vm_count = 2
windows_vm_count = 3

# Customize VM sizes
vm_size = "Standard_D8as_v5"

# Modify storage types
storage_type = "PremiumSSD"
```

#### Lab Settings
```hcl
# Lab announcement
dtl_announcement = {
  enabled  = "Enabled"
  title    = "Development Lab"
  markdown = "Please shut down VMs when not in use"
}

# Storage configuration
dtl_storage_type = "Premium"
```

## 🔄 CI/CD Integration

### GitHub Actions Workflow
The repository includes a GitHub Actions workflow (`.github/workflows/azure-dev.yml`) that:
- Automatically provisions infrastructure on commits to main
- Uses Azure Developer CLI for deployment
- Supports both manual and automatic triggers
- Integrates with Azure RBAC for secure deployments

### Deployment Pipeline
1. **Checkout**: Retrieves source code
2. **Install azd**: Sets up Azure Developer CLI
3. **Authenticate**: Logs into Azure using service principal
4. **Provision**: Deploys infrastructure using Terraform
5. **Deploy**: Configures applications and artifacts

## 📊 Monitoring and Management

### Cost Management
- Automatic VM shutdown policies
- Lab-level cost controls
- Resource tagging for cost allocation

### Security
- Key Vault integration for credential management
- RBAC-based access control
- Network security groups
- Encrypted storage

### Monitoring
- Log Analytics workspace integration
- Container Insights for Docker workloads
- VM performance metrics
- Custom log collection

## 🛠️ Troubleshooting

### Common Issues

1. **VM Creation Fails**
   - Check Key Vault permissions
   - Verify subnet configuration
   - Ensure sufficient quota

2. **Artifact Installation Issues**
   - Validate artifact JSON syntax
   - Check network connectivity
   - Review VM logs

3. **Authentication Problems**
   - Verify service principal permissions
   - Check Azure CLI login status
   - Validate subscription access

### Support Resources
- [Azure DevTest Labs Documentation](https://docs.microsoft.com/en-us/azure/devtest-labs/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Developer CLI](https://docs.microsoft.com/en-us/azure/developer/azure-developer-cli/)

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.


