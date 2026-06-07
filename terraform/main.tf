provider "aws" {
  region = "us-east-1"
}

# DYNAMODB TABLE WITH STREAMS ENABLED
resource "aws_dynamodb_table" "financial_data" {
  name         = "financial-processing-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "TransactionID"

  attribute {
    name = "TransactionID"
    type = "S"
  }

  # LESSON CORE: Enables the stream. "NEW_IMAGE" captures the entire new item.
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"
}

# 2. IAM ROLE & POLICIES FOR LAMBDA
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Grant Lambda permission to read from DynamoDB Streams and write execution logs to CloudWatch
resource "aws_iam_role_policy" "lambda_stream_policy" {
  name = "saa_lab_lambda_stream_policy"
  role = aws_iam_role.lambda_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream",
          "dynamodb:ListStreams"
        ]
        Resource = "${aws_dynamodb_table.financial_data.arn}/stream/*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# 3. LAMBDA FUNCTION CONFIGURATION
# Create a local zip file containing the Python code inline
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "validator" {
  filename         = "lambda_function.zip"
  function_name    = "financial-data-validator"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# 4. EVENT SOURCE MAPPING (The Glue)
resource "aws_lambda_event_source_mapping" "dynamodb_trigger" {
  event_source_arn  = aws_dynamodb_table.financial_data.stream_arn
  function_name     = aws_lambda_function.validator.arn
  starting_position = "LATEST"
  batch_size        = 1 # Process records immediately as they arrive
}
