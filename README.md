# GCP Terraform Lab: HTTP Load Balancer

This project provisions a Global HTTP Load Balancer with a managed instance group backend.

## Resources Created

1.  **Instance Template**: Defines VM config with Apache and startup script.
2.  **Managed Instance Group (MIG)**: Manages 2 instances.
3.  **Load Balancer Components**:
    - Backend Service & Health Check
    - URL Map
    - HTTP Proxy
    - Global Forwarding Rule
4.  **Firewall Rule**: Allows health checks from Google's probe IPs.

## Usage

1.  **Authenticate**:
    ```bash
    gcloud auth application-default login
    ```

2.  **Initialize**:
    ```bash
    terraform init
    ```

3.  **Plan**:
    ```bash
    terraform plan -var="project_id=YOUR_PROJECT_ID"
    ```

4.  **Apply**:
    ```bash
    terraform apply -var="project_id=YOUR_PROJECT_ID"
    ```

5.  **Test**:
    Wait a few minutes for the LB to provision and health checks to pass, then visit the `load_balancer_ip`.
