
-- Project: Telecom Customer Churn and Retention Optimization
-- Database: telecom_churn_db
-- Purpose: Database data quality validation


-- 1. Verify total records and unique identifiers

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT record_id) AS unique_records,
    COUNT(*) - COUNT(DISTINCT record_id) AS duplicate_ids
FROM public.customers;


-- 2. Check missing values across all columns

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE record_id IS NULL
            OR call_failures IS NULL
            OR has_complaint IS NULL
            OR subscription_months IS NULL
            OR charge_amount IS NULL
            OR call_duration_seconds IS NULL
            OR call_frequency IS NULL
            OR sms_frequency IS NULL
            OR distinct_called_numbers IS NULL
            OR age_group IS NULL
            OR tariff_plan IS NULL
            OR status IS NULL
            OR age IS NULL
            OR customer_value IS NULL
            OR churn IS NULL
            OR is_duplicate_record IS NULL
    ) AS records_with_missing_values
FROM public.customers;


-- 3. Validate categorical variables

SELECT
    COUNT(*) FILTER (
        WHERE has_complaint NOT IN (0, 1)
    ) AS invalid_complaints,

    COUNT(*) FILTER (
        WHERE age_group NOT BETWEEN 1 AND 5
    ) AS invalid_age_groups,

    COUNT(*) FILTER (
        WHERE tariff_plan NOT IN (1, 2)
    ) AS invalid_tariff_plans,

    COUNT(*) FILTER (
        WHERE status NOT IN (1, 2)
    ) AS invalid_status,

    COUNT(*) FILTER (
        WHERE churn NOT IN (0, 1)
    ) AS invalid_churn_values,

    COUNT(*) FILTER (
        WHERE charge_amount NOT BETWEEN 0 AND 10
    ) AS invalid_charge_categories,

    COUNT(*) FILTER (
        WHERE is_duplicate_record NOT IN (0, 1)
    ) AS invalid_duplicate_flags

FROM public.customers;


-- 4. Check negative numerical values

SELECT
    COUNT(*) FILTER (
        WHERE call_failures < 0
            OR subscription_months < 0
            OR call_duration_seconds < 0
            OR call_frequency < 0
            OR sms_frequency < 0
            OR distinct_called_numbers < 0
            OR age < 0
            OR customer_value < 0
    ) AS invalid_numerical_records
FROM public.customers;


-- 5. Investigate repeated source records

SELECT
    is_duplicate_record,
    COUNT(*) AS record_count
FROM public.customers
GROUP BY is_duplicate_record
ORDER BY is_duplicate_record;


-- 6. Investigate charge category distribution

SELECT
    charge_amount,
    COUNT(*) AS customer_count
FROM public.customers
GROUP BY charge_amount
ORDER BY charge_amount;


-- 7. Verify churn distribution

SELECT
    CASE
        WHEN churn = 1 THEN 'Churned'
        ELSE 'Non-Churned'
    END AS customer_status,

    COUNT(*) AS customer_count,

    ROUND(
        COUNT(*) * 100.0 /
        NULLIF((SELECT COUNT(*) FROM public.customers), 0),
        2
    ) AS percentage

FROM public.customers
GROUP BY churn
ORDER BY churn;


-- 8. Final database quality summary

SELECT
    COUNT(*) AS total_customers,

    COUNT(DISTINCT record_id) AS unique_records,

    COUNT(*) FILTER (
        WHERE churn = 1
    ) AS churned_customers,

    COUNT(*) FILTER (
        WHERE churn = 0
    ) AS non_churned_customers,

    ROUND(AVG(churn) * 100, 2) AS churn_rate,

    ROUND((1 - AVG(churn)) * 100, 2) AS retention_rate

FROM public.customers;

