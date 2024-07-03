#!/bin/bash

# Create load balancer for TAS for VMs (with public IP)
az network lb create --name pcf-lb \
                    --resource-group $RESOURCE_GROUP \
                    --location $LOCATION \
                    --backend-pool-name pcf-lb-be-pool \
                    --frontend-ip-name pcf-lb-fe-ip \
                    --public-ip-address pcf-lb-ip \
                    --public-ip-address-allocation Static \
                    --sku Standard

# Add probe for health checks on port 8080
az network lb probe create --lb-name pcf-lb \
                         --name http8080 \
                         --resource-group $RESOURCE_GROUP \
                         --protocol Http \
                         --port 8080 \
                         --path health

# Add load balancing rule for HTTP traffic
az network lb rule create --lb-name pcf-lb \
                         --name http \
                         --resource-group $RESOURCE_GROUP \
                         --protocol Tcp \
                         --frontend-port 80 \
                         --backend-port 80 \
                         --frontend-ip-name pcf-lb-fe-ip \
                         --backend-pool-name pcf-lb-be-pool \
                         --probe-name http8080

# Add load balancing rule for HTTPS traffic
az network lb rule create --lb-name pcf-lb \
                         --name https \
                         --resource-group $RESOURCE_GROUP \
                         --protocol Tcp \
                         --frontend-port 443 \
                         --backend-port 443 \
                         --frontend-ip-name pcf-lb-fe-ip \
                         --backend-pool-name pcf-lb-be-pool \
                         --probe-name http8080

# Get the public IP of the load balancer
PUBLIC_IP=$(az network public-ip show --name pcf-lb-ip --resource-group $RESOURCE_GROUP --query ipAddress -o tsv)

echo "Public IP of the load balancer: $PUBLIC_IP"
