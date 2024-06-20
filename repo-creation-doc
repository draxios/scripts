### Simplified Architecture

1. **AWS DynamoDB**: A table (`BEGTable`) to store the new repository information with a partition key indicating a new repository.
2. **AWS Lambda**: Multiple Lambda functions to handle different automation tasks:
    - Create Repository
    - Add Hello World Template
    - Add README and .gitignore
    - Create Build and Deploy Pipeline
3. **AWS Step Functions**: To orchestrate the execution of Lambda functions in a defined sequence.
4. **AWS CloudWatch**: For monitoring and logging.

### Workflow

1. **New Entry in DynamoDB**:
   - A new row is added to the `BEGTable` with the `repoStatus` set to `new-repo`.

2. **DynamoDB Stream**:
   - Triggers a Lambda function when a new entry is added to the `BEGTable`.

3. **Initial Lambda Function**:
   - Reads the new entry from DynamoDB and starts the execution of a Step Functions state machine.

4. **Step Functions State Machine**:
   - Orchestrates the sequence of Lambda functions to create the repository, add templates, and set up the pipeline.

5. **Monitoring and Logging**:
   - Each step is monitored and logged using AWS CloudWatch.

### Implementation Example

#### Step Functions Definition
```json
{
  "Comment": "Orchestrate repo creation steps",
  "StartAt": "CreateRepository",
  "States": {
    "CreateRepository": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:region:account-id:function:CreateRepository",
      "Next": "AddHelloWorldTemplate"
    },
    "AddHelloWorldTemplate": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:region:account-id:function:AddHelloWorldTemplate",
      "Next": "AddReadmeAndGitignore"
    },
    "AddReadmeAndGitignore": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:region:account-id:function:AddReadmeAndGitignore",
      "Next": "CreateBuildAndDeployPipeline"
    },
    "CreateBuildAndDeployPipeline": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:region:account-id:function:CreateBuildAndDeployPipeline",
      "End": true
    }
  }
}
```

#### Initial Lambda Function
```python
import json
import boto3

dynamodb = boto3.client('dynamodb')
stepfunctions = boto3.client('stepfunctions')

def lambda_handler(event, context):
    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            new_image = record['dynamodb']['NewImage']
            input_data = {
                'repositoryName': new_image['repositoryName']['S'],
                'projectName': new_image['projectName']['S'],
                'projectType': new_image['projectType']['S'],
                'accountGroup': new_image['accountGroup']['S'],
                'lambdaName': new_image['lambdaName']['S']
            }
            response = stepfunctions.start_execution(
                stateMachineArn='arn:aws:states:region:account-id:stateMachine:RepoCreationStateMachine',
                input=json.dumps(input_data)
            )
            print(f"Started Step Function: {response['executionArn']}")
    return {'statusCode': 200, 'body': 'Step Functions execution started'}
```

### Event Payload Example for Step Functions
```json
{
  "repositoryName": "sample-repo",
  "projectName": "SampleProject",
  "pipelineName": "SamplePipeline",
  "projectType": "python-lambda",
  "accountGroup": "StifelFinancial"
}
```

### Additional Considerations
- **Error Handling**: Implement error handling within each Lambda function. For example, use try-except blocks and log errors to CloudWatch.
- **Idempotency**: Ensure your Lambda functions are idempotent to handle potential retries or duplicates from DynamoDB Streams.
- **Security**: Ensure IAM roles and policies are correctly configured to grant only the necessary permissions to each component.



### Step 1: Set Up AWS DynamoDB

1. **Create a DynamoDB Table**:
   - **Table Name**: `BEGTable`
   - **Primary Key**: `repoStatus` (Partition Key), `timestamp` (Sort Key)

### Step 2: Set Up AWS Secrets Manager

1. **Create a Secret**:
   - **Secret Name**: `your-secret-name`
   - **Secret Value**: `{"AzureManagementPAT": "your_personal_access_token"}`

### Step 3: Create Lambda Functions

#### 1. Initial Lambda Function: `InitialLambdaFunction`

1. **Create the Lambda Function**:
   - **Function Name**: `InitialLambdaFunction`
   - **Runtime**: Python 3.8 or later
   - **Role**: Create a new role with basic Lambda permissions and permissions to read from DynamoDB, Secrets Manager, and trigger Step Functions.

2. **Add the Following Code**:
   ```python
   import json
   import boto3
   import base64
   import subprocess
   import tempfile
   import os

   dynamodb = boto3.client('dynamodb')
   stepfunctions = boto3.client('stepfunctions')
   secrets_client = boto3.client('secretsmanager')
   http = urllib3.PoolManager()

   def get_secret(secret_name):
       try:
           response = secrets_client.get_secret_value(SecretId=secret_name)
           secret = response['SecretString']
           return json.loads(secret)
       except Exception as e:
           print(f"Error retrieving secret: {e}")
           raise e

   def clone_repo(repo_url, local_path, personal_access_token):
       clone_url = repo_url.replace("https://", f"https://{personal_access_token}@")
       subprocess.run(["git", "clone", clone_url, local_path], check=True)

   def lambda_handler(event, context):
       # Get the personal access token from Secrets Manager
       secret_name = "your-secret-name"
       secrets = get_secret(secret_name)
       personal_access_token = secrets['AzureManagementPAT']
       
       # Clone the Azure DevOps repository containing the Step Function definitions
       repo_url = "https://dev.azure.com/StifelFinancial/BEG-Platform/_git/aws-intake-step-function-definitions"
       with tempfile.TemporaryDirectory() as temp_dir:
           clone_repo(repo_url, temp_dir, personal_access_token)
           
           # Read the Step Function definition file
           step_function_file_path = os.path.join(temp_dir, 'new-repo-full.json')
           with open(step_function_file_path, 'r') as file:
               step_function_definition = json.load(file)
       
       for record in event['Records']:
           if record['eventName'] == 'INSERT':
               new_image = record['dynamodb']['NewImage']
               input_data = {
                   'repositoryName': new_image['repositoryName']['S'],
                   'projectName': new_image['projectName']['S'],
                   'projectType': new_image['projectType']['S'],
                   'accountGroup': new_image['accountGroup']['S'],
                   'lambdaName': new_image['lambdaName']['S']
               }
               response = stepfunctions.start_execution(
                   stateMachineArn='arn:aws:states:region:account-id:stateMachine:RepoCreationStateMachine',
                   input=json.dumps(input_data),
                   name=f"Execution-{new_image['repositoryName']['S']}-{new_image['projectName']['S']}"
               )
               print(f"Started Step Function: {response['executionArn']}")
       return {'statusCode': 200, 'body': 'Step Functions execution started'}
   ```

