variable region {}
variable region_name {}

provider "aws" {
    alias = "localregion"
    region = "${var.region}"
}

resource "aws_vpc" "default_vpc" {
    provider = "aws.localregion"
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "${var.region_name}-vpc",
        Project = "etcd-global-cluster"
    }
}

resource "aws_internet_gateway" "default" {
    provider = "aws.localregion"
    vpc_id = "${aws_vpc.default_vpc.id}"

    tags {
      Name = "${var.region_name}-igw",
      Project = "etcd-global-cluster"
    }
}

resource "aws_subnet" "default" {
    provider = "aws.localregion"
    count             = "${length(var.azs)}"
    vpc_id            = "${aws_vpc.default_vpc.id}"
    cidr_block        = "${cidrsubnet(var.vpc_cidr, 2, count.index)}"
    availability_zone = "${element(var.azs, count.index)}"

    tags {
      Name = "${var.region_name}-subnet",
      Project = "etcd-global-cluster"
    }
}

resource "aws_default_route_table" "default" {
    default_route_table_id = "${aws_vpc.default_vpc.default_route_table_id}"

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
      Name = "${var.region_name}-default-rt"
      Project = "etcd-global-cluster"
    }
}