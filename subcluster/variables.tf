provider "aws" {
  region = "eu-west-2"
}

variable "azs" {
  type = "list"
  description = "List of availability zones into which to deploy infrastructure"
}

variable "instance_type" {
  description = "Instance type to be used for ETCD cluster nodes"
  default = "c5.2xlarge"
}

variable "ssh_public_key" {
  description = "SSH key to be installed into EC2 instances"
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqRfcwabJmBrOpu1aIKfQrpuvo8rG7t4zsA6iFMzgeIkLD5uOTZBoqzdfOhqevGTrWIKaEvCd/s3tV74W7HmxbglVUfm746+DbaK27WoJw1aTwlvKt1qRfreDuFppG2l+glkazwnIAMzdWuHMchGcR5iczME9KegM53q+8gGq62OJUonLHE8WVIcAr6puSMiTx/nITmeqULFTCTdymsu7acppbdzPoQVJO1zEjlw/oUXKKXvBMY7vxgOeocw4eLiFp8KdsnUYPIfC7NtROnc4nSP6OIspxfFvhNJx2+SbhvLmXnruNJlVjiDaa/xLubMNhBj9aLgdJx74P4ugUAxSr4S9fZ8KrhP1uqTYeJr/KFe9Ey2dhesyCv0cC2vHpffYEMCbrpdmtFFkuoMRYNNVLNPoppUPC/LlCqBgl63lfMwm6bF0stkNzSKZxHJrpJHBT85JZVqE6gDgTnqMoJpulB5vyfjpS8q6qD05BY9RFrQg79HfrU7qZ0GzNS0YWqYkmmqKDM4zQlaBv4oTRNSoiXOhOX7AixdUxHTnxlwvvlacf1V6diuoLYhBLY7I4513um/I75FAJCiZ6ILqg37b7Ujx/APmCXpBqOqMY7QPqDfH6P4dcjNE0VQGZuiHYDKNCTu6ZP+PjbgYSbzzu8/DdABLaaWIrYyhmlYntio88kQ== jasbarto@amazon.com"
}

variable "project_name" {}

variable "ntp_host" {
  description = "NTP IP address with which the ETCD cluster node will sync"
  default = "169.254.169.123"
}

variable "discovery_url" { }

variable "create_benchmark" {
  default = false
}
