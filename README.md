## Terraforming ElasticSearch in AWS

### Running this project

#### You will need the following

- Docker
- AWS credentials (AWS Access Key, Secret Access Key)
- AWS config with a profile named `ops-admin` set to assume an IAM role which has AdministratorAccess privileges.
- A registered DNS TLD which you can point to the DNS NS records created by this project (for public DNS to work).
- An existing VPC and subnet in which to build the AMI.
- In packer/ami-builder.json, set the ` "aws_subnet_id": "subnet-7d110d51",` line to match an existing subnet in your VPC.  It should be a public subnet or a private subnet accessible by ssh/port 22 in order for packer to build the image.
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
    `cd packer && packer build -var 'aws_subnet_id=<your_subnet_id>' ami-builder.json` - To build the AMI (Be sure to set this AMI ID in terraform.tfvars once it has been built)
    `cd terraform && terraform init && terraform plan` - To initialize the project and see what resources Terraform will be creating
    `cd terraform && terraform apply` - To deploy the infrastructure

### References

- Terraform documentation
- AWS documentation

### Notes

- This is intended for demo purposes only.  It is not designed to be production-grade quality.
- In a team setting the Terraform state would be in a KMS-encrypted S3 bucket and state locking would be provided via a DynamoDB table.  This would create difficulty when attempting to run the project in a different AWS account than my own.
- The project will create a new VPC with related subnets, NAT and internet gateway, Route tables, etc. to house the ES cluster and ensure it is on a private network.