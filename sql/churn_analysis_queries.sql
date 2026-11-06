-- Telecom Customer Churn Analysis: SQL queries
-- Table: telco_churn (one row per customer, loaded from data/telco_churn_clean.csv)
-- Written for SQLite (used in the notebook). The same queries run on SQL Server
-- with minor syntax changes.

-- 1. Overall churn rate and customer count
SELECT
    COUNT(*)                                   AS customers,
    SUM(churn_flag)                            AS churned,
    ROUND(100.0 * AVG(churn_flag), 1)          AS churn_rate_pct
FROM telco_churn;

-- 2. Churn rate by contract type
SELECT
    Contract,
    COUNT(*)                                   AS customers,
    SUM(churn_flag)                            AS churned,
    ROUND(100.0 * AVG(churn_flag), 1)          AS churn_rate_pct
FROM telco_churn
GROUP BY Contract
ORDER BY churn_rate_pct DESC;

-- 3. Churn rate by tenure band (months with the company)
SELECT
    CASE
        WHEN tenure <= 12 THEN '0-12 months'
        WHEN tenure <= 24 THEN '13-24 months'
        WHEN tenure <= 48 THEN '25-48 months'
        ELSE '49-72 months'
    END                                        AS tenure_band,
    COUNT(*)                                   AS customers,
    ROUND(100.0 * AVG(churn_flag), 1)          AS churn_rate_pct
FROM telco_churn
GROUP BY tenure_band
ORDER BY MIN(tenure);

-- 4. Churn rate by payment method
SELECT
    PaymentMethod,
    COUNT(*)                                   AS customers,
    ROUND(100.0 * AVG(churn_flag), 1)          AS churn_rate_pct
FROM telco_churn
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;

-- 5. Internet customers: churn with and without tech support
SELECT
    InternetService,
    TechSupport,
    COUNT(*)                                   AS customers,
    ROUND(100.0 * AVG(churn_flag), 1)          AS churn_rate_pct
FROM telco_churn
WHERE InternetService <> 'No'
GROUP BY InternetService, TechSupport
ORDER BY InternetService, TechSupport;

-- 6. Monthly recurring revenue (MRR) lost to churn
SELECT
    ROUND(SUM(MonthlyCharges), 2)                                          AS total_mrr,
    ROUND(SUM(CASE WHEN churn_flag = 1 THEN MonthlyCharges ELSE 0 END), 2) AS churned_mrr,
    ROUND(100.0 * SUM(CASE WHEN churn_flag = 1 THEN MonthlyCharges ELSE 0 END)
          / SUM(MonthlyCharges), 1)                                        AS churned_mrr_pct
FROM telco_churn;

-- 7. Churned MRR by contract type (where the lost revenue comes from)
SELECT
    Contract,
    ROUND(SUM(MonthlyCharges), 2)                                          AS churned_mrr,
    ROUND(100.0 * SUM(MonthlyCharges)
          / (SELECT SUM(MonthlyCharges) FROM telco_churn WHERE churn_flag = 1), 1) AS share_of_churned_mrr_pct
FROM telco_churn
WHERE churn_flag = 1
GROUP BY Contract
ORDER BY churned_mrr DESC;
