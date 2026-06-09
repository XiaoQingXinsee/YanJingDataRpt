SELECT
    '工资总额填报_04组织人员多维度人数_按月' AS date_source,
    '人力成本概况' AS theme_name,
    '人均人力成本' AS indicator_name,
    TO_CHAR(COALESCE(b.stat_date, p.stat_date), 'YYYY-MM') AS nyear_month,
    COALESCE(b.budget_year, p.budget_year) AS nyear,
    '' AS nmonth,
    COALESCE(b.organization_code, p.organization_code) AS org_code,
    COALESCE(b.organization_name, p.organization_name) AS org_name,
    '' AS dim,
    '' AS dim1,
    '' AS dim2,
    COALESCE(b.budget_amount, 0) AS val,
    COALESCE(p.payment_amount, 0) AS val1,
    CASE
        WHEN COALESCE(b.budget_amount, 0) = 0 THEN 0
        ELSE ROUND(
            COALESCE(p.payment_amount, 0) / b.budget_amount,
            4
        )
    END AS val2,
    COALESCE(t1.person_count, 0) AS val3
FROM (
    SELECT
        stat_date,
        budget_year,
        budget_month,
        organization_code,
        organization_name,
        SUM(total_budget_amount) AS budget_amount
    FROM dws_hrm_hrd_month_fund_plan_summary_df
    WHERE stat_date >= DATE '2024-01-01'
    GROUP BY
        stat_date,
        budget_year,
        budget_month,
        organization_code,
        organization_name
) b
FULL JOIN (
    SELECT
        stat_date,
        budget_year,
        budget_month,
        organization_code,
        organization_name,
        SUM(total_payment_amount) AS payment_amount
    FROM dws_hrm_hrd_month_payment_apply_summary_df
    WHERE stat_date >= DATE '2026-03-01'
    GROUP BY
        stat_date,
        budget_year,
        budget_month,
        organization_code,
        organization_name
) p
    ON b.stat_date = p.stat_date
    AND b.organization_code = p.organization_code
LEFT JOIN (
    SELECT
        t1.org_code,
        t1.nyear_month,
        COUNT(t1.code) AS person_count
    FROM dwd_hrm_hrd_month_psndoc t1
    WHERE t1.rylb IN ('正式工','内退人员','在职不在岗')
      AND t1.end_status = '在职'
      AND t1.ismainjob LIKE '%Y%'
    GROUP BY
        t1.org_code,
        t1.nyear_month
) t1
    ON t1.org_code = COALESCE(b.organization_code, p.organization_code)
   AND t1.nyear_month = TO_CHAR(COALESCE(b.stat_date, p.stat_date), 'YYYY-MM')