# Marketing Data Platform | Databricks + dbt

An end-to-end marketing analytics data platform built using **Databricks, dbt, Python, GitHub Actions, and Elementary** to transform raw Facebook Ads and Snapchat Ads data into a unified, governed, and tested analytical dataset.

## 1. Project Overview

Marketing teams often manage advertising performance across multiple platforms, each with different data structures, naming conventions, and reporting formats.

This creates challenges in comparing campaign performance, monitoring advertising spend, and producing reliable cross-platform analytics.

This project addresses those challenges by building a centralized marketing data platform that:

- Ingests and stores raw advertising datasets in Databricks.
- Standardizes Facebook and Snapchat advertising data using dbt.
- Combines both platforms into a unified marketing performance model.
- Implements automated data-quality checks and observability.
- Separates development, CI, and production environments.
- Automates validation and production deployment using GitHub Actions.
- Enforces controlled access through Unity Catalog and Service Principal authentication.

The resulting dataset supports marketing reporting, BI dashboards, SQL analysis, and other future analytics applications.

## 2. Technology Stack

| Technology | Purpose |
|---|---|
| Databricks | Lakehouse platform, Delta tables, SQL processing |
| Unity Catalog | Data governance and access control |
| dbt Core | SQL transformations, modeling, testing and documentation |
| Python + uv | Python environment and dependency management |
| Elementary | dbt observability and data-quality monitoring |
| Git + GitHub | Source control and collaboration |
| GitHub Actions | Continuous integration and deployment |
| OAuth Service Principals | Secure non-personal authentication for CI and production |

## 3. Architecture

The pipeline follows a layered data architecture.

```text
     Facebook Ads          Snapchat Ads
          |                     |
          +----------+----------+
                     |
                     v
             Raw Advertising Data
                     |
                     v
          Databricks / Delta Lake
                Bronze Layer
                     |
                     v
              dbt Staging Layer
          Cleaning & Standardization
                     |
                     v
            dbt Intermediate Layer
       Enrichment, Joins & Deduplication
                     |
                     v
             Unified Fact Table
          fct_marketing_performance
                     |
          +----------+-----------+
          |          |           |
          v          v           v
      SQL Analysis   BI      Analytics
```

### Data layers

**Bronze:** Stores the original advertising datasets as Delta tables.

**Staging:** Standardizes column names, data types, identifiers, currencies, dates, and metrics.

**Intermediate:** Applies reusable business logic, dimension enrichment, and deduplication.

**Marts:** Publishes the unified marketing performance fact table for downstream analysis.

## 4. Source Data

The platform integrates nine source tables.

| Platform | Source tables |
|---|---|
| Facebook Ads | `facebook_accounts`, `facebook_campaigns`, `facebook_adgroups`, `facebook_ads`, `facebook_ads_stats` |
| Snapchat Ads | `snapchat_campaigns`, `snapchat_adgroups`, `snapchat_ads`, `snapchat_ads_stats` |

The source datasets are stored in Databricks as Delta tables and referenced using dbt sources.

The production raw tables are stored under:

`bronze_production.marketing_raw`

For this case study, the production raw tables were populated from the development Bronze datasets using Databricks Delta cloning.

**Scope:** This implementation demonstrates batch-based analytics over provided advertising datasets. It does not yet implement continuous ingestion from the live Facebook or Snapchat APIs.

## 5. Data Modeling

The dbt project implements staging, intermediate, and mart models.

## Staging models

Staging transformations:

- Standardize identifiers and naming conventions.
- Convert raw metric fields into appropriate numeric types.
- Normalize dates and currency codes.
- Handle invalid numeric strings and missing values.
- Retain platform-specific records without premature aggregation.

### Intermediate models

The intermediate layer provides enriched advertising performance datasets for each platform.

A key challenge involved **Snapchat ad-group history**.

The source contained 267 ad-group records, including multiple historical versions of some identifiers. Joining against these records without deduplication caused row multiplication.

The `int_snapchat_latest_adgroups` model uses `ROW_NUMBER()` to select the latest record for each ad group.

