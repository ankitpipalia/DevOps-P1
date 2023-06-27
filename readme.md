# Frontend
Genrate Manage Deployment Token and paste to Azure DevOps pipeline for CI/CD


# Backend
## Create Pfx Certificate For Azure Application Gateway
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -out test-cert.crt -keyout test-cert.key
openssl pkcs12 -export -in test-cert.crt -inkey test-cert.key -passout pass:test -out test-cert.pfx


# Terraform
## Install infracost
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh
## Print the Cost Of Resources
infracost breakdown --format html --out-file cost.html --show-skipped --path .
## make Azure App Registration With RBAC(Contributar Role) For Terraform Cloud
az ad sp create-for-rbac --name <custom-app-name> --role Contributor --scopes /subscriptions/<subscriptions-id>
## Uploading function to azure
Use Azure-core and azure cli to push function


# Ansible
Put Virtual Machine ip-address in /etc/hosts and inventory/hosts
SSH key will be scp to virtual machine for private repo clone


# Function
func init MyThumbnailFunction --python
func new --name ThumbnailFunction --template "blobTrigger" --language "Python"
pip3 install -r requirments.txt
func azure functionapp publish <function_name>