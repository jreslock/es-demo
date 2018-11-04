output "private_zone_name" {
  value = "${aws_route53_zone.es-demo-private.name}"
}

output "private_zone_id" {
  value = "${aws_route53_zone.es-demo-private.id}"
}

output "public_zone_id" {
  value = "${aws_route53_zone.es-demo-public.id}"
}
