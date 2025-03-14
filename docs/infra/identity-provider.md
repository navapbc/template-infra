# Identity Provider

Some applications need their own user authentication system when they can't rely solely on SSO through an external identity provider. This document describes how to configure an identity provider using Amazon Cognito. The identity provider setup process will:

1. Create an Amazon Cognito user pool and user pool client for managing user accounts
2. Set up the necessary environment variables for the application service

## Requirements

While not strictly required, it's recommended to [set up notifications](./notifications.md) first. Without notifications configured, account verification and password reset emails will use Cognito's default email configuration, which has daily email sending limits.

## 1. Enable identity provider in application config

Update `enable_identity_provider = true` in your application's `app-config` module (`infra/<APP_NAME>/app-config/main.tf`).

## 2. Configure identity provider settings

The identity provider configuration is defined in the environment config module in `infra/<APP_NAME>/app-config/env-config/identity_provider.tf`. You can customize the following settings:

- `callback_url_path`: Path fragment for post-login redirect (optional)
- `logout_url_path`: Path fragment for post-logout redirect (optional)
- `password_policy`: Customize password requirements
  - `password_minimum_length`: Minimum password length
  - `temporary_password_validity_days`: Days until temporary passwords expire
- `verification_email`: Customize verification email content
  - `verification_email_message`: Custom message content
  - `verification_email_subject`: Custom email subject

## 3. Deploy the identity provider

Run the following command:

```bash
make infra-update-app-service APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT>
```
