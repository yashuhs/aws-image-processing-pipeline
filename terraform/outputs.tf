output "source_bucket_name" {
  description = "The name of the S3 bucket for uploading original images."
  value       = aws_s3_bucket.source.bucket
}

output "destination_bucket_name" {
  description = "The name of the S3 bucket where processed images are stored."
  value       = aws_s3_bucket.destination.bucket
}