
# Data Dictionary

## Telecom Customer Churn Prediction and Retention Optimization

## 1. Dataset Overview

- Source: UCI Iranian Customer Churn Dataset
- Original records: 3,150
- Original columns: 14
- Cleaned columns: 16
- Missing values: 0
- Dataset: data/processed/telecom_churn_cleaned.csv

## 2. Column Definitions

| Column Name | SQL Data Type | Description |
|---|---|---|
| record_id | VARCHAR(10) | Generated unique record identifier |
| call_failures | INTEGER | Number of failed calls |
| has_complaint | SMALLINT | Customer complaint indicator |
| subscription_months | INTEGER | Subscription duration in months |
| charge_amount | SMALLINT | Relative charge category |
| call_duration_seconds | INTEGER | Total call duration in seconds |
| call_frequency | INTEGER | Total number of calls |
| sms_frequency | INTEGER | Total number of text messages |
| distinct_called_numbers | INTEGER | Number of distinct called numbers |
| age_group | SMALLINT | Customer age category |
| tariff_plan | SMALLINT | Customer tariff plan |
| status | SMALLINT | Customer activity status |
| age | INTEGER | Additional age representation |
| customer_value | NUMERIC | Calculated customer value |
| churn | SMALLINT | Customer churn outcome |
| is_duplicate_record | SMALLINT | Identical record indicator |

## 3. Categorical Variable Definitions

### has_complaint
- 0: No complaint
- 1: Complaint

### charge_amount
- Observed categories: 0 to 10
- Lower values represent lower charge categories.
- Category 10 is retained despite the original
  documentation specifying a range of 0 to 9.
- Values do not represent actual monetary charges.

### age_group
- 1: Youngest age group
- 2: Age group 2
- 3: Age group 3
- 4: Age group 4
- 5: Oldest age group

### tariff_plan
- 1: Pay-as-you-go
- 2: Contractual

### status
- 1: Active
- 2: Non-active

### churn
- 0: Non-churned
- 1: Churned

### is_duplicate_record
- 0: Record has no identical source record
- 1: Record belongs to an identical-record group

## 4. Primary Key

record_id

The identifier is generated during data preparation.
It represents a dataset observation rather than a
verified real-world customer ID.

## 5. Target Variable

churn

This variable will be used as the outcome in
statistical analysis and classification models.

## 6. Data Quality Rules

- Record identifiers must be unique.
- Required fields must not contain null values.
- Numerical customer attributes must be non-negative.
- Binary variables must contain valid binary values.
- Categorical variables must contain permitted values.
- Charge categories must be within the observed range.
- Original dataset records must be preserved.

## 7. Machine Learning Considerations

- record_id must not be used as a predictive feature.
- is_duplicate_record is used for auditing only.
- Identical predictor records must be grouped during
  training and testing dataset splitting.
- Status and customer value must be investigated
  for potential target leakage.
- Age and age group must be investigated for redundant
  information and unclear encoding.
- Class imbalance must be considered during evaluation.

## 8. Dataset Limitations

- Customer value is not confirmed monetary revenue.
- Exact encoding of the additional age field requires
  further investigation.
- Actual customer identifiers are unavailable.
- Actual retention campaign outcomes are unavailable.
- The dataset is not from a Sri Lankan company.

## 9. Source

UCI Machine Learning Repository
Iranian Churn Dataset

https://archive.ics.uci.edu/dataset/563/iranian+churn+dataset
