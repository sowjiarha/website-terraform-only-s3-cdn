resource "aws_cloudfront_distribution" "www_distribution" {
   depends_on = [aws_s3_bucket.bucket]
// origin is where CloudFront gets its content from.
  origin {

    custom_origin_config {
      // These are all the defaults.
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2", "TLSv1.1"]
    }

    // Here we're using our S3 bucket's URL!
    domain_name = "${aws_s3_bucket.bucket.website_endpoint}"
    // This can be any name to identify this origin.
    origin_id   = "${var.domainName}"
  }

  enabled             = true
  default_root_object = "index.html"

  // All values are defaults from the AWS console.
  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    // This needs to match the `origin_id` above.
    target_origin_id       = "${var.domainName}"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  // rather than the domain name CloudFront gives us.
  aliases = ["${var.domainName}"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  // Here's where our certificate is loaded in!
  viewer_certificate {
    acm_certificate_arn = "${var.acm_arn}"
    ssl_support_method  = "sni-only"
  }
}
