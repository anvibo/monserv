terraform {
  backend "gcs" {
    bucket = "anvibo-terraform-states"
    prefix = "monaps10/vm"
    credentials = "../../../creds/anvibo-gcp-f5f9b5100748.json"
  }
}
provider "google" {
  credentials = "${file("../../../creds/anvibo-gcp-f5f9b5100748.json")}"
  project     = "anvibo-gcp"
  region      = "us-central1"
  zone        = "us-central1-a"
}



data "template_file" "metadata_startup_script" {
    template = "${file("${path.module}/bootstrap.sh")}"
}

module "monaps10" {
  source  = "anvibo/compute-with-public-ip/google"

    name = "monaps10"
    type = "f1-micro"
    boot_disk_type = "pd-ssd"
    boot_disk_size = 10
    image = "ubuntu-minimal-1804-lts"
    subnetwork = "vpc-1-us-central1"
    network_tags = ["http-server", "https-server", "monserv", "allow-ssh"]
    startup_script = "${data.template_file.metadata_startup_script.rendered}"
}

resource "google_compute_disk" "hdd-1" {
    name    = "hdd-1"
    type    = "pd-standard"
    size    = "10"
}

resource "google_compute_attached_disk" "default" {
    disk = "${google_compute_disk.hdd-1.id}"
    instance = "${module.monaps10.instance_id}"
    depends_on = ["google_compute_disk.hdd-1"]
}