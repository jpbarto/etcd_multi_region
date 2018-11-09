variable "project_name" {
  description = "Project name which all resources will be tagged with"
  default = "etcd-global-cluster"
}

variable "create_benchmark" {
  description = "Deploy an EC2 instance into London for benchmarking purposes"
  default = true 
}

variable "discovery_url" {
  description = "ETCD Discovery URL for cluster intialization, example https://discovery.etcd.io/e6add49bc3f36bc3153791d9986c1731"
 }
