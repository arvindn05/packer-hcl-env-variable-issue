#Common
variables {
  date = "{{isotime \"2006.01.02.03.04\"}}"
  name_append = "-testing"
  is_production = false
}

# AWS
variable "aws_extra_regions" {
  type    = list(string)
  default = []
}
variable "aws_shared_accounts" {
  type    = list(string)
  default = []
}
variables {
  aws_ssh_interface = null
  security_group_id = null
  source_ami        = null
  subnet_id         = null
  vpc_id = null
  ami_name = null
}

source "amazon-ebssurrogate" "ami" {
  ami_name    = var.ami_name
  ami_regions = var.aws_extra_regions
  ami_root_device {
    delete_on_termination = true
    device_name           = "/dev/xvda"
    source_device_name    = "/dev/xvdf"
    volume_size           = 16
    volume_type           = "gp2"
  }
  ami_users                   = var.aws_shared_accounts
  ami_virtualization_type     = "hvm"
  associate_public_ip_address = true
  communicator                = "ssh"
  ena_support                 = true
  encrypt_boot                = false
  instance_type               = "t2.medium"
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/xvdf"
    volume_size           = 16
    volume_type           = "gp2"
  }
  region            = "us-west-2"
  security_group_id = var.security_group_id
  source_ami        = var.source_ami
  ssh_interface     = var.aws_ssh_interface
  ssh_pty           = true
  ssh_username      = "centos"
  subnet_id         = var.subnet_id
  tags = {
    Architecture = "x86_64"
    Builder      = "Packer"
    Enabled      = "false"
    OS           = "CentOS 7"
  }
  vpc_id = var.vpc_id
}

build {
  sources = ["source.amazon-ebssurrogate.ami"]

  provisioner "shell" {
    environment_vars = [ "TARGET_DISK=/dev/xvdf" ]
    execute_command  = "chmod +x {{ .Path }} ; sudo {{ .Vars }} {{ .Path }}"
    only             = ["amazon-ebssurrogate.ami"]
    scripts          = ["env_vars-demo.sh"]
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}
