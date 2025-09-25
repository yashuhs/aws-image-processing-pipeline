#!/bin/bash
# This script packages the Lambda function and its dependencies.
set -e

FUNCTION_NAME="image_processor"
OUTPUT_DIR="dist"
PACKAGE_FILE="${OUTPUT_DIR}/${FUNCTION_NAME}.zip"
SRC_DIR="src"

# Create a clean output directory
rm -rf ${OUTPUT_DIR}
mkdir -p ${OUTPUT_DIR}

# Install dependencies into a temporary package directory
python3 -m pip install -r requirements.txt -t ${OUTPUT_DIR}/package

# Go into the package directory and zip dependencies
cd ${OUTPUT_DIR}/package
zip -r ../${FUNCTION_NAME}.zip .

# Go back to the root and add the Lambda function code to the zip
cd ../..
cd ${SRC_DIR}
zip -g ../${PACKAGE_FILE} *.py

echo "✅ Lambda package created at ${PACKAGE_FILE}"