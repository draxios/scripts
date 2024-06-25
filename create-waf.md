### Step 1: Identify Your IP Range

You need to know the IP address ranges that your network uses. These could be public IP addresses or a range of internal IPs if your users are accessing the internet through a shared gateway.

### Step 2: Set Up AWS WAF

1. **Create a Web ACL**:
   - Open the AWS WAF console.
   - Click on "Web ACLs" in the navigation pane.
   - Click on "Create web ACL".
   - Enter a name for the Web ACL (e.g., `RestrictAccessWebACL`).
   - Choose "CloudFront" for the resource to associate with the Web ACL.
   - Click on "Next".

2. **Add Rules to the Web ACL**:
   - Click on "Add my own rules and rule groups".
   - Click on "Add rule".
   - Choose "IP set" as the rule type.
   - Click on "Next".
   - Enter a name for the rule (e.g., `AllowCompanyIPRange`).
   - Click on "Add IP set".
   - Enter a name for the IP set (e.g., `CompanyIPRange`).
   - Add the IP addresses or IP ranges that you want to allow.
   - Click on "Add IP set".

3. **Configure the Rule**:
   - Choose "Allow" as the action for the IP set rule.
   - Click on "Add rule".

4. **Default Action**:
   - Set the default action to "Block".
   - Click on "Next".
   - Review and create the Web ACL.

### Step 3: Associate the Web ACL with CloudFront

1. **Associate the Web ACL with Your CloudFront Distribution**:
   - In the AWS WAF console, go to the "Web ACLs" section.
   - Select the Web ACL you created (`RestrictAccessWebACL`).
   - Click on "Associations" tab.
   - Click on "Add association".
   - Select the CloudFront distribution that you want to restrict access to.
   - Click on "Add association".

### Step 4: Test the Access Control

1. **Access the CloudFront URL**:
   - Attempt to access the CloudFront URL from a device within your company's network.
   - Verify that you can access the site.

2. **Test from an External Network**:
   - Try to access the site from an external network (e.g., your home network or a mobile network).
   - Verify that access is blocked.

### Example of IP Set Rule in AWS WAF
Here is an example of how you might configure the IP set for your company's IP range:

- Name: `CompanyIPRange`
- IP addresses: 
  - `192.0.2.0/24` (example of a public IP range)
  - `198.51.100.0/24` (another example)

### Additional Security Measures

- **HTTPS**: Ensure that your CloudFront distribution is configured to use HTTPS to encrypt data in transit.
- **Access Logs**: Enable CloudFront access logs to monitor who is accessing your site.
