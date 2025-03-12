module "jenkins" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-tf"

  instance_type          = "t3.small"
  vpc_security_group_ids = var.security_group_ids # var.security_group_ids #replace your SG
  subnet_id = var.subnet_id    #var.subnet_id #replace your Subnet
  ami = data.aws_ami.ami_info.id
  user_data = file("jenkins.sh")
  tags = {
    Name = "jenkins-tf"
  }
}

module "jenkins_agent" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-agent"

  instance_type          = "t3.small"
  vpc_security_group_ids = var.security_group_ids # var.security_group_ids
  # convert StringList to list and get first element
  subnet_id = var.subnet_id        #"subnet-0a6f1c9704ca109db" # var.subnet_id
  ami = data.aws_ami.ami_info.id
  user_data = file("jenkins-agent.sh")

  iam_instance_profile = "roboshop_ec2_route53"
  tags = {
    Name = "jenkins-agent"
  }

}

resource "aws_key_pair" "tools" {
  key_name   = "tools"
  # you can paste the public key directly like this
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBElajmmAS+Slq1dnQ2B73xVvYciaQY9naeB1vBKYKD9 udayd@SAT-HYD-L1026"
  # public_key = file("~/.ssh/tools.pub")
  # ~ means windows home directory
}

module "nexus" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "nexus"

  instance_type          = "t3.medium"
  vpc_security_group_ids = var.security_group_ids # var.security_group_ids
  # convert StringList to list and get first element
  subnet_id = var.subnet_id    # var.subnet_id
  ami = data.aws_ami.nexus_ami_info.id
  key_name = aws_key_pair.tools.key_name
  root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 30
    }
  ]
  tags = {
    Name = "nexus"
  }
}


module "sonarqube" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "sonarqube"

  instance_type          = "t3.medium"
  vpc_security_group_ids = var.security_group_ids # var.security_group_ids
  # convert StringList to list and get first element
  subnet_id = var.subnet_id    # var.subnet_id
  ami =    ""                         ## fetch the emi d
  key_name = aws_key_pair.tools.key_name
  root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 30
    }
  ]
  tags = {
    Name = "sonarqube"
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "jenkins"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins.public_ip
      ]
      allow_overwrite = true
    },
    {
      name    = "jenkins-agent"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins_agent.private_ip
      ]
      allow_overwrite = true
    },
    {
      name    = "nexus"
      type    = "A"
      ttl     = 1
      allow_overwrite = true
      records = [
        module.nexus.private_ip
      ]
      allow_overwrite = true
    },
    {
      name    = "sonarqube"
      type    = "A"
      ttl     = 1
      allow_overwrite = true
      records = [
        module.sonarqube.private_ip
      ]
      allow_overwrite = true
    }
  ]

}