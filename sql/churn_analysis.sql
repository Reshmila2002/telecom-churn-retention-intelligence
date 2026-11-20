
-- Project: Telecom Customer Churn and Retention Optimization
-- Database: telecom_churn_db
-- Purpose: Identify customer churn patterns and associated factors


-- 1. Overall churn and retention KPIs

SELECT
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    COUNT(*) - SUM(churn) AS retained_customers,
    ROUND(AVG(churn) * 100, 2) AS churn_rate,
    ROUND((1 - AVG(churn)) * 100, 2) AS retention_rate
FROM public.customers;


-- 2. Churn by tariff plan

SELECT
    CASE
        WHEN tariff_plan = 1 THEN 'Pay-as-you-go'
        ELSE 'Contractual'
    END AS tariff_type,

    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(AVG(churn) * 100, 2) AS churn_rate

FROM public.customers
GROUP BY tariff_plan
ORDER BY churn_rate DESC;


-- 3. Churn by customer complaints

SELECT
    CASE
        WHEN has_complaint = 1 THEN 'Complaint'
        ELSE 'No Complaint'
    END AS complaint_status,

    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(AVG(churn) * 100, 2) AS churn_rate

FROM public.customers
GROUP BY has_complaint
ORDER BY churn_rate DESC;


-- 4. Churn by age group

SELECT
    age_group,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(AVG(churn) * 100, 2) AS churn_rate

FROM public.customers
GROUP BY age_group
ORDER BY churn_rate DESC;


-- 5. Churn by subscription duration

WITH tenure_segments AS (

    SELECT
        *,
        CASE
            WHEN subscription_months < 12 THEN 'Under 1 year'
            WHEN subscription_months < 24 THEN '1-2 years'
            WHEN subscription_months < 36 THEN '2-3 years'
            ELSE '3+ years'
        END AS tenure_segment

    FROM public.customers

)

SELECT
    tenure_segment,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(AVG(churn) * 100, 2) AS churn_rate,
    ROUND(AVG(subscription_months), 2) AS avg_tenure

FROM tenure_segments
GROUP BY tenure_segment
ORDER BY avg_tenure;


-- 6. Churn by customer activity status

SELECT
    CASE
        WHEN status = 1 THEN 'Active'
        ELSE 'Non-active'
    END AS customer_status,

    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(AVG(churn) * 100, 2) AS churn_rate

FROM public.customers
GROUP BY status
ORDER BY churn_rate DESC;


-- 7. Churn by call failure level

WITH failure_segments AS (

    SELECT
        *,
        CASE
            WHEN call_failures = 0 THEN 'No Failures'
            WHEN call_failures <= 5 THEN 'Low Failures'
            WHEN call_failures <= 15 THEN 'Medium Failures'
            ELSE 'High Failures'
        END AS failure_level

    FROM public.customers

)

SELECT
    failure_level,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(AVG(churn) * 100, 2) AS churn_rate

FROM failure_segments
GROUP BY failure_level
ORDER BY churn_rate DESC;


-- 8. Compare service usage by churn status

SELECT
    CASE
        WHEN churn = 1 THEN 'Churned'
        ELSE 'Non-Churned'
    END AS customer_status,

    COUNT(*) AS total_customers,
    ROUND(AVG(call_frequency), 2) AS avg_call_frequency,
    ROUND(AVG(sms_frequency), 2) AS avg_sms_frequency,
    ROUND(AVG(call_duration_seconds) / 60, 2) AS avg_call_minutes,
    ROUND(AVG(call_failures), 2) AS avg_call_failures,
    ROUND(AVG(customer_value), 2) AS avg_customer_value

FROM public.customers
GROUP BY churn;


-- 9. Churn by customer value quartile

WITH value_segments AS (

    SELECT
        *,
        NTILE(4) OVER (
            ORDER BY customer_value, record_id
        ) AS value_quartile

    FROM public.customers

)

SELECT
    value_quartile,

    CASE
        WHEN value_quartile = 1 THEN 'Low Value'
        WHEN value_quartile = 2 THEN 'Medium-Low Value'
        WHEN value_quartile = 3 THEN 'Medium-High Value'
        ELSE 'High Value'
    END AS value_segment,

    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(AVG(churn) * 100, 2) AS churn_rate,
    ROUND(AVG(customer_value), 2) AS avg_customer_value

FROM value_segments
GROUP BY value_quartile
ORDER BY value_quartile;


-- 10. Combined complaint and tariff plan analysis

SELECT
    CASE
        WHEN tariff_plan = 1 THEN 'Pay-as-you-go'
        ELSE 'Contractual'
    END AS tariff_type,

    CASE
        WHEN has_complaint = 1 THEN 'Complaint'
        ELSE 'No Complaint'
    END AS complaint_status,

    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(AVG(churn) * 100, 2) AS churn_rate

FROM public.customers
GROUP BY tariff_plan, has_complaint
ORDER BY churn_rate DESC;


-- 11. Compare complaint segment churn with overall churn

WITH overall AS (

    SELECT AVG(churn) * 100 AS overall_churn_rate
    FROM public.customers

),

segment_analysis AS (

    SELECT
        has_complaint,
        COUNT(*) AS total_customers,
        AVG(churn) * 100 AS segment_churn_rate

    FROM public.customers
    GROUP BY has_complaint

)

SELECT
    CASE
        WHEN has_complaint = 1 THEN 'Complaint'
        ELSE 'No Complaint'
    END AS complaint_status,

    total_customers,
    ROUND(segment_churn_rate, 2) AS segment_churn_rate,
    ROUND(overall_churn_rate, 2) AS overall_churn_rate,

    ROUND(
        segment_churn_rate - overall_churn_rate, 2
    ) AS difference_percentage_points,

    ROUND(
        segment_churn_rate /
        NULLIF(overall_churn_rate, 0), 2
    ) AS relative_churn_rate

FROM segment_analysis
CROSS JOIN overall
ORDER BY segment_churn_rate DESC;


-- 12. Historical customer value associated with churn

SELECT
    COUNT(*) FILTER (
        WHERE churn = 1
    ) AS churned_customers,

    ROUND(SUM(customer_value), 2) AS total_customer_value,

    ROUND(
        SUM(customer_value) FILTER (WHERE churn = 1), 2
    ) AS churned_customer_value,

    ROUND(
        100.0 * SUM(customer_value) FILTER (WHERE churn = 1)
        / NULLIF(SUM(customer_value), 0),
        2
    ) AS churned_value_percentage

FROM public.customers;
