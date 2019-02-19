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
  name_prefix   = "${var.fqdn_app}-launch"
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

resource "aws_cloudformation_stack" "asg" {
  depends_on = ["aws_elb.elb"]
  name       = "${var.asg_stack_name}"

  template_body = <<EOF
Description: "web server asg"
Resources:
  ASG:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      VPCZoneIdentifier: ["${join("\",\"", aws_subnet.subnet.*.id)}"]
      AvailabilityZones: ["${join("\",\"", var.aws_availability_zones)}"]
      LaunchTemplate:
        LaunchTemplateId : "${aws_launch_template.template.id}"
       # LaunchTemplateName : "${aws_launch_template.template.name}"
        Version : "${aws_launch_template.template.latest_version}"
      MinSize: "${var.asg_min}"
      MaxSize: "${var.asg_max}"
      DesiredCapacity: "${var.asg_desired}"
      HealthCheckType: EC2
      LoadBalancerNames: ["${aws_elb.elb.name}"]

    UpdatePolicy:
    # Ignore differences in group size properties caused by scheduled actions
      AutoScalingScheduledAction:
        IgnoreUnmodifiedGroupSizeProperties: true
      AutoScalingRollingUpdate:
        MaxBatchSize: 1
        MinInstancesInService: 2
        MinSuccessfulInstancesPercent: 33
        PauseTime: PT10M
        SuspendProcesses:
          - HealthCheck
          - ReplaceUnhealthy
          - AZRebalance
          - AlarmNotification
          - ScheduledActions
        WaitOnResourceSignals: no
    DeletionPolicy: Retain
  EOF
}
