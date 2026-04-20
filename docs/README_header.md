# Azure Landing Zone Identity (Service Principals & RBAC)

**IMPORTANT NOTE:** This code must be run *after* the `Azure-ConseilsTI-Core` repository has been fully deployed, as it relies on the core management group structure and foundational resources established there.

## Purpose

This project provisions and configures the identity access layer (Service Principals, Custom Roles, and Role Assignments) for the Azure Landing Zone (Connectivity, Identity, and Management subscriptions) to enforce strict Principle of Least Privilege (PoLP) and separation of duties.

## Features

- **Platform Subscription Access:** Automates the creation of Service Principals and RBAC for specific subscription boundaries (Connectivity, Identity, Management).
- **Separation of Duties:** Delineates between Network administrators, IAM administrators, and Security/Management administrators.
- **Granular Network Access:** Implements roles that restrict broader virtual network modification but permit localized Private Endpoint creation and subnet joins.
- **Management Group Governance:** Configures roles allowing Policy and Management operations at the Management Group tier to enforce guardrails across subscriptions.

## Permissions

The deployment Service Principal running this Terraform code requires the following elevated permissions at the root or target Management Group scope:
- **User Access Administrator** (to create and assign role assignments)
- **Role Based Access Control Administrator** (for custom role definitions)
- Azure AD/Entra ID permissions to create and manage enterprise applications/service principals (e.g., Application Administrator).

## Authentications

- Support for Dynamic Provider Credentials via HCP Terraform or OIDC in GitHub Actions.
- Requires both `azurerm` and `azuread` providers to be configured with appropriate tenant and client IDs.
