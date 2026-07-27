# Threat Detection (AWS GuardDuty)

The infrastructure uses AWS GuardDuty for threat detection and security monitoring within the AWS accounts. GuardDuty is enabled by default to continuously analyze the following data sources:

- **AWS CloudTrail event logs** - API calls and user activities
- **Amazon VPC Flow Logs** - Network traffic patterns
- **DNS logs** - Domain name resolution requests

## Accessing GuardDuty Findings

**AWS Console:**

- Navigate to GuardDuty Console -> Findings
- Filter by finding type, severity, or resource
- View detailed finding information and evidence

## Configuration

**Threat detection is enabled by default** for all environments in the configured default region. The configuration can be customized through Terraform variables in the accounts layer.

Note: Amazon GuardDuty is a regional service. Enabling threat detection will activate GuardDuty only in the configured default region.

### Available Configuration Options

| Variable                                        | Description                                                 | Default             | Options                                          |
| ----------------------------------------------- | ----------------------------------------------------------- | ------------------- | ------------------------------------------------ |
| `enable_threat_detection`                       | Enable/disable GuardDuty threat detection                   | `true`              | `true`, `false`                                  |
| `threat_detection_finding_publishing_frequency` | How often GuardDuty publishes findings to CloudWatch Events | `"FIFTEEN_MINUTES"` | `"FIFTEEN_MINUTES"`, `"ONE_HOUR"`, `"SIX_HOURS"` |

### Setting Threat Detection Configuration

Edit your Terraform workspace configuration file for the account layer, `infra/project-config/threat_detection.tf`.

To disable AWS GuardDuty threat detection:

- Set the threat detection variable to `false`:

  ```hcl
  enable_threat_detection = false
  ```

To set publishing frequency:

- Set finding publishing frequency (FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS):
  ```hcl
  threat_detection_finding_publishing_frequency = "FIFTEEN_MINUTES"
  ```

Apply the changes:

```bash
make infra-update-current-account
```
