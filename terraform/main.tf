provider "aws" {
  region = var.region
}


## Create VPC-Resources for project

# The VPC
resource "aws_vpc" "de-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "de-vpc"
  }
}

# Public Subnet (for Orchestration)
resource "aws_subnet" "de-public-subnet" {
  vpc_id     = aws_vpc.de-vpc.id
  cidr_block = "10.1.1.0/24"
  tags = {
    Name = "de-public-subnet"
  }
}


# IGW for public subnet
resource "aws_internet_gateway" "de-igw" {
  vpc_id = aws_vpc.de-vpc.id
  tags = {
    Name = "de-igw"
  }
}

# Route Table for public SN (internet access)
resource "aws_route_table" "de-public-rt" {
  vpc_id = aws_vpc.de-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.de-igw.id
  }
  tags = {
    Name = "de-public-rt"
  }
}

# Map route-table to public SN
resource "aws_route_table_association" "de-rta-public-subnet" {
  depends_on = [
    aws_subnet.de-public-subnet,
    aws_route_table.de-public-rt
  ]
  subnet_id      = aws_subnet.de-public-subnet.id
  route_table_id = aws_route_table.de-public-rt.id
}

# Private Subnet (for DB)
resource "aws_subnet" "de-private-subnet-1" {
  vpc_id            = aws_vpc.de-vpc.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "de-private-subnet-1"
  }
}

resource "aws_subnet" "de-private-subnet-2" {
  vpc_id            = aws_vpc.de-vpc.id
  cidr_block        = "10.1.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "de-private-subnet-2"
  }
}

resource "aws_route_table" "de-private-rt-1" {
  vpc_id = aws_vpc.de-vpc.id
  tags = {
    Name = "de-private-rt-1"
  }
}

resource "aws_route_table" "de-private-rt-2" {
  vpc_id = aws_vpc.de-vpc.id
  tags = {
    Name = "de-private-rt-2"
  }
}

# Map route-table to private SN
resource "aws_route_table_association" "de-rta-private-subnet-1" {
  depends_on = [
    aws_subnet.de-private-subnet-1,
    aws_route_table.de-private-rt-1
  ]
  subnet_id      = aws_subnet.de-private-subnet-1.id
  route_table_id = aws_route_table.de-private-rt-1.id
}

resource "aws_route_table_association" "de-rta-private-subnet-2" {
  depends_on = [
    aws_subnet.de-private-subnet-2,
    aws_route_table.de-private-rt-2
  ]
  subnet_id      = aws_subnet.de-private-subnet-2.id
  route_table_id = aws_route_table.de-private-rt-2.id
}

