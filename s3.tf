# Create a (unique) bucket name automatically by using a prefix.
resource "aws_s3_bucket" "static" {
  bucket_prefix = "avery-tf-static-site"
  force_destroy = true # helpful during dev; remove or set false in prod
  tags = {
    Name      = "avery-tf-static-site"
    ManagedBy = "terraform"
  }
}

# Block public ACLs/policies
resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.static.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enforce Bucket Owner (recommended when using OAC)
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.static.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Data source to clone the static website repository
data "external" "clone_repo" {
  program = ["bash", "-c", <<-EOT
    REPO_URL="https://github.com/cloudacademy/static-website-example.git"
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    git clone "$REPO_URL" static-site
    cd static-site
    # Create a JSON output with the directory path
    echo "{\"path\": \"$TEMP_DIR/static-site\"}"
  EOT
  ]
}

# Upload static files to S3
resource "null_resource" "upload_static_files" {
  depends_on = [aws_s3_bucket.static]

  provisioner "local-exec" {
    command = <<-EOT
      # Install awscli if not present
      if ! command -v aws &> /dev/null; then
        echo "AWS CLI not found. Please install it first."
        exit 1
      fi
      
      # Upload all files from the cloned repository to S3
      aws s3 sync "${data.external.clone_repo.result.path}/" s3://${aws_s3_bucket.static.id}/ \
        --delete \
        --exclude ".git/*" \
        --exclude "*.md" \
        --exclude "LICENSE*"
    EOT
  }

  triggers = {
    # Re-upload when the bucket changes
    bucket_id = aws_s3_bucket.static.id
    # Re-upload when the repository content changes
    repo_hash = data.external.clone_repo.result.path
  }
}
