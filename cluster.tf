provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

provider "aws" {
  alias  = "paris"
  region = "eu-west-3"
}

provider "aws" {
  alias  = "frankfurt"
  region = "eu-central-1"
}

resource "aws_vpc" "london_vpc" {
  provider             = "aws.london"
  cidr_block           = "172.2.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "london-vpc"
    Project = "etcd-global-cluster"
  }
}

resource "aws_vpc" "frankfurt_vpc" {
  provider             = "aws.frankfurt"
  cidr_block           = "172.4.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "frankfurt-vpc"
    Project = "etcd-global-cluster"
  }
}

resource "aws_vpc" "paris_vpc" {
  provider             = "aws.paris"
  cidr_block           = "172.8.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "paris-vpc"
    Project = "etcd-global-cluster"
  }
}

resource "aws_vpc_peering_connection" "paris_to_frankfurt" {
  provider    = "aws.paris"
  vpc_id      = "${aws_vpc.paris_vpc.id}"
  peer_vpc_id = "${aws_vpc.frankfurt_vpc.id}"
  peer_region = "eu-central-1"
  auto_accept = false

  tags = {
    Name    = "Paris2FrankfurtPeer"
    Project = "etcd-global-cluster"
  }
}

resource "aws_vpc_peering_connection_accepter" "paris_to_frankfurt_accept" {
  provider                  = "aws.frankfurt"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.paris_to_frankfurt.id}"
  auto_accept               = true

  tags = {
    Side = "Acceptor"
  }
}

resource "aws_vpc_peering_connection" "london_to_frankfurt" {
  provider    = "aws.london"
  vpc_id      = "${aws_vpc.london_vpc.id}"
  peer_vpc_id = "${aws_vpc.frankfurt_vpc.id}"
  peer_region = "eu-central-1"
  auto_accept = false

  tags = {
    Name    = "London2FrankfurtPeer"
    Project = "etcd-global-cluster"
  }
}

resource "aws_vpc_peering_connection_accepter" "london_to_frankfurt_accept" {
  provider                  = "aws.frankfurt"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.london_to_frankfurt.id}"
  auto_accept               = true

  tags = {
    Side = "Acceptor"
  }
}

resource "aws_vpc_peering_connection" "london_to_paris" {
  provider    = "aws.london"
  vpc_id      = "${aws_vpc.london_vpc.id}"
  peer_vpc_id = "${aws_vpc.paris_vpc.id}"
  peer_region = "eu-west-3"
  auto_accept = false

  tags = {
    Name    = "London2ParisPeer"
    Project = "etcd-global-cluster"
  }
}

resource "aws_vpc_peering_connection_accepter" "london_to_paris_accept" {
  provider                  = "aws.paris"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.london_to_paris.id}"
  auto_accept               = true

  tags = {
    Side = "Acceptor"
  }
}

module "london_cluster" {
  source = "./subcluster"

  vpc_id                = "${aws_vpc.london_vpc.id}"
  vpc_cidr              = "${aws_vpc.london_vpc.cidr_block}"
  route_table_id        = "${aws_vpc.london_vpc.default_route_table_id}"
  region_code           = "eu-west-2"
  region_name           = "london"
  neighbor_1_cidr_block = "${aws_vpc.frankfurt_vpc.cidr_block}"
  neighbor_1_peer_id    = "${aws_vpc_peering_connection.london_to_frankfurt.id}"
  neighbor_2_cidr_block = "${aws_vpc.paris_vpc.cidr_block}"
  neighbor_2_peer_id    = "${aws_vpc_peering_connection.london_to_paris.id}"
  azs                   = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  instance_profile_id   = "${aws_iam_instance_profile.default.id}"
}

module "frankfurt_cluster" {
  source = "./subcluster"

  vpc_id                = "${aws_vpc.frankfurt_vpc.id}"
  vpc_cidr              = "${aws_vpc.frankfurt_vpc.cidr_block}"
  route_table_id        = "${aws_vpc.frankfurt_vpc.default_route_table_id}"
  region_code           = "eu-central-1"
  region_name           = "frankfurt"
  neighbor_1_cidr_block = "${aws_vpc.paris_vpc.cidr_block}"
  neighbor_1_peer_id    = "${aws_vpc_peering_connection.paris_to_frankfurt.id}"
  neighbor_2_cidr_block = "${aws_vpc.london_vpc.cidr_block}"
  neighbor_2_peer_id    = "${aws_vpc_peering_connection.london_to_frankfurt.id}"
  azs                   = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  instance_profile_id   = "${aws_iam_instance_profile.default.id}"
}

module "paris_cluster" {
  source = "./subcluster"

  vpc_id                = "${aws_vpc.paris_vpc.id}"
  vpc_cidr              = "${aws_vpc.paris_vpc.cidr_block}"
  route_table_id        = "${aws_vpc.paris_vpc.default_route_table_id}"
  region_code           = "eu-west-3"
  region_name           = "paris"
  neighbor_1_cidr_block = "${aws_vpc.frankfurt_vpc.cidr_block}"
  neighbor_1_peer_id    = "${aws_vpc_peering_connection.paris_to_frankfurt.id}"
  neighbor_2_cidr_block = "${aws_vpc.london_vpc.cidr_block}"
  neighbor_2_peer_id    = "${aws_vpc_peering_connection.london_to_paris.id}"
  azs                   = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
  instance_profile_id   = "${aws_iam_instance_profile.default.id}"
}
