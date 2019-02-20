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

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = ["${aws_security_group.web.id}"]

    #set to true to avoid orphaned ENIs that prevent terraform destroy from completing
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudformation_stack" "asg" {
  depends_on         = ["aws_elb.elb"]
  name               = "${var.asg_stack_name}"
  timeout_in_minutes = 30

  template_body = <<EOF
Description: "web server asg"
Resources:
  ASG:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      VPCZoneIdentifier: ["${join("\",\"", aws_subnet.subnet.*.id)}"]
      AvailabilityZones: ["${join("\",\"", var.aws_availability_zones)}"]
      Cooldown: "30"
      LaunchTemplate:
        LaunchTemplateId : "${aws_launch_template.template.id}"
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
        MaxBatchSize: 3
        MinInstancesInService: 3
        PauseTime: PT10M
        SuspendProcesses:
          - HealthCheck
          - ReplaceUnhealthy
          - AZRebalance
          - AlarmNotification
          - ScheduledActions
        WaitOnResourceSignals: no
    DeletionPolicy: Delete
  EOF
}
