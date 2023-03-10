resource "aws_s3_bucket" "pages" {
  bucket = "my-pages-bucket"

  tags = {
    Name        = "My Pages"
    Environment = var.env_name
  }
}

resource "aws_s3_bucket_acl" "pages" {
  bucket = aws_s3_bucket.pages.id
  acl    = "private"
}

resource "aws_s3_object" "homepage" {
    for_each = fileset("files/", "*")
    bucket = aws_s3_bucket.pages.id
    key = each.value
    source = "files/${each.value}"
    etag = filemd5("files/${each.value}")
}