resource "aws_launch_configuration" "consul_server_launch_config_test" {
  name_prefix = "consul-server-test"
  image_id = "dummy ami id with consul binary baked" 
  instance_type = "t2.micro"
  key_name = "keypair name"
  iam_instance_profile = "Consul"
  security_groups = ["<SG_ID>"]
  associate_public_ip_address = true
  user_data = "${file("data.sh")}"
  
lifecycle {
    create_before_destroy = true
  }
}

# Optional security group to be attached
resource "aws_security_group" "consul_sg" {
  name        = "Consul sg"
  description = "consul sg"
  vpc_id      = "<VPC ID>"
# Inbound Rules
  # HTTP access from anywhere
  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["LOCAL CIDR"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = ["LOCAL CIDR"]
  }
  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "udp"
    cidr_blocks = ["LOCAL CIDR"]
  }
  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = ["LOCAL CIDR"]
  }
  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = ["LOCAL CIDR"]
  }
  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = ["LOCAL CIDR"]
  }
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["LOCAL CIDR"]
  }
  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["LOCAL CIDR"]
  }

# SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["LOCAL CIDR"]
  }
# Outbound Rules
  # Internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["LOCAL CIDR"]
  }
}

resource "aws_autoscaling_group" "consul_server_asg" {
  name = "${aws_launch_configuration.consul_server_launch_config_test.name}-asg"
  min_size             = 2
  desired_capacity     = 2
  max_size             = 2
  launch_configuration = "${aws_launch_configuration.consul_server_launch_config_test.name}"
  vpc_zone_identifier  = [
    "subnet-083e481abe8bf00b4",
    "subnet-0b620783c6e0b2aed"
  ]
    
# Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }
  health_check_type    = "ELB"
  load_balancers = [
    "${aws_elb.consul_elb.id}"
  ]
    tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = "Consul Server"
        "propagate_at_launch" = true
      },
      {
        "key"                 = "Application"
        "value"               = "Consul-test"
        "propagate_at_launch" = true
      },
    ],
  )
}

resource "aws_elb" "consul_elb" {
  name = "consul-elb"
  security_groups = [
    "${aws_security_group.consul_sg.id}"
  ]
  subnets = [
    "subnet-id1",
    "subnet-id2"
  ]
cross_zone_load_balancing   = true
health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:8500/"
  }
listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }
}