This produces 264 distinct ad groups and prevents duplicated historical records from inflating downstream metrics.

### Final analytical model

**Model:** `fct_marketing_performance`

**Grain:** One record per platform, advertisement, date, country, and currency combination.

The fact table integrates Facebook and Snapchat metrics into a consistent structure.

Key analytical fields include platform, advertisement identifiers, campaign information, reporting date, currency, spend, impressions, clicks, and derived performance metrics.

### Marketing metrics

| Metric | Definition |
|---|---|
| Spend | Advertising expenditure in the source currency |
| Impressions | Number of ad impressions |
| Clicks | Number of clicks recorded on an ad |
| CTR | Clicks / Impressions |
| CPC | Spend / Clicks |
| CPM | Spend / Impressions × 1,000 |

Currency is retained in the final model. Advertising spend in different currencies should not be summed into a single monetary total without currency conversion.

## 6. Data Quality and Validation

dbt data tests validate the reliability of the analytical models.

Implemented checks include:

- Unique marketing performance keys.
- Non-null primary identifiers.
- Non-null reporting dates and platform values.
- Accepted advertising platform values.
- Currency-code presence.
- Non-negative marketing performance metrics.

Additional reconciliation checks were done between the original performance datasets and the unified fact table to verify row counts and aggregated metrics.

### Validated production results

| Platform | Performance records | Unique records |
|---|---:|---:|
| Facebook | 92,300 | 92,300 |
| Snapchat | 2,809 | 2,809 |
| **Total** | **95,109** | **95,109** |

These results confirm that the deployed unified fact table preserves the expected performance records without duplicate fact keys.

## 7. Environment Separation

The platform uses three dedicated Databricks environments.

| Environment | Catalog | Target schema | Purpose |
|---|---|---|---|
| Development | `marketing_development` | `dbt_dev` | Model development and debugging |
| CI | `ci_development` | `marketing_ci` | Automated validation |
| Production | `bronze_production` | `marketing_marts` | Published analytical models |

Production and CI authentication use dedicated Databricks Service Principals rather than personal access tokens.

Unity Catalog permissions control access to source datasets and model destinations.

The CI identity has access to its dedicated validation environment and read-only access to the required production raw sources.

The production identity is used for deployment into the production analytics schema.

## 8. CI/CD with GitHub Actions

Two GitHub Actions workflows automate the software delivery lifecycle.

### Continuous Integration

**Workflow:** `.github/workflows/dbt-ci.yml`

Triggered by pull requests targeting `main`.

The workflow:

1. Checks out the repository.
2. Installs Python and uv dependencies.
3. Configures dbt using CI credentials stored in GitHub Secrets.
4. Validates the Databricks connection.
5. Compiles dbt models.
6. Builds the selected models and executes automated tests.

Failed builds or tests prevent the CI check from passing.

### Continuous Deployment

**Workflow:** `.github/workflows/dbt-prod.yml`

Triggered when changes are merged into `main`, with support for manual execution.

The workflow:

1. Authenticates using the production Service Principal.
2. Validates the production connection.
3. Compiles the production dbt models.
4. Builds the unified marketing analytics pipeline.
5. Executes automated data-quality tests.
6. Generates dbt documentation.

Production credentials are stored in a GitHub production environment.

### Delivery workflow

```text
Feature Branch
      |
      v
Pull Request
      |
      v
GitHub Actions CI
      |
      v
dbt Compile + Build + Tests
      |
      v
Merge to Main
      |
      v
GitHub Actions CD
      |
      v
Databricks Production
```

The current CI implementation uses a shared CI schema, with workflow concurrency controls to avoid overlapping builds.

## 9. Observability with Elementary

Elementary is integrated into dbt to provide visibility into model execution and data quality.

It supports:

- Monitoring dbt test outcomes.
- Inspecting model and test execution results.
- Reviewing data-quality issues.
- Generating observability reports.
- Supporting investigation of model failures and anomalies.

Elementary monitoring models have been initialized in development and production.

The development environment also supports HTML observability report generation through the Elementary CLI.

