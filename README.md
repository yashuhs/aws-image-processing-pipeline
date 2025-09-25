Here is the complete `README.md` content formatted in raw markdown. You can copy this entire block and paste it directly into your `README.md` file.

-----

````markdown
# Serverless Image Processing Pipeline on AWS

This project implements a fully automated, event-driven pipeline on AWS to process images in real-time. It's designed to solve a common business problem for web applications like e-commerce sites, where multiple versions of an image (e.g., thumbnails, web-optimized) are needed automatically upon upload.

## Architectural Diagram

The architecture is 100% serverless and event-driven. An image upload to the source S3 bucket triggers a Lambda function that performs the resizing and saves the results to a destination bucket.

```mermaid
graph TD;
    subgraph "User's Action"
        A[👤 User] -- Uploads image (.jpg, .png) --> B((Source S3 Bucket));
    end

    subgraph "AWS Automated Workflow"
        B -- S3 Event Trigger --> C{⚙️ AWS Lambda Function};
        C -- Processes Image --> D((Destination S3 Bucket));
    end

    subgraph "Processed Images"
        D -- Stores --> E[🖼️ Thumbnail Version];
        D -- Stores --> F[🖼️ Web-Optimized Version];
    end

    style B fill:#FF9900,stroke:#333,stroke-width:2px
    style D fill:#FF9900,stroke:#333,stroke-width:2px
    style C fill:#5A30B5,stroke:#FFF,stroke-width:2px,color:#FFF
````

## Demo 📸

Here is a demonstration of the pipeline in action. After uploading an image to the source bucket, the processed versions automatically appear in the destination bucket.

*(To add your own GIF, create an `assets` folder in your project, save a `demo.gif` file inside it, push it to your repository, and use the following line of code.)*

`![Demonstration of the image processing pipeline](assets/demo.gif)`

## Problem Solved

In many applications, developers need to manually resize images, which is slow, error-prone, and not scalable. This pipeline automates the entire workflow, ensuring that images are processed instantly, consistently, and cost-effectively.

## Features

  - **Fully Automated**: Image processing is triggered automatically on upload.
  - **Serverless & Scalable**: Built on AWS Lambda and S3, it scales from zero to thousands of requests automatically.
  - **Infrastructure as Code**: The entire infrastructure is provisioned and managed using Terraform for repeatable and reliable deployments.
  - **Secure by Design**: Follows the principle of least privilege with granular IAM roles and private S3 buckets.

## Technology Stack

  - **Cloud Provider**: AWS
  - **Core Services**: S3, Lambda, IAM, CloudWatch
  - **Infrastructure as Code**: Terraform
  - **Application Code**: Python 3.9
  - **Libraries**: Boto3, Pillow

-----

## Development Environment

This project can be deployed from two primary environments: a cloud-based Linux environment (like AWS CloudShell) or a local Windows machine. The setup steps vary slightly.

### 1\. AWS CloudShell or Linux (Recommended)

This is the simplest and most reliable method. The `package.sh` script is designed for a Linux environment and works out of the box.

  * **`package.sh` modification**: Ensure the package command uses `python3`:
    ```bash
    python3 -m pip install -r requirements.txt -t ${OUTPUT_DIR}/package
    ```

### 2\. Local Windows Machine

If you are running this project from a local Windows machine, the `package.sh` script will likely fail due to environment path issues between Git Bash and Windows.

  * **Solution**: Bypass the script and package the Lambda function manually using the Windows Command Prompt (CMD), where Python is reliably found.

    1.  Create the packaging folder:
        ```cmd
        mkdir package
        ```
    2.  Install dependencies into the folder:
        ```cmd
        pip install -r requirements.txt --target ./package
        ```
    3.  Copy your Lambda code:
        ```cmd
        copy src\lambda_function.py package\
        ```
    4.  **Create the ZIP file**: In File Explorer, go into the `package` folder, select all files, right-click, and choose `Send to > Compressed (zipped) folder`. Rename the resulting file to `image_processor.zip`.
    5.  **Create the `dist` folder**:
        ```cmd
        mkdir dist
        ```
    6.  **Move the ZIP file**:
        ```cmd
        move image_processor.zip dist\
        ```

-----

## Setup and Deployment

Follow these steps to deploy the infrastructure on your own AWS account.

### Prerequisites

1.  An AWS Account with programmatic access.
2.  [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) installed on your local machine.
3.  [Python 3.9](https://www.python.org/downloads/) installed.
4.  [Git](https://git-scm.com/downloads) installed.

### Deployment Steps

1.  **Clone the repository:**

    ```bash
    git clone [https://github.com/your-username/your-repo-name.git](https://github.com/your-username/your-repo-name.git)
    cd your-repo-name
    ```

2.  **Configure your AWS Credentials:**
    Make sure your AWS CLI is configured with credentials that have permissions to create the resources in the Terraform files.

    ```bash
    aws configure
    ```

3.  **Package the Lambda Function:**
    Follow the instructions in the "Development Environment" section above. If using a Linux environment, run:

    ```bash
    bash package.sh
    ```

4.  **Deploy the Infrastructure:**
    Navigate to the `terraform` directory and run the following commands.

    ```bash
    cd terraform
    terraform init
    terraform apply --auto-approve
    ```

## How to Use

1.  After deployment, Terraform will output the `source_bucket_name`.
2.  Navigate to the AWS S3 console and find this bucket.
3.  Upload a `.jpg` or `.png` image into the bucket.
4.  Check the `destination_bucket_name`. The resized images will appear in the `thumbnails/` and `web/` folders within seconds.

## Clean Up

To avoid ongoing charges, destroy the resources when you are finished.

**IMPORTANT:** You must manually delete the objects inside the S3 buckets before Terraform can destroy the buckets themselves.

1.  Navigate to the `terraform` directory.
2.  Run the destroy command:
    ```bash
    cd terraform
    terraform destroy --auto-approve
    ```

<!-- end list -->

```
```