region = "us-east-1"

vpc_cidr = "10.0.0.0/16"

enable_dns_support = "true"

enable_dns_hostnames = "true"

enable_classiclink = "false"

enable_classiclink_dns_support = "false"

preferred_number_of_public_subnets = 1

preferred_number_of_private_subnets = 2

environment = "dev"

ami-web = "ami-00a45107f7c3455a5"

ami-bastion = "ami-0dbc99375eba56ff4"

ami-nginx = "ami-010bd88cc8f5997f3"

ami-sonar = "ami-0f8bd95a744e074b8"

keypair = "default-ou"

master-username = "waledevops"

master-password = "devops101"

account_no = "669699159433"

tags = {
  Enviroment      = "dev" 
  Owner-Email     = "tofadeolawale@gmail.com"
  Managed-By      = "Terraform"
  Billing-Account = "1234567890"
}