## 10. Local Setup

### Prerequisites

- Python 3.12
- uv
- Databricks workspace access
- Databricks SQL Warehouse
- Unity Catalog permissions
- Valid Databricks authentication credentials

### Clone the repository

```bash
git clone https://github.com/Emeriii/marketing-data-platform.git
cd marketing-data-platform
```

### Install dependencies

```bash
uv sync --locked
```

### Install dbt packages

```bash
uv run dbt deps --project-dir marketing_dbt
```

### Configure authentication

Create a local dbt profile at:

`~/.dbt/profiles.yml`

The profile should be named `marketing_dbt` and contain an appropriate target (`dev`, `ci`, or `prod`).

Use environment variables or another secure secret-management mechanism for credentials.

Never commit passwords, Personal Access Tokens, OAuth client secrets, or `.env` files.

### Validate the connection

```bash
uv run dbt debug --project-dir marketing_dbt --target dev
```

### Build development models

```bash
uv run dbt build \
  --project-dir marketing_dbt \
  --target dev \
  --select +fct_marketing_performance \
  --vars '{"source_catalog":"marketing_development","source_schema":"bronze"}'
```

### Generate documentation

```bash
uv run dbt docs generate \
  --project-dir marketing_dbt \
  --target dev
```

```bash
uv run dbt docs serve \
  --project-dir marketing_dbt \
  --port 8080
```

## 11. Example Business Queries

### Advertising spend by platform and currency

```sql
SELECT
    platform,
    currency_code,
    SUM(spend) AS total_spend
FROM bronze_production.marketing_marts.fct_marketing_performance
GROUP BY platform, currency_code
ORDER BY platform, currency_code;
```

### Campaign performance

```sql
SELECT
    platform,
    campaign_id,
    currency_code,
    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks
FROM bronze_production.marketing_marts.fct_marketing_performance
GROUP BY platform, campaign_id, currency_code
ORDER BY total_spend DESC;
```

### Daily advertising performance

```sql
SELECT
    ad_date,
    platform,
    currency_code,
    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks
FROM bronze_production.marketing_marts.fct_marketing_performance
GROUP BY ad_date, platform, currency_code
ORDER BY ad_date, platform;
```

## 12. Engineering Decisions

**Views for staging and intermediate models:** These models favor reusable transformation logic and avoid unnecessary storage duplication.

**Table materialization for the final mart:** The unified analytical model is persisted to support predictable downstream reporting and query performance.

**Deduplication before enrichment:** Snapchat historical records are resolved before joining to advertising performance data, preventing unwanted row multiplication.

**Currency-aware analytics:** Original currencies are preserved rather than incorrectly combining spend across currencies.

**Separate service principals:** CI and production use distinct identities to reduce the risk of automated validation accessing production write operations.

**Environment-specific sources:** dbt variables make it possible to use the same transformation code against different configured source environments.

**Automated deployment:** CI/CD provides a repeatable process for validating code changes and publishing production transformations.

## 13. Limitations and Future Improvements

Potential enhancements include:

- Introducing incremental materialization for large performance datasets.
- Adding live API ingestion for Facebook Ads and Snapchat Ads.
- Implementing scheduled ingestion and refresh workflows.
- Using isolated per-pull-request CI schemas.
- Extending automated source freshness and referential integrity tests.
- Configuring additional Elementary anomaly-detection monitors.
- Implementing currency conversion using a governed exchange-rate source.
- Building a Power BI dashboard on the unified fact table.
- Exploring Databricks workload identity federation for GitHub Actions authentication.

## 14. Project Outcome

This project demonstrates the design and implementation of a production-oriented analytics workflow using modern data engineering practices.

The resulting platform centralizes advertising data from Facebook and Snapchat, applies reusable dbt transformations, publishes a validated analytical model, and automates testing and deployment across separated environments.

The project demonstrates practical experience with data modeling, Databricks, Unity Catalog, dbt, data quality, observability, authentication, and CI/CD.

---

**Author:** Emeri David

**Repository:** https://github.com/Emeriii/marketing-data-platform
