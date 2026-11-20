
-- Project: Telecom Customer Churn and Retention Optimization
-- Database: telecom_churn_db
-- Purpose: Create the customer churn table

CREATE TABLE public.customers (

    record_id VARCHAR(10) PRIMARY KEY,

    call_failures INTEGER NOT NULL
        CHECK (call_failures >= 0),

    has_complaint SMALLINT NOT NULL
        CHECK (has_complaint IN (0, 1)),

    subscription_months INTEGER NOT NULL
        CHECK (subscription_months >= 0),

    charge_amount SMALLINT NOT NULL
        CHECK (charge_amount BETWEEN 0 AND 10),

    call_duration_seconds INTEGER NOT NULL
        CHECK (call_duration_seconds >= 0),

    call_frequency INTEGER NOT NULL
        CHECK (call_frequency >= 0),

    sms_frequency INTEGER NOT NULL
        CHECK (sms_frequency >= 0),

    distinct_called_numbers INTEGER NOT NULL
        CHECK (distinct_called_numbers >= 0),

    age_group SMALLINT NOT NULL
        CHECK (age_group BETWEEN 1 AND 5),

    tariff_plan SMALLINT NOT NULL
        CHECK (tariff_plan IN (1, 2)),

    status SMALLINT NOT NULL
        CHECK (status IN (1, 2)),

    age INTEGER NOT NULL
        CHECK (age >= 0),

    customer_value NUMERIC NOT NULL
        CHECK (customer_value >= 0),

    churn SMALLINT NOT NULL
        CHECK (churn IN (0, 1)),

    is_duplicate_record SMALLINT NOT NULL
        CHECK (is_duplicate_record IN (0, 1))

);

COMMENT ON TABLE public.customers IS
'Validated telecom customer records for churn analysis and retention optimization';

