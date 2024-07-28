@echo off

:INPUT_INSTANCE_NAME
set "INSTANCE_NAME="
set /p "INSTANCE_NAME=Enter a name for the EC2 instance: "

if "%INSTANCE_NAME%"=="" (
  echo Name of The EC2 Instance is empty. Press any key to continue...
  pause >nul
  goto INPUT_INSTANCE_NAME
)

:INPUT_IMAGE
set "AMI_ID="
set /p "AMI_ID=Enter the AMI ID of the image to launch: "

if "%AMI_ID%"=="" (
  echo Please enter a valid AMI ID. Press any key to continue...
  pause >nul
  goto INPUT_IMAGE
)

:INPUT_INSTANCE_TYPE
set "INSTANCE_TYPE="
set /p "INSTANCE_TYPE=Enter the instance type (e.g., t2.micro): "

if "%INSTANCE_TYPE%"=="" (
  echo Please enter a valid instance type. Press any key to continue...
  pause >nul
  goto INPUT_INSTANCE_TYPE
)

:INPUT_KEY_PAIR
set "KEY_PAIR="
set /p "KEY_PAIR=Enter the name of the key pair to use: "

if "%KEY_PAIR%"=="" (
  echo Please enter a valid key pair name. Press any key to continue...
  pause >nul
  goto INPUT_KEY_PAIR
)

:INPUT_SECURITY_GROUP
set "SECURITY_GROUP="
set /p "SECURITY_GROUP=Enter the security group ID (or \"nil\" for default): "

if "%SECURITY_GROUP%"=="" (
  echo Please enter a security group ID or \"nil\". Press any key to continue...
  pause >nul
  goto INPUT_SECURITY_GROUP
)

:INPUT_COUNT
set "COUNT="
set /p "COUNT=Enter the Number of Instances to be launched: "

if "%COUNT%"=="" (
  echo Empty Input. Please enter the number of instances to be launched. Press any key to continue...
  pause >nul
  goto INPUT_COUNT
)

:INPUT_REGION
set "REGION="
set /p "REGION=Enter the Region of the instance to be launched: "

if "%REGION%"=="" (
  echo Empty Input. Please enter the region of the instance to be launched. Press any key to continue...
  pause >nul
  goto INPUT_REGION
)

REM Error handling
aws --version >nul 2>&1
if %errorlevel% neq 0 (
  echo Error: AWS CLI is not configured. Make sure it's installed and configured properly.
  echo Please configure AWS CLI in your system to execute this file.
  pause >nul
  exit /b 1
)

REM Launch the EC2 instance
if "%SECURITY_GROUP%" NEQ "" (
  REM To launch an instance into a non-default subnet and add a public IP address
  aws ec2 run-instances --image-id %AMI_ID% --instance-type %INSTANCE_TYPE% --security-group-ids %SECURITY_GROUP% --key-name %KEY_PAIR% --count %COUNT% --region %REGION% --tag-specifications ResourceType=instance,Tags=[{Key=Name,Value=%INSTANCE_NAME%}] > nul
) else (
  REM To launch an instance into a default subnet
  aws ec2 run-instances --image-id %AMI_ID% --instance-type %INSTANCE_TYPE% --key-name %KEY_PAIR% --count %COUNT% --region %REGION% --tag-specifications ResourceType=instance,Tags=[{Key=Name,Value=%INSTANCE_NAME%}] > nul
)

echo EC2 instance launched successfully.

REM Describe the launched instance
aws ec2 describe-instances --filters "Name=tag:Name,Values=%INSTANCE_NAME%" --query "Reservations[*].Instances[*].[InstanceId,PrivateIpAddress,PublicIpAddress,State.Name]" --output table

REM Wait for any key press before exiting
pause >nul