3. **Add Permissions**:
   - Add permissions to access Secrets Manager.
   - Add permissions to start Step Function executions.
   - Add permissions to read from DynamoDB.

#### 2. Create Additional Lambda Functions for Each Task

- **Create Lambda Functions**: 
   - `CreateRepository`
   - `AddHelloWorldTemplate`
   - `AddReadmeAndGitignore`
   - `CreateBuildAndDeployPipeline`
  
- **Set Up Each Lambda Function**: 
   - **Runtime**: Python 3.8 or later
   - **Role**: Create a new role or use the existing role with necessary permissions.
   - **Code**: Implement the required functionality for each Lambda.

### Step 4: Set Up AWS Step Functions

1. **Create a State Machine**:
   - **Name**: `RepoCreationStateMachine`
   - **Definition**: Use the JSON definition provided earlier in the detailed implementation example.

2. **Link Lambda Functions**:
   - Ensure each task in the state machine is linked to the corresponding Lambda function.

### Step 5: Integrate DynamoDB Streams with Lambda

1. **Enable DynamoDB Streams**:
   - Go to the `BEGTable` in DynamoDB.
   - Enable DynamoDB Streams with `NEW_AND_OLD_IMAGES`.

2. **Trigger Lambda Function**:
   - Set up DynamoDB Streams to trigger the `InitialLambdaFunction`.

### Step 6: Set Up AWS CloudWatch

1. **Create Log Groups**:
   - Ensure each Lambda function has a corresponding CloudWatch log group.

2. **Enable Monitoring**:
   - Enable monitoring and set up dashboards/alarms as needed.

### Step 7: Test the Implementation

1. **Add a New Entry to DynamoDB**:
   - Add a new row to the `BEGTable` with `repoStatus` set to `new-repo` and other required attributes.

2. **Monitor Execution**:
   - Check the CloudWatch logs to monitor the execution flow.
   - Verify that the Step Function starts and executes the Lambda functions in the correct sequence.

### Detailed Step-by-Step Implementation in AWS Console

#### DynamoDB
1. **Create Table**:
   - Open the DynamoDB console.
   - Click `Create table`.
   - Set `Table name` to `BEGTable`.
   - Set `Partition key` to `repoStatus` (String).
   - Set `Sort key` to `timestamp` (Number).
   - Enable DynamoDB Streams with `NEW_AND_OLD_IMAGES`.

#### AWS Secrets Manager
1. **Create a Secret**:
   - Open the Secrets Manager console.
   - Click `Store a new secret`.
   - Choose `Other type of secret`.
   - Add key `AzureManagementPAT` and its value.
   - Set the secret name to `your-secret-name`.

#### Lambda Functions
1. **Create Initial Lambda Function**:
   - Open the Lambda console.
   - Click `Create function`.
   - Choose `Author from scratch`.
   - Set `Function name` to `InitialLambdaFunction`.
   - Choose `Python 3.8` for Runtime.
   - Choose `Create a new role with basic Lambda permissions`.
   - Click `Create function`.
   - Add the provided code to the function.
   - Add permissions for DynamoDB, Secrets Manager, and Step Functions.

2. **Create Additional Lambda Functions**:
   - Repeat the above steps for `CreateRepository`, `AddHelloWorldTemplate`, `AddReadmeAndGitignore`, and `CreateBuildAndDeployPipeline`.
   - Implement the required functionality for each Lambda.

#### Step Functions
1. **Create State Machine**:
   - Open the Step Functions console.
   - Click `Create state machine`.
   - Choose `Author with code snippets`.
   - Set the name to `RepoCreationStateMachine`.
   - Add the state machine definition JSON.

#### DynamoDB Streams
1. **Enable Streams and Set Trigger**:
   - Go to the `BEGTable` in DynamoDB.
   - Enable DynamoDB Streams with `NEW_AND_OLD_IMAGES`.
   - In the Lambda console, set the stream as a trigger for `InitialLambdaFunction`.

#### CloudWatch
1. **Create Log Groups and Enable Monitoring**:
   - Open the CloudWatch console.
   - Ensure each Lambda function has a log group.
   - Set up dashboards and alarms as needed.

### Testing
1. **Add a New Entry to DynamoDB**:
   - Open the DynamoDB console.
   - Go to the `BEGTable`.
   - Click `Explore table items`.
   - Click `Create item`.
   - Add `repoStatus` and `timestamp`, along with other required attributes.

2. **Monitor Execution**:
   - Open the CloudWatch console.
   - Monitor logs and execution flow.
   - Verify the execution of the Step Functions and Lambda functions.
