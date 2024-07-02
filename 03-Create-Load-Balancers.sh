#Create Load Balancers
az network lb create --resource-group tas-resource-group --name pcf-lb --sku Standard --frontend-ip-name LoadBalancerFrontEnd --backend-pool-name LoadBalancerBackEnd

#Configure Load Balancer Rules
az network lb rule create --resource-group tas-resource-group --lb-name pcf-lb --name http-rule --protocol Tcp --frontend-port 80 --backend-port 80 --frontend-ip-name LoadBalancerFrontEnd --backend-pool-name LoadBalancerBackEnd --probe-name http-probe

az network lb rule create --resource-group tas-resource-group --lb-name pcf-lb --name https-rule --protocol Tcp --frontend-port 443 --backend-port 443 --frontend-ip-name LoadBalancerFrontEnd --backend-pool-name LoadBalancerBackEnd --probe-name https-probe

