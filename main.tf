#PROVIDER
provider "aws" {
	region = "ap-south-1"
}

#INSTANCE
resource "aws_instance" "apache-php" {

  security_groups = ["${aws_security_group.instance-sg.id}"]
  ami           = "ami-0cc933559cda16fcd"
  instance_type = "t2.micro"
  key_name = "damodaran_test"
  subnet_id = "${var.publicsubnets[0]}"
  associate_public_ip_address = true
  user_data = "${file("${path.module}/installing-components.sh")}"


  tags {
    Name = "Apache-PHP"
  }
}




#SECURITYGROUPS
resource "aws_security_group" "instance-sg" {
  name        = "instance security group"
  description = "Allow all inbound traffic"
  vpc_id      = "${var.vpc_id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [
      "${aws_security_group.lb_sg.id}",
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0",]
  }

  tags {
    Name = "Apache-PHP security group"
  }
}


resource "aws_security_group" "lb_sg" {
  name        = "elb security group"
  description = "Allow all inbound traffic"
  vpc_id      = "${var.vpc_id}"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0",]
  }

  tags {
    Name = "Apache-PHP LB security group"
  }
}



#LOADBALANCERS


resource "aws_elb" "apache_php_elb" {
  name = "Apache-PHP-LB"
  internal = false
  security_groups = ["${aws_security_group.lb_sg.id}"]
  subnets = ["${var.publicsubnets}"]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {    
    healthy_threshold   = 10    
    unhealthy_threshold = 2    
    timeout             = 5       
    interval            = 10 
    target              = "HTTP:80/index.php"    
  }
  instances = ["${aws_instance.apache-php.id}"]

}
