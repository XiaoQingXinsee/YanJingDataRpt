WITH RECURSIVE org_relation AS (
    -- 递归查询组织树：根节点 -> 子节点
    SELECT
        o.pk_org       AS root_org_id,
        o.code         AS root_org_code,
        o.pk_org       AS org_id,
        o.code         AS org_code
    FROM public.ods_org_orgs o
    WHERE o.enablestate = '2' AND o.isbusinessunit = 'Y'

    UNION ALL

    SELECT
        orl.root_org_id,
        orl.root_org_code,
        org.pk_org    AS org_id,
        org.code      AS org_code
    FROM org_relation orl
    JOIN public.ods_org_orgs org 
        ON orl.org_id = org.pk_fatherorg
    WHERE org.enablestate = '2' AND org.isbusinessunit = 'Y'
),
org_full_info AS (
    -- 组织完整信息（含父级编码）
    SELECT
        o.pk_org,
        o.code,
        o.name,
        o.pk_fatherorg,
        oo.code AS forg_code
    FROM public.ods_org_orgs o
    LEFT JOIN public.ods_org_orgs oo 
        ON o.pk_fatherorg = oo.pk_org
    WHERE o.enablestate = '2' AND o.isbusinessunit = 'Y'
),
all_indicators AS (
    -- ===================== 你的全部业务指标（已清理1000硬编码）=====================
    SELECT 
      t.date_source,
    	'用工总量' theme_name,
      '入职人数' indicator_name,
      t.nyear_month,
      t.nyear,
      t.nmonth,
      t.org_code,
      t.org_name,
    	'' dim,
    	'' dim1,
    	'' dim2,
      SUM(t.onboard_count) + SUM(t.offboard_count) - SUM(t1.onboard_count) AS val,
    	0 val1,
    	0 val2,
    	0 val3
    FROM dws_hrm_hrd_month_onboard_offboard_count t 
    LEFT JOIN dws_hrm_hrd_month_onboard_offboard_count t1 
      ON t.org_code = t1.org_code 
      AND t1.nyear_month = TO_CHAR(
        (TO_DATE(t.nyear_month, 'YYYY-MM') - INTERVAL '1 month')::date, 
        'YYYY-MM'
      )
    GROUP BY 
      t.date_source,
      t.nyear_month,
      t.nyear,
      t.nmonth,
      t.org_code,
      t.org_name

    UNION ALL 

    SELECT 
      t.date_source,
    	'编制改革目标' theme_name,
      '净减员人数' indicator_name,
      t.nyear_month,
      t.nyear,
      t.nmonth,
      t.org_code,
      t.org_name,
    	'' dim,
    	'' dim1,
    	'' dim2,
      SUM(t.val) - SUM(t1.val) AS val,
    	0 val1,
    	0 val2,
    	0 val3
    FROM dws_hrm_hrd_month_end_personnel_count t 
    LEFT JOIN dws_hrm_hrd_month_end_personnel_count t1 
      ON t.org_code = t1.org_code 
      AND t1.nyear_month = TO_CHAR(
        (TO_DATE(t.nyear_month, 'YYYY-MM') - INTERVAL '1 month')::date, 
        'YYYY-MM'
      )
    GROUP BY 
      t.date_source,
      t.nyear_month,
      t.nyear,
      t.nmonth,
      t.org_code,
      t.org_name

    UNION ALL 

        SELECT 
      '03单位编制' date_source,
    	'用工总量' theme_name,
      '编制人数' indicator_name,
      d.nyear_month,
      CAST(d.nyear AS VARCHAR) nyear,
      CAST(d.nmonth AS VARCHAR) nmonth,
      t.org_code,
      t.org_name,
    	'' dim,
    	'' dim1,
    	'' dim2,
      budget_self AS val,
    	0 val1,
    	0 val2,
    	0 val3
    FROM v_dim_month d 
    LEFT JOIN dwd_hrm_hrd_orgbugget t 
      ON t.budget_year = CAST(d.nyear AS VARCHAR)

    UNION ALL 

   SELECT 
      '编织改革填报' date_source,
    	'编制改革目标' theme_name,
      '目标数、执行数' indicator_name,
      t.nyear nyear_month,
			left(t.nyear,4) nyear,
			right(t.nyear,2) nmonth,
      t.org_code,
      t.org_name,
    	'' dim,
    	'' dim1,
    	'' dim2,
      t.target_num val,
      t.execution_num val1,
    	0 val2,
    	0 val3
    FROM ods_weaving_reform t 
    GROUP BY
      t.org_code,
      t.org_name,
      t.nyear,
      t.target_num,
      t.execution_num

    UNION ALL 

    -- 修复：经济补偿金-人均经济补偿金（普通组织）
    SELECT 
      '经济补偿金填报_04组织人员多维度人数_按月' date_source,
    	'编制改革目标' theme_name,
      '人均经济补偿金' indicator_name,
      t.nyear_month,
    	'' nyear,
    	'' nmonth,
      t.org_code,
      t.org_name,
    	'' dim,
    	'' dim1,
    	'' dim2,
      t.usage_amount * 1.0 AS val,
    	SUM(t1.person_count) AS val1,
    	0 val2,
    	0 val3
    FROM ods_severance_pay t 
    LEFT JOIN dws_hrm_hrd_month_dim_person_count t1 
      ON t.org_code = t1.org_code 
      AND t.nyear_month = t1.nyear_month
      AND t1.end_status = '离职' 
      AND t1.trnsreason_name = '协商一致'
    GROUP BY
      t.org_code,
      t.org_name,
      t.nyear_month,
      t.usage_amount
    -- 2026/5/30 add by zhshrui 先注释
--    UNION ALL 

    

--     修复：工资总额-人均薪酬（普通组织）
--     SELECT 
--      '经济补偿金填报_04组织人员多维度人数_按月' date_source,
--    	'工资总额概况' theme_name,
--      '人均薪酬_系统取数' indicator_name,
--    	t.nyear_month nyear_month,
--      left(t.nyear_month,4) nyear,
--    	'' nmonth,
--      t.org_code,
--      t.org_name,
--    	'' dim,
--    	'' dim1,
--    	'' dim2,
--      sum(t.salary_budget) as val,
--      sum(t.salary_execution) as val1,
--      CASE 
--        WHEN sum(t.salary_budget) = 0 THEN 0.0
--        ELSE sum(t.salary_execution) * 1.0 / sum(t.salary_budget)
--      END AS val2,
--       sum(t1.person_count) AS val3
--    FROM ods_salary_total t 
--    LEFT JOIN (
--				SELECT 
--				t1.org_code,
--				t1.org_name,
--				t1.nyear,
--				t1.nmonth,
--				t1.nyear_month,
--				count(t1.code) AS person_count 
--				FROM dwd_hrm_hrd_month_psndoc t1
--				where rylb in ('正式工','内退人员','在职不在岗')
--				and end_status='在职'
--				and ismainjob LIKE '%Y%'
--				GROUP BY t1.org_code, t1.org_name, t1.nyear, t1.nmonth, t1.nyear_month
--    ) t1 
--      ON t.org_code = t1.org_code 
--      AND t.nyear_month = t1.nyear_month
--    GROUP BY
--      t.nyear_month,
--    	t.nyear,
--    	t.org_code,
--      t.org_name
--      
      
    -- add by zhshrui
    
    UNION ALL

SELECT
    '经济补偿金填报_04组织人员多维度人数_按月' AS date_source,
    '工资总额概况' AS theme_name,
    '人均薪酬_系统取数' AS indicator_name,
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
      AND business_type = '工资总额'
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
    WHERE stat_date >= DATE '2024-01-01'
      AND business_type = '工资总额'
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
    
    -- add by zhshrui end

   
       -- 2026/5/30 add by zhshrui 先注释

--    UNION ALL 
--
--    -- 修复：人力成本-人均人力成本（普通组织）
--       SELECT 
--      '工资总额填报_04组织人员多维度人数_按月' date_source,
--    	'人力成本概况' theme_name,
--      '人均人力成本' indicator_name,
--    	t.nyear_month,
--      left(t.nyear_month,4) nyear,
--    	'' nmonth,
--      t.org_code,
--      t.org_name,
--    	'' dim,
--    	'' dim1,
--    	'' dim2,
--      sum(t.labor_budget) as val,
--      sum(t.labor_execution) as val1,
--      CASE 
--        WHEN sum(t.labor_budget)  = 0 THEN 0.0
--        ELSE sum(t.labor_execution)  * 1.0 / SUM(t.labor_budget)
--      END AS val2,
--      sum(t1.person_count) AS val3
--    FROM ods_labor_costs t 
--		LEFT JOIN (
--				SELECT 
--				t1.org_code,
--				t1.org_name,
--				t1.nyear,
--				t1.nmonth,
--				t1.nyear_month,
--				count(t1.code) AS person_count 
--				FROM dwd_hrm_hrd_month_psndoc t1
--				where rylb in ('正式工','内退人员','在职不在岗')
--				and end_status='在职'
--				and ismainjob LIKE '%Y%'
--				GROUP BY t1.org_code, t1.org_name, t1.nyear, t1.nmonth, t1.nyear_month
--    ) t1 
--      ON t.org_code = t1.org_code 
--      AND t.nyear_month = t1.nyear_month
--
--    GROUP BY
--      t.nyear_month,
--    	t.nyear,
--    	t.org_code,
--      t.org_name
      
      -- add by zhshrui
      
      UNION ALL

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
      -- add by zhshrui end

    UNION ALL 

    -- 修复：干部人才分析-职级晋升率（普通组织）
    SELECT 
      '02人员基本信息_按月' date_source,
    	'干部人才分析' theme_name,
      '职级晋升' indicator_name,
      t.nyear_month,
      CAST(t.nyear AS VARCHAR) nyear,
      CAST(t.nmonth AS VARCHAR) nmonth,
      t.org_code,
      t.org_name,
    	'' dim,
    	'' dim1,
    	'' dim2,
			SUM(CASE WHEN t.trnstype_name = '晋升' THEN 1 ELSE 0 END) * 1.0 AS val,
    	sum(person_count) AS val1,
    	0 val2,
    	0 val3
    FROM dws_hrm_hrd_month_dim_person_count t 
    WHERE rylb in ('正式工','内退人员','在职不在岗')
				and end_status='在职'
				and ismainjob LIKE '%Y%'
    GROUP BY 
      t.nyear_month,
      t.nyear,
      t.nmonth,
      t.org_code,
      t.org_name
)
-- ===================== 最终关联递归组织，输出汇总结果 =====================
SELECT
    ofi.code         AS org_code,        -- 根组织编码
    ofi.name         AS org_name,        -- 根组织名称
    ofi.forg_code    AS forg_code,       -- 父组织编码
    h.date_source,
    h.theme_name,
    h.indicator_name,
    h.nyear_month,
    h.nyear,
    h.nmonth,
    h.dim,
    h.dim1,
    h.dim2,
    SUM(h.val)       AS val, -- 汇总数
		SUM(CASE WHEN h.org_code = ofi.code THEN h.val ELSE 0 END) AS total_val, -- 本级单位数
    SUM(h.val1)      AS val1,
		SUM(CASE WHEN h.org_code = ofi.code THEN h.val1 ELSE 0 END) AS total_val1,
    SUM(h.val2)      AS val2,
		SUM(CASE WHEN h.org_code = ofi.code THEN h.val2 ELSE 0 END) AS total_val2,
    SUM(h.val3)      AS val3,
		SUM(CASE WHEN h.org_code = ofi.code THEN h.val3 ELSE 0 END) AS total_val3

FROM all_indicators h
-- 关联递归组织关系
JOIN org_relation orl   ON h.org_code = orl.org_code
-- 关联到根组织信息
JOIN org_full_info ofi  ON orl.root_org_code = ofi.code

GROUP BY
    ofi.code,
    ofi.name,
    ofi.forg_code,
    h.date_source,
    h.theme_name,
    h.indicator_name,
    h.nyear_month,
    h.nyear,
    h.nmonth,
    h.dim,
    h.dim1,
    h.dim2
ORDER BY
    ofi.code,
    h.nyear_month,
    h.theme_name,
    h.indicator_name;