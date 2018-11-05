module "london-subcluster" {
    source = "./subcluster"

    region = "eu-west-2"
    region_name = "london"
    vpc_cidr = "172.2.0.0/16"
    azs = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

module "frankfurt-subcluster" {
    source = "./subcluster"

    region = "eu-central-1"
    region_name = "frankfurt"
    vpc_cidr = "172.4.0.0/16"
    azs = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

module "paris-subcluster" {
    source = "./subcluster"

    region = "eu-west-3"
    region_name = "paris"
    vpc_cidr = "172.8.0.0/16"
    azs = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
}

