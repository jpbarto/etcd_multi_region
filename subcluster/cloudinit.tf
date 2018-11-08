data "template_file" "cloud-init" {
  template = "${file("${path.module}/cloudinit/userdata-template.json")}"

  vars {
    etcd_member_unit    = "${data.template_file.etcd_member_unit.rendered}"
    ntpdate_unit        = "${data.template_file.ntpdate_unit.rendered}"
    ntpdate_timer_unit  = "${data.template_file.ntpdate_timer_unit.rendered}"
  }
}

data "template_file" "etcd_member_unit" {
  template = "${file("${path.module}/cloudinit/etcd_member_unit")}"

  vars {
    peer_name             = "peer-nm"
    discovery_domain_name = "discovery.i.domain"
    cluster_name          = "benchmark-cluster"
    discovery_url         = "${var.discovery_url}"
  }
}

data "template_file" "ntpdate_unit" {
  template = "${file("${path.module}/cloudinit/ntpdate_unit")}"

  vars {
    ntp_host = "${var.ntp_host}"
  }
}

data "template_file" "ntpdate_timer_unit" {
  template = "${file("${path.module}/cloudinit/ntpdate_timer_unit")}"
}