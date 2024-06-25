### Step 1: Create the HTML, CSS, and JavaScript Files

#### index.html
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Repo Request</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <h1>Repo Request</h1>
        <form id="repoRequestForm">
            <label for="apiKey">API Key</label>
            <input type="password" id="apiKey" name="apiKey" required>

            <label for="repoStatus">Repo Status</label>
            <input type="text" id="repoStatus" name="repoStatus" value="new-repo" required>

            <label for="accountGroup">Account Group</label>
            <input type="text" id="accountGroup" name="accountGroup" required>

            <label for="lambdaName">Lambda Name</label>
            <input type="text" id="lambdaName" name="lambdaName" required>

            <label for="organizationName">Organization Name</label>
            <input type="text" id="organizationName" name="organizationName" required>

            <label for="projectName">Project Name</label>
            <input type="text" id="projectName" name="projectName" required>

            <label for="projectType">Project Type</label>
            <input type="text" id="projectType" name="projectType" required>

            <label for="repositoryName">Repository Name</label>
            <input type="text" id="repositoryName" name="repositoryName" required>

            <button type="submit">Submit Request</button>
        </form>
        <div id="response"></div>
    </div>
    <script src="scripts.js"></script>
</body>
</html>
```

#### styles.css
```css
body {
    font-family: 'Courier New', Courier, monospace;
    background-color: #1e1e1e;
    color: #f5f5f5;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    margin: 0;
}

.container {
    background-color: #2e2e2e;
    padding: 2rem;
    border-radius: 8px;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
    max-width: 400px;
    width: 100%;
}

h1 {
    font-size: 24px;
    margin-bottom: 1rem;
    text-align: center;
}

form {
    display: flex;
    flex-direction: column;
}

label {
    margin-top: 1rem;
}

input {
    padding: 0.5rem;
    margin-top: 0.5rem;
    border: none;
    border-radius: 4px;
    font-size: 14px;
}

button {
    margin-top: 1.5rem;
    padding: 0.75rem;
    border: none;
    border-radius: 4px;
    background-color: #007bff;
    color: white;
    font-size: 16px;
    cursor: pointer;
    transition: background-color 0.3s;
}

button:hover {
    background-color: #0056b3;
}

#response {
    margin-top: 1rem;
    text-align: center;
}
```

#### scripts.js
```javascript
document.getElementById('repoRequestForm').addEventListener('submit', async function (event) {
    event.preventDefault();

    const apiKey = document.getElementById('apiKey').value;
    const repoStatus = document.getElementById('repoStatus').value;
    const accountGroup = document.getElementById('accountGroup').value;
    const lambdaName = document.getElementById('lambdaName').value;
    const organizationName = document.getElementById('organizationName').value;
    const projectName = document.getElementById('projectName').value;
    const projectType = document.getElementById('projectType').value;
    const repositoryName = document.getElementById('repositoryName').value;

    const requestBody = {
        apiKey: apiKey,
        json: {
            repoStatus: repoStatus,
            accountGroup: accountGroup,
            lambdaName: lambdaName,
            organizationName: organizationName,
            projectName: projectName,
            projectType: projectType,
            repositoryName: repositoryName
        }
    };

    try {
        const response = await fetch('https://<YOUR_API_GATEWAY_URL>', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(requestBody)
        });

        const responseData = await response.json();
        document.getElementById('response').innerText = responseData.message;
    } catch (error) {
        document.getElementById('response').innerText = 'Error: ' + error.message;
    }
});
```

### Step 2: Host the Static Site Using AWS S3 and CloudFront

1. **Create an S3 Bucket**:
   - Open the AWS Management Console and go to the S3 service.
   - Click "Create bucket".
   - Enter a unique bucket name (e.g., `repo-request-ui`).
   - Choose a region and configure any other settings as needed.
   - Click "Create bucket".

2. **Upload the Files to S3**:
   - Open your S3 bucket.
   - Click "Upload" and add the `index.html`, `styles.css`, and `scripts.js` files.
   - Set permissions for the files to be publicly readable.

3. **Enable Static Website Hosting**:
   - Go to the "Properties" tab of your S3 bucket.
   - Scroll down to the "Static website hosting" section.
   - Click "Edit" and enable static website hosting.
   - Specify `index.html` as the index document.
   - Save changes.

4. **Set Up CloudFront**:
   - Open the AWS Management Console and go to the CloudFront service.
   - Click "Create Distribution".
   - Choose "Web" for the delivery method.
   - Under "Origin Settings", set the Origin Domain Name to your S3 bucket's website endpoint (e.g., `repo-request-ui.s3-website-us-east-1.amazonaws.com`).
   - Configure other settings as needed.
   - Click "Create Distribution".

5. **Update DNS Configuration** (Optional):
   - If you want to use a custom domain, configure your DNS settings to point to the CloudFront distribution.

### Step 3: Test the UI

1. **Access the CloudFront URL**:
   - Once the CloudFront distribution is deployed, navigate to the CloudFront URL provided.

2. **Submit a Repo Request**:
   - Use the form on the UI to submit a repo request.
   - Ensure you provide the correct API key and all necessary details.
