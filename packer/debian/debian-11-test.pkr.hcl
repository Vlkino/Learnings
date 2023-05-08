variable "iso_file" {
  type    = string
  default = "iso-storage_NAS:iso/debian-11.6.0-amd64-netinst.iso"
}

variable "cloudinit_storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "cores" {
  type    = string
  default = "2"
}

variable "disk_format" {
  type    = string
  default = "raw"
}

variable "disk_size" {
  type    = string
  default = "20G"
}

variable "disk_storage_pool" {
  type    = string
  default = "lvnvme"
}

variable "disk_storage_pool_type" {
  type    = string
  default = "lvm"
}

variable "cpu_type" {
  type = string
  default = "kvm64"
}

variable "memory" {
  type    = string
  default = "2048"
}

variable "network_vlan" {
  type    = string
  default = "40"
}

variable "prx-api-token-secret"  {
  type      = string
  sensitive = true
}

variable "prx-api-token-id" {
  type = string
}

variable "prx-api-url" {
  type = string
}

source "proxmox-iso" "debian-11" {
  proxmox_url              = "https://${var.prx-api-url}/api2/json"
  insecure_skip_tls_verify = true
  username                 = var.prx-api-token-id
  token 		   = var.prx-api-token-secret
  node			   = "xwing" 

  template_description = "Debian 11 cloud-init template. Built on ${formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())}"

network_adapters {
    bridge   = "vmbr1"
    firewall = true
    model    = "virtio"
    vlan_tag = var.network_vlan
  }
 disks {
    disk_size         = var.disk_size
    format            = var.disk_format
    io_thread         = true
    storage_pool      = var.disk_storage_pool
    storage_pool_type = var.disk_storage_pool_type
    type              = "scsi"
  }
  scsi_controller = "virtio-scsi-single"

  iso_file       = var.iso_file
  http_directory = "/home/srvalma/packer-ubuntu/debian/http"
  http_port_max  = 8336
  http_port_min  = 8336
  boot_wait      = "10s"
  boot_command   = ["<wait><esc><wait>auto preseed/url=http://10.17.226.50:{{ .HTTPPort }}/preseed.cfg<enter>"]
  qemu_agent = true
  unmount_iso    = true

  cloud_init              = true
  cloud_init_storage_pool = var.cloudinit_storage_pool

  vm_name  = "debian-11.6.0-amd64"
  cpu_type = var.cpu_type
  os       = "l26"
  memory   = var.memory
  cores    = var.cores
  sockets  = "1"

  ssh_password = "packer"
  ssh_username = "root"
  ssh_timeout  = "15m"
}

build {
  sources = ["source.proxmox-iso.debian-11"]

  provisioner "file" {
    destination = "/etc/cloud/cloud.cfg"
    source      = "cloud.cfg"
  }
}
