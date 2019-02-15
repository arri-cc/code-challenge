resource "aws_vpc" "vpc" {
  count                = 1
  cidr_block           = "${var.vpc_network_cidr_block}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${format("%s.%s-%s", "vpc", var.aws_region, var.fqdn)}"
    App  = "${var.fqdn}"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "${element(var.aws_availability_zones, count.index)}"
  cidr_block        = "${element(var.vpc_network_subnet_cidr_blocks, count.index)}"
  count             = "${var.replica_count}"

  depends_on = ["aws_vpc.vpc"]

  tags {
    Name = "${format("%s.%s-%s", "subnet", element(var.aws_availability_zones, count.index), var.fqdn)}"
    App  = "${var.fqdn}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id     = "${aws_vpc.vpc.id}"
  depends_on = ["aws_vpc.vpc"]

  tags {
    Name = "${format("%s.%s-%s", "gw", var.aws_region, var.fqdn)}"
    App  = "${var.fqdn}"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  depends_on = ["aws_vpc.vpc"]

  tags {
    Name = "${format("%s.%s-%s", "routes", element(var.aws_availability_zones, count.index), var.fqdn)}"
    App  = "${var.fqdn}"
  }
}

resource "aws_route_table_association" "to_subnet" {
  count          = "${var.replica_count}"
  subnet_id      = "${element(aws_subnet.subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.route_table.id}"
  depends_on     = ["aws_route_table.route_table"]
}

resource "aws_security_group" "web" {
  name        = "web-server-rules"
  description = "Allow HTTP(S), ICMP ECHO and SSH"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    description = "Allow all traffic between webservers"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "allow icmp echo"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = ["aws_vpc.vpc"]

  tags {
    Name = "${format("%s.%s-%s", "websg", element(var.aws_availability_zones, count.index), var.fqdn)}"
    App  = "${var.fqdn}"
  }
}

resource "aws_vpc_dhcp_options" "dchp_options" {
  domain_name         = "${var.fqdn_internal}"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    Name = "${format("%s.%s-%s", "dchp-options", element(var.aws_availability_zones, count.index), var.fqdn)}"
    App  = "${var.fqdn}"
  }
}

resource "aws_vpc_dhcp_options_association" "dhcp_association" {
  vpc_id          = "${aws_vpc.vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dchp_options.id}"
}

resource "null_resource" "aws_vpc_resources" {
  depends_on = [
    "aws_vpc.vpc",
    "aws_subnet.subnet",
    "aws_internet_gateway.gw",
    "aws_security_group.web",
  ]
}
