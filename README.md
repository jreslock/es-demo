## Terraforming ElasticSearch in AWS

### Running this project

#### Requirements
You will need the following

- Docker
- AWS credentials (AWS Access Key, Secret Access Key)
- AWS config with a profile named `ops-admin` set to assume an IAM role which has AdministratorAccess privileges.
- A registered DNS TLD which you can point to the DNS NS records created by this project (for public DNS to work)  This mapping can be done after creating the Route53 zones.  External/public DNS is not required for this demo to function but I thought it would be nice to have a publicly routable name for the service.
- An existing VPC and subnet in which to build the AMI.  Since this project builds a new VPC, there is a bit of chicken and egg problem.  You need a VPC and subnet in order to build an AMI but you need the AMI in order to deploy the full solution.  I have opted to just use the default VPC and public subnet to build the AMI and follow that with the VPC creation.
- Set vars in terraform.tfvars (not included in the git repo due to the fact that it contains potentially sensitive information)
    - `aws_profile = "ops-admin"`
    - `aws_role_arn = "arn:aws:iam::<your account number>:role/ops-admin"`
    - `domain = <your tld (i.e. example.com)>`
    - `tls_cert_arn = <the arn of a valid ACM certificate>`
    - `ssh_public_key = <The contents of an ssh public key you would like to use for ssh access to the instances>`
    - `es_ami = <AMI ID generated from running packer to build an AMI>` 

Once the required variables are set, AWS access is confirmed, DNS records mapped to appropriate name servers, etc.  Build the docker image to run this project:
    `docker build -t demo .`

Run the newly built image and share two volumes so that AWS credentials are inside of the container and the current working directory is in /home/demo/code
    `docker run -it -v $PWD:/home/demo/code -v ~/.aws:/home/demo/.aws demo`
    
You should be dropped into a bash prompt with all of the required tools to build and deploy this project.
    
    `cd code/packer && packer build -var 'aws_subnet_id=<your_subnet_id>' ami-builder.json` - To build the AMI (Be sure to set this AMI ID in terraform.tfvars once it has been built)
    `cd code/terraform && terraform init && terraform plan` - To initialize the project and see what resources Terraform will be creating
    `cd code/terraform && terraform apply` - To deploy the infrastructure

### References

- [Terraform documentation](https://www.terraform.io/docs/providers/aws/index.html)
- [AWS documentation](https://docs.aws.amazon.com/index.html#lang/en_us)
- [ES documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
### Notes

- This is intended for demo purposes only.  It is not designed to be production-grade.
- In a team setting the Terraform state would be in a KMS-encrypted S3 bucket and state locking would be provided via a DynamoDB table.  This would create difficulty when attempting to run the project in a different AWS account than my own.
- The project will create a new VPC with related subnets, NAT and internet gateway, route tables, etc. to house the ES cluster and ensure it is on a private network.
- TLS encryption is enabled for inter-node communication via the ElasticSearch x-pack utility.  I am using a self-signed certificate and CA.
- All nodes present the same TLS certificate because it is generated when the AMI is built.  This greatly simplifies deployment but also sacrifices a bit on security.  In a production setting, each node should have a unique certificate that is tied to the hostname, IP or dns fqdn of the node.  Since this is a demo, the fastest path was to use one certificate.
- The main parts of this project are the AMI, ALB and AutoScaling Group.  The AMI is built such that it requires no run-time configuration and can be booted directly from the ASG and join the ES cluster automatically.
- The ALB is configured to forward traffic to all cluster nodes on port 9200 via HTTP (ES seems to have a strange TLS over HTTP connection method that I personally dont like, but wasn't going to try and change).  It also has an extra listener rule to automatically redirect HTTP requests to HTTPS.
- The ALB is configured with a wide-open security group allowing inbound HTTPS/443 traffic from 0.0.0.0/0.  In a production setting, this should be configured with a WAF and rules to restrict where source traffic is allowed from.
- There is a single wildcard certificate attached to the ALB that will handle TLS encryption for inbound client traffic.  This certificate was generated manually via the Amazon Certificate Manager tool in the AWS console. 
- There is a bastion host configured that will be launched in one of the public subnets so that access to the environment via SSH is possible for troubleshooting.  This instance should be stopped/shut down when not in use as it has a wide-open security group allowing inbound port 22 traffic from 0.0.0.0/0.  This could be locked down or limited to specific CIDR blocks if desired.  Alternatively, in a production setting there would be no bastion host as the VPC would likely have a VPN that would allow access to the private subnets.
- I spent somewhere between 8 and 10 hours building this demo.  Most of the time was spent learning ElasticSearch, specifically on securing ES as the documentation is less than stellar.