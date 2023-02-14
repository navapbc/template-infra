# mtde-rds-aurora
This component creates the AWS RDS Aurora PostgreSQL cluster for MTDE. Aurora Serverless V2 instances are created for this cluster.

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | 1.0.2   |
| aws       | 4.54.0  |
| template  | 2.1.0   |

## Providers

| Name      | Version |
| --------- | ------- |
| terraform | n/a     |

## Modules

| Name              | Source                                     | Version |
| ----------------- | ------------------------------------------ | ------- |
| gdit\_vpc\_data   | ../../../modules/network-v3-0.12/terraform | n/a     |
| mtde\_rds\_aurora | ../../../modules/tf-rds-aurora/terraform   | n/a     |

## Resources

| Name                                                                                                                               | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [terraform_remote_state.common](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name                           | Description                                                    | Type           | Default                    | Required |
| ------------------------------ | -------------------------------------------------------------- | -------------- | -------------------------- | :------: |
| allow\_gdit\_vpn\_access       | Boolean value determining if the GDIT cidr should be allowed   | `bool`         | `false`                    |    no    |
| aws\_region                    | The region to deploy to                                        | `any`          | n/a                        |   yes    |
| db\_engine\_major\_version     | The major version of the of the RDS instance                   | `string`       | `"13"`                     |    no    |
| db\_engine\_version            | The engine version of the RDS instance                         | `string`       | `"13.6"`                   |    no    |
| db\_instance\_class            | Instance class of the database                                 | `string`       | n/a                        |   yes    |
| enable\_pg\_cron               | Enable pg\_cron extention for Aurora DB                        | `bool`         | `false`                    |    no    |
| environment\_name              | The name of the environment                                    | `any`          | n/a                        |   yes    |
| ingress\_cidrs                 | List of cidrs allowed access to cluster                        | `list(any)`    | `[]`                       |    no    |
| instance\_count                | Number of DB instances for the Aurora cluster                  | `number`       | `2`                        |    no    |
| performance\_insights\_enabled | Specifies whether performance Insight is enabled               | `bool`         | `false`                    |    no    |
| security\_group\_ids           | List of security groups allowed access to cluster              | `list(string)` | `[]`                       |    no    |
| snapshot\_identifier           | The snapshot identifier name                                   | `string`       | `""`                       |    no    |
| tf\_state\_bucket              | state bucket                                                   | `any`          | n/a                        |   yes    |
| update\_password               | Whether to update the master password when instance is created | `bool`         | `false`                    |    no    |
| vpc\_name                      | The name of the vpc                                            | `any`          | n/a                        |   yes    |
| vpc\_type                      | the type of the vpc                                            | `any`          | n/a                        |   yes    |
| vpn\_cidr                      | CIDRs to allow for GDIT connections                            | `list`         | ```[ "10.232.32.0/19" ]``` |    no    |

## Outputs

| Name     | Description                                  |
| -------- | -------------------------------------------- |
| endpoint | The endpoint of the MTDE RDS Aurora instance |
