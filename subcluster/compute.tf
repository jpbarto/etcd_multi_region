variable "instance_profile_id" {}

data "aws_ami" "amazon_linux_ami" {
  provider    = "aws.module_region"
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat*"]
  }
}

resource "aws_key_pair" "default" {
  provider   = "aws.module_region"
  key_name   = "${var.region_name}-etcd-node-keypair"
  public_key = "${var.ssh_public_key}"
}

resource "aws_launch_configuration" "default" {
  provider                    = "aws.module_region"
  name_prefix                 = "etcd-cluster-node-"
  image_id                    = "${data.aws_ami.amazon_linux_ami.id}"
  instance_type               = "${var.instance_type}"
  ebs_optimized               = true
  iam_instance_profile        = "${var.instance_profile_id}"
  key_name                    = "${aws_key_pair.default.key_name}"
  enable_monitoring           = false
  associate_public_ip_address = true
  user_data                   = "echo date > /tmp/built.on"
  security_groups             = ["${aws_security_group.etcd-cluster-sg.id}"]

  root_block_device {
    volume_size           = 100
    volume_type           = "gp2"
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "default" {
  provider                  = "aws.module_region"
  availability_zones        = "${var.azs}"
  name                      = "etcd-cluster-node-${count.index}"
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 3
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.default.name}"
  vpc_zone_identifier       = ["${aws_subnet.default.1.id}", "${aws_subnet.default.2.id}", "${aws_subnet.default.0.id}"]
  wait_for_capacity_timeout = "0"

  tag {
    key                 = "Name"
    value               = "etcd-cluster-node-group"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "${var.project_name}"
    propagate_at_launch = true
  }
}
