# HireVoice Terraform

Terraform infrastructure for the HireVoice personal AWS account deployment.

## Layout

- `bootstrap/remote-state`: S3 and DynamoDB backend bootstrap resources.
- `envs/dev/phase1`: Core AWS infrastructure for the dev environment.
- `envs/dev/phase2`: Cluster add-ons, observability, and backup resources.

## Safety

Do not commit local Terraform state, plan files, `.terraform/`, or real tfvars files.
Use GitHub Actions or local Terraform with the configured remote backend.
