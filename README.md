# Uptime Kuma on Google Cloud Platform

This Terraform configuration deploys Uptime Kuma, an open-source monitoring tool, on GCP VM using Container-Optimized OS and Docker.

## Features

- Runs on GCP's free tier eligible VM (e2-micro)
- Persistent storage for monitoring data
- Automatic container deployment
- Uses Container-Optimized OS for better security and performance

## Prerequisites

- Google Cloud Platform account with billing enabled
- Terraform installed (version >= 1.0.0)
- Google Cloud CLI installed
- A GCP project with required APIs enabled:
  - Compute Engine API
  - Cloud Resource Manager API

## Directory Structure

```
uptime-kuma-gcp-vm/
├── main.tf          # Main Terraform configuration
├── variables.tf     # Declaring variables for terraform configuration
├── terraform.tfvars # Variables configuration (create this)
└── README.md        # This file
```

## Quick Start

1. Clone this repository:

```bash
git clone https://github.com/rishabkumar7/uptime-kuma-gcp-vm
cd uptime-kuma-gcp-vm
```

2. Create a `terraform.tfvars` file:

```hcl
project_id = "your-project-id"
```

3. Initialize and apply:

```bash
terraform init
terraform apply
```

4. Access Uptime Kuma at

```
http://<instance-ip>:3001
```

The IP address will be shown in Terraform's output.

## Configuration Options

Edit `terraform.tfvars` to customize your deployment:

```hcl
project_id = "your-project-id"
region = "us-central1"      # Default: us-central1
zone = "us-central1-a"      # Default: us-central1-a
machine_type = "e2-micro"   # Default: e2-micro
disk_size = 20             # Default: 20 GB
boot_disk_size = 10        # Default: 10 GB
```

## Maintenance

### Updating Uptime Kuma

To update to a new version, modify the container image tag in `main.tf`:

```hcl
image = "registry.hub.docker.com/louislam/uptime-kuma:new-version"
```

Then run:

```bash
terraform apply
```

### Backup

The monitoring data is stored on a persistent disk. To create a backup:

1. Stop the VM in GCP Console
2. Create a snapshot of the `kuma-disk`
3. Restart the VM

### Clean Up

To remove all resources:

```bash
terraform destroy
```

⚠️ Warning: This will delete all resources including monitoring data!

## Troubleshooting

### Can't Access Uptime Kuma

1. Wait 2-3 minutes after deployment for container initialization
2. Verify VM is running:

```bash
gcloud compute instances describe uptime-kuma-vm
```

3. Check container logs:

```bash
gcloud compute ssh uptime-kuma-vm --command="docker ps && docker logs \$(docker ps -q)"
```

### Common Issues

- **Terraform Provider Error**: Make sure you've enabled the necessary APIs
- **Container Not Starting**: Check logs using the command above
- **Disk Not Mounting**: Check startup script logs in GCP Console

## Security Notes

- The deployment opens port 3001 to all IPs (0.0.0.0/0)
- Consider limiting `source_ranges` in the firewall rule
- Container runs as non-root user
- Uses Container-Optimized OS for enhanced security

## Contributing

Feel free to submit issues and pull requests!

## License

[MIT License](LICENSE)

## Author

[Rishab Kumar](https://rishabkumar.com)
