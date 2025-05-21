# Generates a random 4-byte hex string to make the S3 bucket name globally unique
resource "random_id" "bucket_id" {
  byte_length = 4
}

# Creates the actual S3 bucket for the Vue frontend files
resource "aws_s3_bucket" "frontend" {
  bucket = "vue-frontend-dashboard-${random_id.bucket_id.hex}"

  tags = {
    Name = "VueFrontend"  # Optional tag to identify the bucket
  }
}

# Configures the bucket to act as a static website (for SPA routing)
resource "aws_s3_bucket_website_configuration" "frontend_site" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"  # Entry point of the Vue SPA
  }

  error_document {
    key = "index.html"     # Also load index.html on error (important for client-side routing)
  }
}

# Allows public access to the bucket (default settings block all public access)
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Defines a policy that allows anyone (public) to read objects from this bucket
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.frontend.id

  depends_on = [aws_s3_bucket_public_access_block.frontend]

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",  # Allow all users
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.frontend.arn}/*"  # Allow read access to all objects in the bucket
      }
    ]
  })
}
