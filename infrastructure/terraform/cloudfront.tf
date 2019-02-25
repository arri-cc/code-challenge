resource "aws_s3_bucket" "s3_cdn" {
  provider      = "aws.useast1"
  bucket        = "${var.aws_s3_bucket_for_cdn}"
  acl           = "${var.aws_s3_bucket_for_cdn_acl}"
  force_destroy = true

  tags {
    Environment = "${var.fqdn_app}"
  }
}

resource "aws_s3_bucket_object" "logs_cdn" {
  provider = "aws.useast1"
  bucket   = "${aws_s3_bucket.s3_cdn.id}"
  key      = "${var.logs_cdn}"
  source   = "/dev/null"
  etag     = "${md5(file("/dev/null"))}"
  acl      = "public-read"
}

resource "aws_s3_bucket_object" "content_for_cdn" {
  provider = "aws.useast1"
  count    = "${length(var.content_for_cdn)}"
  bucket   = "${aws_s3_bucket.s3_cdn.id}"
  key      = "${element(keys(var.content_for_cdn), count.index)}"
  source   = "${var.content_for_cdn[element(keys(var.content_for_cdn), count.index)]}"
  etag     = "${md5(file(var.content_for_cdn[element(keys(var.content_for_cdn), count.index)]))}"
  acl      = "public-read"
}

resource "aws_cloudfront_distribution" "content_cdn" {
  provider   = "aws.useast1"
  depends_on = ["aws_acm_certificate.cert_cdn", "aws_s3_bucket_object.cdn_logs"]

  origin {
    domain_name = "${aws_s3_bucket.s3_cdn.bucket_regional_domain_name}"
    origin_id   = "${aws_s3_bucket.s3_cdn.id}"
  }

  enabled         = true
  is_ipv6_enabled = false

  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.s3_cdn.bucket_domain_name}"
    prefix          = "${var.logs_cdn}"
  }

  aliases = ["${var.fqdn_cdn}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.s3_cdn.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/images/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${aws_s3_bucket.s3_cdn.id}"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US"]
    }
  }

  tags {
    Environment = "${var.fqdn_app}"
  }

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.cert_cdn.arn}"
    ssl_support_method  = "sni-only"
  }
}

resource "aws_acm_certificate" "cert_cdn" {
  provider          = "aws.useast1"
  domain_name       = "${var.fqdn_cdn}"
  validation_method = "DNS"
}

resource "aws_route53_record" "dns_validation_cdn" {
  provider = "aws.useast1"
  name     = "${aws_acm_certificate.cert_cdn.domain_validation_options.0.resource_record_name}"
  type     = "${aws_acm_certificate.cert_cdn.domain_validation_options.0.resource_record_type}"
  zone_id  = "${data.aws_route53_zone.zone.zone_id}"
  records  = ["${aws_acm_certificate.cert_cdn.domain_validation_options.0.resource_record_value}"]
  ttl      = "60"
}

resource "aws_acm_certificate_validation" "cert_validation_cdn" {
  provider        = "aws.useast1"
  certificate_arn = "${aws_acm_certificate.cert_cdn.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.dns_validation_cdn.fqdn}",
  ]
}

resource "aws_route53_record" "cdn" {
  provider = "aws.useast1"
  zone_id  = "${data.aws_route53_zone.zone.zone_id}"
  name     = "${var.fqdn_cdn}"
  type     = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.content_cdn.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.content_cdn.hosted_zone_id}"
    evaluate_target_health = false
  }
}
