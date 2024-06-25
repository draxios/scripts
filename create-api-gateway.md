### Step-by-Step Instructions

#### Step 1: Create the Lambda Function
1. **Navigate to the AWS Lambda Console**:
   - Open the AWS Management Console.
   - Go to the Lambda service.

2. **Create a New Lambda Function**:
   - Click on "Create function".
   - Choose "Author from scratch".
   - Enter the function name (e.g., `InsertIntoDynamoDB`).
   - Choose the runtime (e.g., Python 3.8).
   - Set up an execution role with the necessary permissions to access DynamoDB and Secrets Manager.
   - Click on "Create function".

3. **Configure Environment Variables**:
   - In the Lambda function configuration, add an environment variable:
     - Key: `DYNAMODB_TABLE_NAME`
     - Value: `cicd-beg-dev` (or your DynamoDB table name)

4. **Deploy the Lambda Function Code**:
   - Replace the default code with the provided Lambda function code.
   - Click on "Deploy".

#### Step 2: Create the API in API Gateway
1. **Navigate to the API Gateway Console**:
   - Open the AWS Management Console.
   - Go to the API Gateway service.

2. **Create a New API**:
   - Click on "Create API".
   - Choose "REST API" and click on "Build".
   - Enter the API name (e.g., `DynamoDBInsertAPI`).
   - Click on "Create API".

#### Step 3: Set Up the API Resource and Method
1. **Create a Resource**:
   - In the API Gateway console, click on "Resources" in the left-hand menu.
   - Click on the "Actions" drop-down and select "Create Resource".
   - Enter the resource name (e.g., `items`).
   - Click on "Create Resource".

2. **Create a Method**:
   - Select the newly created resource (`/items`).
   - Click on the "Actions" drop-down and select "Create Method".
   - Choose `POST` from the method type drop-down.
   - Click on the checkmark to confirm.

#### Step 4: Integrate the Lambda Function with API Gateway
1. **Set Up Lambda Function Integration**:
   - For the `POST` method, choose "Lambda Function" as the integration type.
   - Select "Use Lambda Proxy integration".
   - In the Lambda Function field, enter the name of your Lambda function (e.g., `InsertIntoDynamoDB`).
   - Click on "Save".
   - Confirm the Lambda function permissions by clicking "OK".

2. **Deploy the API**:
   - Click on the "Actions" drop-down and select "Deploy API".
   - Create a new stage (e.g., `dev`).
   - Click on "Deploy".

#### Step 5: Configure API Gateway Authentication
1. **Enable API Keys (Optional)**:
   - If you want to use API keys, navigate to the API Gateway console.
   - Click on the "Stages" section and select your stage (e.g., `dev`).
   - In the "Stage Editor", click on the "Enable API Gateway Caching" box (optional) and "Require API Key" box.

2. **Create an API Key**:
   - Click on "API Keys" in the left-hand menu.
   - Click on "Create API Key".
   - Enter a name for the API key.
   - Click on "Add API Key to Usage Plan".

3. **Create a Usage Plan**:
   - Click on "Usage Plans" in the left-hand menu.
   - Click on "Create Usage Plan".
   - Enter a name for the usage plan.
   - Configure throttling and quota settings (optional).
   - Click on "Next".
   - Add the API stage to the usage plan.
   - Click on "Next".
   - Add the API key to the usage plan.
   - Click on "Done".

#### Step 6: Test the API
1. **Get the Invoke URL**:
   - In the API Gateway console, navigate to your deployed API stage.
   - Copy the "Invoke URL".

2. **Test with a Client (e.g., Postman)**:
   - Use Postman or a similar tool to send a POST request to the API.
   - Set the request URL to the invoke URL followed by the resource path (e.g., `https://{invoke_url}/items`).
   - Add the necessary headers, including the `x-api-key` header if API keys are enabled.
   - Set the request body to a JSON object matching the expected format.

#### Example Request Body
```json
{
  "json": {
    "repoStatus": "new-repo",
    "accountGroup": "example-group",
    "lambdaName": "example-lambda",
    "organizationName": "example-org",
    "projectName": "example-project",
    "projectType": "example-type",
    "repositoryName": "example-repo"
  }
}
```
