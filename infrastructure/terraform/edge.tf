data "aws_route53_zone" "zone" {
  name         = "${var.fqdn}."
  private_zone = false
}

# SSL
resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.fqdn_app}"
  validation_method = "DNS"
}

resource "aws_route53_record" "validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = "60"
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn = "${aws_acm_certificate.cert.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.validation.fqdn}",
  ]
}

# Create a new load balancer
resource "aws_elb" "elb" {
  name            = "elb${var.suffix}"
  security_groups = ["${aws_security_group.web.id}"]
  subnets         = ["${aws_subnet.subnet.*.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${aws_acm_certificate_validation.default.certificate_arn}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  cross_zone_load_balancing   = true

  tags {
    Name = "${format("%s.%s", "elb", var.fqdn)}"
    App  = "${var.fqdn}"
  }
}

resource "aws_route53_record" "web" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name    = "${var.fqdn_app}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.elb.dns_name}"]

  depends_on = ["aws_elb.elb"]
}
