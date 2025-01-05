#!/bin/bash

# Environment variables
ENVIRONMENT=$1

check_num_of_args() {
    # Checking the number of arguments
    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 <environment>"
        exit 1
    fi
}

activate_infra_environment() {
    # Acting based on the argument value
    if [ "$ENVIRONMENT" == "local" ]; then
        echo "Running script for Local Environment..."
    elif [ "$ENVIRONMENT" == "testing" ]; then
        echo "Running script for Testing Environment..."
    elif [ "$ENVIRONMENT" == "production" ]; then
        echo "Running script for Production Environment..."
    else
        echo "Invalid environment specified. Please use 'local', 'testing', or 'production'."
        exit 2
    fi
}

# Function to check if AWS CLI is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI is not installed. Please install it before proceeding."
        return 1
    fi
}

# Function to check if AWS profile is set
check_aws_profile() {
    if [ -z "$AWS_PROFILE" ]; then
        echo "AWS profile environment variable is not set."
        return 1
    fi
}

# Function to create IAM users
create_iam_users() {
    # List of IAM users to be created
    IAM_USERS=("alice" "bob" "charlie" "dave" "eve")
    
    # Iterate through the array of IAM users and create each user
    for USER in "${IAM_USERS[@]}"; do
        echo "Creating IAM user: $USER"
        aws iam create-user --user-name "$USER"
        if [ $? -eq 0 ]; then
            echo "IAM user $USER created successfully."
        else
            echo "Failed to create IAM user $USER."
        fi
    done
}

# Function to create an IAM group "admin" and assign users to it
create_iam_group_and_assign() {
    # Create "admin" IAM group
    echo "Creating IAM group: admin"
    aws iam create-group --group-name admin
    if [ $? -eq 0 ]; then
        echo "IAM group 'admin' created successfully."
    else
        echo "Failed to create IAM group 'admin'."
    fi
    
    # Iterate through the array of IAM users and add them to the "admin" group
    for USER in "${IAM_USERS[@]}"; do
        echo "Adding user $USER to the 'admin' group"
        aws iam add-user-to-group --user-name "$USER" --group-name admin
        if [ $? -eq 0 ]; then
            echo "User $USER added to 'admin' group successfully."
        else
            echo "Failed to add user $USER to 'admin' group."
        fi
    done
}

check_num_of_args
activate_infra_environment
check_aws_cli
check_aws_profile

# Create IAM users
create_iam_users

# Create IAM group and assign users
create_iam_group_and_assign

