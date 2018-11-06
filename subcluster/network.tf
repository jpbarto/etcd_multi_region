variable vpc_id {}
variable vpc_cidr {}
variable region_code {}
variable region_name {}
variable route_table_id {}
variable neighbor_1_cidr_block {}
variable neighbor_1_peer_id {}
variable neighbor_2_cidr_block {}
variable neighbor_2_peer_id {}

provider "aws" {
  alias  = "module_region"
  region = "${var.region_code}"
}

resource "aws_internet_gateway" "default" {
  provider = "aws.module_region"
  vpc_id   = "${var.vpc_id}"

  tags {
    Name    = "${var.region_name}-igw"
    Project = "etcd-global-cluster"
  }
}

resource "aws_subnet" "default" {
  provider          = "aws.module_region"
  count             = "${length(var.azs)}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr, 2, count.index)}"
  availability_zone = "${element(var.azs, count.index)}"

  tags {
    Name    = "${var.region_name}-subnet"
    Project = "etcd-global-cluster"
  }
}

resource "aws_default_route_table" "default" {
  provider               = "aws.module_region"
  default_route_table_id = "${var.route_table_id}"

  route {
    cidr_block                = "${var.neighbor_1_cidr_block}"
    vpc_peering_connection_id = "${var.neighbor_1_peer_id}"
  }

  route {
    cidr_block                = "${var.neighbor_2_cidr_block}"
    vpc_peering_connection_id = "${var.neighbor_2_peer_id}"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name    = "${var.region_name}-default-rt"
    Project = "etcd-global-cluster"
  }
}

resource "aws_security_group" "etcd-cluster-sg" {
  provider = "aws.module_region"
  name     = "${var.region_name}-etcd-cluster-sg"
  vpc_id   = "${var.vpc_id}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.neighbor_1_cidr_block}"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.neighbor_2_cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "${var.region_name}-etcd-cluster-sg"
    Project = "etcd-global-cluster"
  }
}
