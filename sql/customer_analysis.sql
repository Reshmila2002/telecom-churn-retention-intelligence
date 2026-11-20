
-- Project: Telecom Customer Churn and Retention Optimization
-- Database: telecom_churn_db
-- Purpose: Customer business analysis


-- 1. Overall customer KPIs

SELECT
    COUNT(*) AS total_customers,
    ROUND(AVG(subscription_months), 2) AS avg_subscription_months,
    ROUND(AVG(customer_value), 2) AS avg_customer_value,
    ROUND(AVG(call_failures), 2) AS avg_call_failures,
    ROUND(AVG(has_complaint) * 100, 2) AS complaint_rate
FROM public.customers;


-- 2. Customer distribution by age group

SELECT
    age_group,
    COUNT(*) AS customer_count,
    ROUND(AVG(customer_value), 2) AS avg_customer_value,
    ROUND(AVG(subscription_months), 2) AS avg_subscription_months
FROM public.customers
GROUP BY age_group
ORDER BY age_group;


-- 3. Customer distribution by tariff plan

SELECT
    CASE
        WHEN tariff_plan = 1 THEN 'Pay-as-you-go'
        WHEN tariff_plan = 2 THEN 'Contractual'
    END AS tariff_type,

    COUNT(*) AS customer_count,

    ROUND(
        COUNT(*) * 100.0 /
        NULLIF((SELECT COUNT(*) FROM public.customers), 0),
        2
    ) AS customer_percentage,

    ROUND(AVG(customer_value), 2) AS avg_customer_value

FROM public.customers
GROUP BY tariff_plan
ORDER BY customer_count DESC;


-- 4. Customer activity status

SELECT
    CASE
        WHEN status = 1 THEN 'Active'
        WHEN status = 2 THEN 'Non-active'
    END AS customer_status,

    COUNT(*) AS customer_count,

    ROUND(AVG(customer_value), 2) AS avg_customer_value

FROM public.customers
GROUP BY status
ORDER BY customer_count DESC;


-- 5. Customer subscription duration segmentation

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
    COUNT(*) AS customer_count,
    ROUND(AVG(customer_value), 2) AS avg_customer_value,
    ROUND(AVG(subscription_months), 2) AS avg_tenure
FROM tenure_segments
GROUP BY tenure_segment
ORDER BY avg_tenure;


-- 6. Customer service usage by tariff plan

SELECT
    CASE
        WHEN tariff_plan = 1 THEN 'Pay-as-you-go'
        WHEN tariff_plan = 2 THEN 'Contractual'
    END AS tariff_type,

    ROUND(AVG(call_duration_seconds) / 60, 2) AS avg_call_minutes,
    ROUND(AVG(call_frequency), 2) AS avg_call_frequency,
    ROUND(AVG(sms_frequency), 2) AS avg_sms_frequency,
    ROUND(AVG(distinct_called_numbers), 2) AS avg_distinct_numbers

FROM public.customers
GROUP BY tariff_plan;


-- 7. Customer complaint analysis

SELECT
    CASE
        WHEN has_complaint = 1 THEN 'Complaint'
        ELSE 'No Complaint'
    END AS complaint_status,

    COUNT(*) AS customer_count,
    ROUND(AVG(call_failures), 2) AS avg_call_failures,
    ROUND(AVG(customer_value), 2) AS avg_customer_value,
    ROUND(AVG(subscription_months), 2) AS avg_subscription_months

FROM public.customers
GROUP BY has_complaint;


-- 8. Customer value segmentation using window functions

WITH value_ranking AS (

    SELECT
        record_id,
        customer_value,
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

    COUNT(*) AS customer_count,
    ROUND(MIN(customer_value), 2) AS min_value,
    ROUND(MAX(customer_value), 2) AS max_value,
    ROUND(AVG(customer_value), 2) AS avg_value

FROM value_ranking
GROUP BY value_quartile
ORDER BY value_quartile;


-- 9. Top 20 customers by calculated customer value

SELECT
    record_id,
    customer_value,
    subscription_months,
    tariff_plan,
    has_complaint,

    DENSE_RANK() OVER (
        ORDER BY customer_value DESC
    ) AS value_rank

FROM public.customers
ORDER BY customer_value DESC, record_id
LIMIT 20;


-- 10. Customers with above-average call failures

SELECT
    COUNT(*) AS customers_above_avg_failures,
    ROUND(AVG(call_failures), 2) AS avg_call_failures,
    ROUND(AVG(has_complaint) * 100, 2) AS complaint_rate,
    ROUND(AVG(customer_value), 2) AS avg_customer_value

FROM public.customers

WHERE call_failures > (
    SELECT AVG(call_failures)
    FROM public.customers
);

