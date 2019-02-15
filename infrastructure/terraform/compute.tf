#Get latest centos 7 image
data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["luckyday-arri-webserver*"]
  }

  owners = ["self"]
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ansible-key"
  public_key = "${var.ssh_public_key}"
}

resource "aws_launch_template" "template" {
  name_prefix   = "luckyday-arri-launch"
  image_id      = "${data.aws_ami.ami.id}"
  instance_type = "${var.ec2_instance_type}"

  #vpc_security_group_ids = ["${aws_security_group.web.id}"]

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = ["${aws_security_group.web.id}"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  #  availability_zones  = ["${var.aws_availability_zones}"]
  desired_capacity    = 3
  max_size            = 6
  min_size            = 3
  vpc_zone_identifier = ["${aws_subnet.subnet.*.id}"]

  launch_template {
    id      = "${aws_launch_template.template.id}"
    version = "$$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }
}
