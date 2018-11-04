resource "aws_route53_zone" "es-demo-public" {
  name = "${var.domain}"

  tags {
    Name      = "public zone"
    terraform = true
  }
}

resource "aws_route53_record" "public-ns" {
  name = "${aws_route53_zone.es-demo-public.name}"
  type = "NS"
  ttl  = "300"

  records = [
    "${aws_route53_zone.es-demo-public.name_servers.0}",
    "${aws_route53_zone.es-demo-public.name_servers.1}",
    "${aws_route53_zone.es-demo-public.name_servers.2}",
    "${aws_route53_zone.es-demo-public.name_servers.3}",
  ]

  zone_id = "${aws_route53_zone.es-demo-public.id}"
}

resource "aws_route53_zone" "es-demo-private" {
  name = "int.${var.domain}"

  tags {
    Name      = "private zone"
    terraform = true
  }
}

resource "aws_route53_record" "private-ns" {
  name = "${aws_route53_zone.es-demo-private.name}"
  type = "NS"
  ttl  = "300"

  records = [
    "${aws_route53_zone.es-demo-private.name_servers.0}",
    "${aws_route53_zone.es-demo-private.name_servers.1}",
    "${aws_route53_zone.es-demo-private.name_servers.2}",
    "${aws_route53_zone.es-demo-private.name_servers.3}",
  ]

  zone_id = "${aws_route53_zone.es-demo-private.id}"
}

resource "aws_route53_record" "public-to-private" {
  name    = "int.${var.domain}"
  type    = "NS"
  ttl     = "300"
  zone_id = "${aws_route53_zone.es-demo-public.id}"

  records = [
    "${aws_route53_zone.es-demo-private.name_servers.0}",
    "${aws_route53_zone.es-demo-private.name_servers.1}",
    "${aws_route53_zone.es-demo-private.name_servers.2}",
    "${aws_route53_zone.es-demo-private.name_servers.3}",
  ]
}
