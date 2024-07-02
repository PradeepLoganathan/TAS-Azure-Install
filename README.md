# TAS-Azure-Install

This repository hosts AZ CLI scripts and comprehensive guidelines for deploying VMware Tanzu Application Service (TAS) on Microsoft Azure. It strictly adheres to the official VMware documentation to ensure a secure and optimized environment setup.

## Contents

- **Network Setup:** AZ CLI scripts to establish resource groups, virtual networks, subnets, and network security groups (NSGs).
- **Storage Configuration:** Instructions for setting up Azure storage accounts and containers using AZ CLI.
- **Ops Manager Deployment:** Detailed steps to manage the Ops Manager VHD via AZ CLI scripts.
- **Load Balancer Setup:** Scripts to configure load balancers essential for TAS operations.
- **BOSH Director and TAS Deployment:** Guidance on deploying BOSH Director and TAS, leveraging AZ CLI for all configuration steps.

## Infrastructure Diagram

```mermaid
graph TD
    A[Resource Group: tas-resource-group]
    A --> B[VNet: pcf-virtual-network]
    B --> C[Subnet: infrastructure-subnet]
    B --> D[Subnet: pas-subnet]
    B --> E[Subnet: services-subnet]
    C --> F[NSG: opsmgr-nsg]
    C --> G[VM: OpsManagerVM]
    G -->|NIC| C
    B --> H[Load Balancer: pcf-lb]
    H --> I[Backend Pool: LoadBalancerBackEnd]
    I --> J[TAS VMs]
    F -->|Rules: SSH, HTTP, HTTPS| G
    
## Usage

Utilize the provided AZ CLI scripts and follow the instructions in order to methodically set up your TAS environment on Azure.
