# The entire section create a certiface, public zone, and validate the certificate using DNS method

# Create the certificate using a wildcard for all the domains created in walesdevops.ml
resource "aws_acm_certificate" "walesdevops" {
  domain_name       = "*.walesdevops.ml"
  validation_method = "DNS"
}

# calling the hosted zone
data "aws_route53_zone" "walesdevops" {
  name         = "walesdevops.ml"
  private_zone = false
}

# selecting validation method
resource "aws_route53_record" "walesdevops" {
  for_each = {
    for dvo in aws_acm_certificate.walesdevops.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.walesdevops.zone_id
}

# validate the certificate through DNS method
resource "aws_acm_certificate_validation" "walesdevops" {
  certificate_arn         = aws_acm_certificate.walesdevops.arn
  validation_record_fqdns = [for record in aws_route53_record.walesdevops : record.fqdn]
}

# create records for tooling
resource "aws_route53_record" "tooling" {
  zone_id = data.aws_route53_zone.walesdevops.zone_id
  name    = "tooling.walesdevops.ml"
  type    = "A"

  alias {
    name                   = aws_lb.ext-alb.dns_name
    zone_id                = aws_lb.ext-alb.zone_id
    evaluate_target_health = true
  }
}

# create records for wordpress
resource "aws_route53_record" "wordpress" {
  zone_id = data.aws_route53_zone.walesdevops.zone_id
  name    = "wordpress.walesdevops.ml"
  type    = "A"

  alias {
    name                   = aws_lb.ext-alb.dns_name
    zone_id                = aws_lb.ext-alb.zone_id
    evaluate_target_health = true
  }
}

# Create ALB
resource "aws_lb" "ext-alb" {
  name            = var.name
  internal        = false
  security_groups = [var.public-sg]

  subnets = [var.public-sbn-1]

  tags = merge(
    var.tags,
    {
      Name = var.name
    },
  )

  ip_address_type    = var.ip_address_type
  load_balancer_type = var.load_balancer_type
}


# Create Target Group for ALB

resource "aws_lb_target_group" "nginx-tgt" {
  health_check {
    interval            = 10
    path                = "/healthstatus"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
  name        = "nginx-tgt"
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

# Create Listner for Target Group

resource "aws_lb_listener" "nginx-listner" {
  load_balancer_arn = aws_lb.ext-alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.walesdevops.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx-tgt.arn
  }
}