# Create Security Group
resource "aws_security_group" "de-ec2-sg" {
  name        = "de-ec2-sg"
  description = "Security Group for accessing the EC2 VPC resources"
  vpc_id      = aws_vpc.de-vpc.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Internet access to the Mage Pipeline / IDE"
    from_port   = 6789
    to_port     = 6789
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana access"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbount access to Aurora DB in private subnet"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.1.2.0/24"] # Grant access to private subnet
  }

  egress {
    description      = "Full internet access"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

## Create EC2 in public subnet
resource "aws_instance" "mage-instance" {
  ami = "ami-005fc0f236362e99f" # Ubuntu 22.04
  # instance_type          = "m5.xlarge"  # $0.23/h, 4 vCPU, 16 GB RAM, EBS only
  instance_type               = "m5.large" # $0.096, 2 vCPU, 8 GiB RAM, EBS only
  key_name                    = "de_key"
  subnet_id                   = aws_subnet.de-public-subnet.id
  vpc_security_group_ids      = [aws_security_group.de-ec2-sg.id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2-instance-profile.name # IAM Role for EC2 instance

  root_block_device {
    volume_size = 40
    volume_type = "gp2"
  }

  user_data = templatefile("user_data.sh", {
    docker_compose_yaml = data.template_file.docker_compose.rendered
  })

  tags = {
    Name = "Orchestration Mage-Instance"
  }
}

resource "aws_security_group" "de-rds-sg" {
  name        = "de-rds-sg"
  description = "Security Group for RDS Database"
  vpc_id      = aws_vpc.de-vpc.id

  ingress {
    description     = "PostgreSQL Access"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.de-ec2-sg.id] # Grant access to public subnets sg
  }
}

# # Subnet Group for Aurora Database
# resource "aws_db_subnet_group" "de-aurora-subnet-group" {
#   name        = "de-aurora-subnet-group"
#   description = "Subnet Group for Aurora Database"
#   subnet_ids  = [
#     aws_subnet.de-private-subnet-1.id,
#     aws_subnet.de-private-subnet-2.id
#   ]
#   tags = {
#     Name = "de-aurora-subnet-group"
#   }
# }


# resource "aws_rds_cluster" "de-aurora-cluster" {

#   cluster_identifier   = "aurora-cluster"
#   engine               = "aurora-postgresql"
#   engine_mode          = "provisioned"
#   engine_version       = "16.6"
#   database_name        = "dev"
#   master_username      = "admin"
#   master_password      = var.postgres-password

#   skip_final_snapshot = true
#   allocated_storage   = 20 # 20 GB (min. storage)

#   scaling_configuration {
#     auto_pause               = true
#     min_capacity             = 1
#     max_capacity             = 2
#     seconds_until_auto_pause = 300
#     timeout_action           = "ForceApplyCapacityChange"
#   }

#   # Put the cluster in the private subnet
#   vpc_security_group_ids = [aws_security_group.de-rds-sg.id] # DB SG

#   tags = {
#     Name = "de-aurora-cluster"
#   }
# }

# resource "aws_rds_cluster_instance" "de-aurora-instance" {
#   count              = 1
#   identifier         = "de-aurora-instance"
#   cluster_identifier = aws_rds_cluster.de-aurora-cluster.cluster_identifier_prefix
#   instance_class     = "db.R6g.large" # 16GB RAM, 2 vCPU, $0.225/h
#   engine             = aws_rds_cluster.de-aurora-cluster.engine
#   engine_version     = aws_rds_cluster.de-aurora-cluster.engine_version

#   # Ensuring that instances are created in the designated subnet
#   db_subnet_group_name = aws_db_subnet_group.de-aurora-subnet-group.name

#   tags = {
#     Name = "de-aurora-instance"
#   }
# }

# data "template_file" "docker_compose" {
#   template = file("${path.module}/../docker-compose.yml.tpl")

#   vars = {
#     PROJECT_NAME      = var.project-name
#     POSTGRES_DBNAME   = aws_rds_cluster.de-aurora-cluster.database_name
#     POSTGRES_SCHEMA   = var.postgres-schema
#     POSTGRES_USER     = aws_rds_cluster.de-aurora-cluster.master_username
#     POSTGRES_PASSWORD = var.postgres-password
#     POSTGRES_HOST     = aws_rds_cluster.de-aurora-cluster.endpoint
#     POSTGRES_PORT     = aws_rds_cluster.de-aurora-cluster.port
#   }
# }

data "template_file" "docker_compose" {
  template = file("${path.module}/../docker-compose.yml.tpl")

  vars = {
    PROJECT_NAME      = var.project-name
    POSTGRES_DBNAME   = "dev" # aws_rds_cluster.de-aurora-cluster.database_name
    POSTGRES_SCHEMA   = var.postgres-schema
    POSTGRES_USER     = "admin" # aws_rds_cluster.de-aurora-cluster.master_username
    POSTGRES_PASSWORD = var.postgres-password
    POSTGRES_HOST     = "localhost" # aws_rds_cluster.de-aurora-cluster.endpoint
    POSTGRES_PORT     = 5432        # aws_rds_cluster.de-aurora-cluster.port
    S3_BUCKET_NAME    = var.s3-bucket-name
  }
}