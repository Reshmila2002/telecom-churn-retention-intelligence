
-- Project: Telecom Customer Churn and Retention Optimization
-- Database: telecom_churn_db
-- Purpose: Reusable reporting views for business intelligence


-- VIEW 1: Executive customer KPIs

CREATE OR REPLACE VIEW public.vw_executive_kpis AS

SELECT
    COUNT(*) AS total_customers,

    SUM(churn) AS churned_customers,

    COUNT(*) - SUM(churn) AS retained_customers,

    ROUND(AVG(churn) * 100, 2) AS churn_rate,

    ROUND((1 - AVG(churn)) * 100, 2) AS retention_rate,

    ROUND(AVG(customer_value), 2) AS avg_customer_value,

    ROUND(AVG(subscription_months), 2) AS avg_subscription_months,

    ROUND(AVG(has_complaint) * 100, 2) AS complaint_rate,

    ROUND(AVG(call_failures), 2) AS avg_call_failures

FROM public.customers;


-- VIEW 2: Customer-level reporting dataset

CREATE OR REPLACE VIEW public.vw_customer_details AS

SELECT
    c.*,

    CASE
        WHEN churn = 1 THEN 'Churned'
        ELSE 'Non-Churned'
    END AS churn_status,

    CASE
        WHEN tariff_plan = 1 THEN 'Pay-as-you-go'
        ELSE 'Contractual'
    END AS tariff_type,

    CASE
        WHEN status = 1 THEN 'Active'
        ELSE 'Non-active'
    END AS activity_status,

    CASE
        WHEN has_complaint = 1 THEN 'Complaint'
        ELSE 'No Complaint'
    END AS complaint_status,

    CASE
        WHEN subscription_months < 12 THEN 'Under 1 year'
        WHEN subscription_months < 24 THEN '1-2 years'
        WHEN subscription_months < 36 THEN '2-3 years'
        ELSE '3+ years'
    END AS tenure_segment,

    CASE
        WHEN call_failures = 0 THEN 'No Failures'
        WHEN call_failures <= 5 THEN 'Low Failures'
        WHEN call_failures <= 15 THEN 'Medium Failures'
        ELSE 'High Failures'
    END AS failure_level,

    ROUND(
        call_duration_seconds / 60.0, 2
    ) AS call_duration_minutes

FROM public.customers AS c;


-- VIEW 3: Churn by tariff plan

CREATE OR REPLACE VIEW public.vw_tariff_churn AS

SELECT
    tariff_type,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(AVG(churn) * 100, 2) AS churn_rate,
    ROUND(AVG(customer_value), 2) AS avg_customer_value

FROM public.vw_customer_details
GROUP BY tariff_type;


-- VIEW 4: Customer complaints and churn

CREATE OR REPLACE VIEW public.vw_complaint_churn AS

SELECT
    complaint_status,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(AVG(churn) * 100, 2) AS churn_rate,
    ROUND(AVG(call_failures), 2) AS avg_call_failures

FROM public.vw_customer_details
GROUP BY complaint_status;


-- VIEW 5: Subscription duration and churn

CREATE OR REPLACE VIEW public.vw_tenure_churn AS

SELECT
    tenure_segment,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(AVG(churn) * 100, 2) AS churn_rate,
    ROUND(AVG(customer_value), 2) AS avg_customer_value

FROM public.vw_customer_details
GROUP BY tenure_segment;


-- VIEW 6: Service quality and churn

CREATE OR REPLACE VIEW public.vw_service_quality AS

SELECT
    failure_level,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(AVG(churn) * 100, 2) AS churn_rate,
    ROUND(AVG(has_complaint) * 100, 2) AS complaint_rate,
    ROUND(AVG(call_frequency), 2) AS avg_call_frequency

FROM public.vw_customer_details
GROUP BY failure_level;


-- VIEW 7: Customer value segmentation

CREATE OR REPLACE VIEW public.vw_customer_value_segments AS

WITH ranked_customers AS (

    SELECT
        record_id,
        customer_value,
        churn,

        NTILE(4) OVER (
            ORDER BY customer_value, record_id
        ) AS value_quartile

    FROM public.customers

)

SELECT
    record_id,
    customer_value,
    churn,
    value_quartile,

    CASE
        WHEN value_quartile = 1 THEN 'Low Value'
        WHEN value_quartile = 2 THEN 'Medium-Low Value'
        WHEN value_quartile = 3 THEN 'Medium-High Value'
        ELSE 'High Value'
    END AS value_segment

FROM ranked_customers;


-- VIEW 8: Customer value segment performance

CREATE OR REPLACE VIEW public.vw_value_segment_summary AS

SELECT
    value_quartile,
    value_segment,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(AVG(churn) * 100, 2) AS churn_rate,
    ROUND(AVG(customer_value), 2) AS avg_customer_value,
    ROUND(SUM(customer_value), 2) AS total_customer_value

FROM public.vw_customer_value_segments
GROUP BY value_quartile, value_segment;
