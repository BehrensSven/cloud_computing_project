# Load all files from the frontend build output directory
locals {
  frontend_path = "${path.module}/../frontend/dist"     # Path to Vue build output
  files         = fileset(local.frontend_path, "**/*.*")  # All files recursively
}

# Upload each file in the build output folder to the S3 bucket
resource "aws_s3_object" "vue_files" {
  for_each = { for file in local.files : file => file }

  bucket = aws_s3_bucket.frontend.id           # Destination S3 bucket
  key    = each.key                            # Object key = relative path
  source = "${local.frontend_path}/${each.key}"  # Full local path to the file

  # Set the correct Content-Type based on the file extension
  content_type = lookup(
    {
      html = "text/html"
      css  = "text/css"
      js   = "application/javascript"
      svg  = "image/svg+xml"
      json = "application/json"
    },
    split(".", each.key)[length(split(".", each.key)) - 1],  # Extract file extension
    "application/octet-stream"  # Fallback MIME type
  )
}
