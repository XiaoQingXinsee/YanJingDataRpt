
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
-- SQL数据源组件，仅支持查询语句；
-- 每次仅能输入一个查询语句；
-- 为了保证任务运行成功率，请在表名前输入数据库模式信息；
--------------编制情况--------------------
select 
'03单位编制' date_source,   -- 数据来源DWD
'编制改革' theme_name,      --主题
'编制率' indicator_name,    --指标名称--
d.nyear_month,         --年月--
CAST(d.nyear AS VARCHAR) nyear,
CAST(d.nmonth AS VARCHAR) nmonth ,            
t.org_code , -- 组织
t.org_name , -- 组织
'' dim,    --维度：时间，日期，店铺等。 
'' dim1,       
'' dim2,
CAST(t.budget_actual AS BIGINT) val,     --含下级业务单元实际编制
CAST(t.budget_self AS BIGINT) val1,    --含下级业务单元计划编制
0 val2,
0 val3,
0 val4,
0 val5,
0 val6
from v_dim_month d  
left join dwd_hrm_hrd_orgbugget t on t.budget_year = CAST(d.nyear AS VARCHAR)  --根据年拿到年日

union all
-----------------------月度减员情况 净减员：本月月末人数-上月月末人数 在职人数-----------------------------
SELECT
'04本月与上月增减人数_按月' date_source,
'编制改革' theme_name, -- 分析
'月度情况' indicator_name,
t.nyear_month,
CAST(t.nyear AS VARCHAR) nyear,
CAST(t.nmonth AS VARCHAR) nmonth,
t.org_code,
t.org_name,
'' dim,
'' dim1,
'' dim2,
t.val as val,                       --净减在职人数
d.val as val1,                      --本月在职人数
0 val2,
0 val3,
0 val4,
0 val5,
0 val6
FROM dws_hrm_hrd_month_count_people t     
LEFT JOIN dws_hrm_hrd_month_end_personnel_count d ON t.org_code = d.org_code AND t.nyear_month=d.nyear_month

union all 
-----------------------解合、离职、退休、其他；新增-----------------------------
	SELECT 
    '02人员基本信息_按月' AS date_source,
    '编制改革' AS theme_name,
    '月度减员类别与入职情况' AS indicator_name,
    t.nyear_month,
    t.nyear::VARCHAR,
    t.nmonth::VARCHAR,
    t.org_code,
    t.org_name,
    '' AS dim, '' AS dim1, '' AS dim2,

    COUNT(CASE WHEN t.trnsreason_code = '0301' AND last.code IS NOT NULL THEN 1 END) AS val,  -- 辞职
    COUNT(CASE WHEN t.trnsreason_code = '0302' AND last.code IS NOT NULL THEN 1 END) AS val1, -- 退休
    COUNT(CASE WHEN t.trnsreason_code = '0303' AND last.code IS NOT NULL THEN 1 END) AS val2, -- 辞退
    COUNT(CASE WHEN t.trnsreason_code = '0305' AND last.code IS NOT NULL THEN 1 END) AS val3, -- 合同到期终止
    COUNT(CASE WHEN t.trnsreason_code = '0306' AND last.code IS NOT NULL THEN 1 END) AS val4, -- 协商一致 
    COUNT(CASE WHEN last.code IS NOT NULL 
         AND (t.trnsreason_code IS NULL 
              OR t.trnsreason_code NOT IN ('0301','0302','0303','0305','0306')) THEN 1 END) AS val5,  --其余为其他,trnsreason_code为空也是其他  

    COUNT(CASE WHEN t.trnsreason_code = '01' THEN 1 END) AS val6  --新增

FROM dwd_hrm_hrd_month_psndoc t
LEFT JOIN dws_hrm_hrd_month_people_detail last 
    ON t.code = last.code
		and t.org_code = last.org_code
    AND last.nyear_month = TO_CHAR(TO_DATE(t.nyear_month, 'YYYY-MM') - INTERVAL '1 month', 'YYYY-MM')
WHERE 
    t.trnsreason_code IS NOT NULL 
GROUP BY 
    t.nyear_month, t.nyear, t.nmonth, t.org_code, t.org_name

union all
-------------------------应届社招内招人数----------------------------------------------
SELECT 
  	'02人员基本信息_按月' date_source,
  	'招聘分析' theme_name, -- 分析
  	'应届社招人数' indicator_name,
    t.nyear_month,
    CAST(t.nyear AS VARCHAR) nyear,
    CAST(t.nmonth AS VARCHAR) nmonth ,    
    t.org_code,
    t.org_name,
      '' dim,
	  '' dim1,
	  '' dim2,
     COUNT(CASE WHEN t.trnstype_code = '0101' THEN t.code END) AS val,     --社会招聘
     COUNT(CASE WHEN t.trnstype_code = '0102' THEN t.code END) AS val1,    --校园招聘
     COUNT(CASE WHEN t.trnstype_code = '0306' THEN t.code END) AS val2,		 --内招
     0 val3, --其他人员
     0 val4,  --新增人数dwd_hrm_hrd_month_psndoc 基本人信息这里边没有燕京啤酒
     0 val5,
     0 val6
FROM dwd_hrm_hrd_month_psndoc t 
GROUP BY 
    t.nyear_month,
    t.nyear,
    t.nmonth,
    t.org_code,
    t.org_name



 union all     
------------------------学历统计根据社招还是校招---- 学历---------------    
SELECT 
    '02人员基本信息_按月' AS date_source,
    '招聘分析' AS theme_name,
    '学历人数' AS indicator_name,
    t.nyear_month,
    CAST(t.nyear AS VARCHAR) AS nyear,
    CAST(t.nmonth AS VARCHAR) AS nmonth,
    t.org_code,
    t.org_name,
    CASE
        WHEN edu_code = '21' THEN '大学本科'
        WHEN edu_code = '14' THEN '硕士研究生'
        WHEN edu_code = '11' THEN '博士'
        ELSE '大专以下'
    END AS dim,
    CAST(t.trnstype_code  AS VARCHAR) dim1,         ---0101 社招， 0102
    '' AS dim2,
    SUM(
        CASE 
            WHEN edu_code = '21' THEN 1
            WHEN edu_code = '14' THEN 1
            WHEN edu_code = '11' THEN 1
            WHEN edu_code NOT IN ('21', '14', '11') THEN 1
            ELSE 0
        END
    ) AS val,
    0 val1,
    0 val2,
    0 val3,
    0 val4,
    0 val5,
    0 val6
FROM 
    dwd_hrm_hrd_month_psndoc t
GROUP BY 
    t.nyear_month,
    t.nyear,
    t.nmonth,
    t.org_code,
    t.org_name,
    dim,
    dim1
      


union all

----------------------------------生产岗位-----------------------------------
SELECT 
    '02人员基本信息_按月' AS date_source,
    '招聘分析' AS theme_name,
    '岗位' AS indicator_name,
    t.nyear_month,
    CAST(t.nyear AS VARCHAR) AS nyear,
    CAST(t.nmonth AS VARCHAR) AS nmonth,
    t.org_code,
    t.org_name,
    CASE
        WHEN postseriescode = '001' THEN '生产序列'
        WHEN postseriescode = '002' THEN '销售序列'
        WHEN postseriescode = '003' THEN '职能序列'
    END AS dim,      --岗位序列
    CAST(t.trnstype_code  AS VARCHAR) dim1,         ---0101 社招， 0102
    '' AS dim2,     
    SUM(
        CASE 
            WHEN postseriescode = '001' THEN 1
            WHEN postseriescode = '002' THEN 1
            WHEN postseriescode = '003' THEN 1
            ELSE 0 
        END
    ) AS val,         
    0 val1,
    0 val2,
    0 val3,
    0 val4,
    0 val5,
    0 val6
FROM  
    dwd_hrm_hrd_month_psndoc t
GROUP BY 
    t.nyear_month,
    t.nyear,
    t.nmonth,
    t.org_code,
    t.org_name,
    dim,
    dim1



 union all        
 -------------------------------年龄段------------------------------------------------------  
 SELECT 
    '02人员基本信息_按月' AS date_source,
    '招聘分析' AS theme_name,
    '年龄' AS indicator_name,
    t.nyear_month,
    CAST(t.nyear AS VARCHAR) AS nyear,
    CAST(t.nmonth AS VARCHAR) AS nmonth,
    t.org_code,
    t.org_name,
    age_fl AS dim,      --岗位序列
    CAST(t.trnstype_code  AS VARCHAR) dim1,         ---0101 社招， 0102
    '' AS dim2,     
    SUM(
        CASE 
            WHEN age_fl = '25-30'  THEN 1
            WHEN age_fl = '40-50'  THEN 1
            WHEN age_fl = '20-25'  THEN 1
            WHEN age_fl = '50-60'  THEN 1
            WHEN age_fl = '30-40'  THEN 1
            WHEN age_fl = '20以下' THEN 1
            WHEN age_fl = '60以上' THEN 1
            ELSE 0 
        END
    ) AS val,         
    0 val1,
    0 val2,
    0 val3,
    0 val4,
    0 val5,
    0 val6
FROM  
    dwd_hrm_hrd_month_psndoc t
GROUP BY 
    t.nyear_month,
    t.nyear,
    t.nmonth,
    t.org_code,
    t.org_name,
    dim,
    dim1



 union all   
-------------------------职级序列---------------------------------------------    
SELECT 
    '02人员基本信息_按月' AS date_source,
    '招聘分析' AS theme_name,
    '职级' AS indicator_name,
    t.nyear_month,
    CAST(t.nyear AS VARCHAR) AS nyear,
    CAST(t.nmonth AS VARCHAR) AS nmonth,
    t.org_code,
    t.org_name,
    CASE WHEN top_dept.name IS NOT NULL THEN SUBSTR(t.joblevel_name, 1, 1) ELSE '' END AS dim,
    COALESCE(top_dept.name, '') AS dim1,        -- 一级部门名称（关键字段）
    SUBSTR(t.joblevel_name, 1, 2) AS dim2,
    COUNT(CASE WHEN top_dept.name IS NOT NULL AND SUBSTR(t.joblevel_name, 1, 1) = 'E' THEN t.code END) AS val,
    COUNT(CASE WHEN top_dept.name IS NOT NULL AND SUBSTR(t.joblevel_name, 1, 1) = 'B' THEN t.code END) AS val1,
    COUNT(CASE WHEN top_dept.name IS NOT NULL AND SUBSTR(t.joblevel_name, 1, 1) = 'M' THEN t.code END) AS val2,
    COUNT(CASE WHEN top_dept.name IS NOT NULL AND SUBSTR(t.joblevel_name, 1, 1) = 'P' THEN t.code END) AS val3,
    COUNT(t.code) AS val4,
    0 AS val5,
    0 AS val6
FROM  
    dwd_hrm_hrd_month_psndoc t
INNER JOIN dwd_org_dept_level dept 
    ON t.dept_code = dept.code
-- 关键修正：直接关联所有启用的一级部门，通过 innercode 前缀匹配
LEFT JOIN dwd_org_dept_level top_dept 
    ON dept.innercode LIKE top_dept.innercode || '%' 
    AND top_dept.dept_level_code = '01'
    AND top_dept.enablestate = 2
WHERE 
    t.joblevel_name IS NOT NULL
    AND TRIM(t.joblevel_name) != ''
    AND t.rylb IN ('正式工', '内退人员')
    AND t.end_status = '在职'
GROUP BY 
    t.nyear_month,
    t.nyear,
    t.nmonth,
    t.org_code,
    t.org_name,
    top_dept.name,
    t.joblevel_name



union all
------------------------------招聘应聘人数--------------------------------------
SELECT 
    '06招聘应聘人数统计表_大易' AS date_source,
    '招聘分析' AS theme_name,
    '应聘录用人数' AS indicator_name,
    t.nyear_month,
    CAST(t.nyear AS VARCHAR(4)) AS nyear,
    CAST(t.nmonth AS VARCHAR(2)) AS nmonth,
    t.org_code,
    t.org_name,
    '' AS dim,              
    '' AS dim1,                                   
    '' AS dim2,    
    SUM(
        CAST(
            CASE 
                WHEN t.recruiting_num = '若干' THEN '2'
                ELSE t.recruiting_num
            END AS BIGINT)
    ) AS val,       --招聘人数
    SUM(CAST(t.interview_num AS BIGINT)) AS val1,  --应聘人数
    SUM(CAST(t.hire_num AS BIGINT)) + SUM(CAST(t.rejection_num AS BIGINT)) AS val2,     --录用人数
    0 AS val3,
    0 AS val4,
    0 val5,
    0 val6
FROM  
    dws_hrm_hrd_recruiting_num t  
GROUP BY 
    t.nyear_month,
    t.nyear,
    t.nmonth,
    t.org_code,
    t.org_name

union all 
     

				SELECT 
  '02人员基本信息_按月_招聘计划数' date_source,
  '招聘分析' theme_name,
  '招聘人数' indicator_name,
  t.nyear_month nyear_month,
  t.nyear::varchar nyear,
  CAST(t.nmonth AS VARCHAR(2)) nmonth,
  t.org_code,
  t.org_name,
  '' dim,
  '' dim1,
  '' dim2,
  t.person_plan_count as val,
  sum(t1.person_count) as val1,
  0 val2,
  0 AS val3,
	 0 val4,  --新增人数dwd_hrm_hrd_month_psndoc 基本人信息这里边没有燕京啤酒
     0 val5,
     0 val6
		 
FROM dwd_recruit_plans t
LEFT JOIN (
  SELECT 
    t1.org_code,
    t1.org_name,
    t1.nyear,
    t1.nmonth,
    t1.nyear_month,
    count(t1.code) AS person_count 
  FROM dwd_hrm_hrd_month_psndoc t1
  where trnsevent='入职'
  and ismainjob LIKE '%Y%'
  GROUP BY t1.org_code, t1.org_name, t1.nyear, t1.nmonth, t1.nyear_month
) t1 
  ON t.org_code = t1.org_code 
  AND t.nyear_month = t1.nyear_month  -- 这里修复了类型
GROUP BY 
t.person_plan_count,
  t.nyear_month,
  t.nyear,
	t.nmonth,
  t.org_code,
  t.org_name
	
union all 
-- 修复：经济补偿金-人均经济补偿金（普通组织）
    SELECT 
      '经济补偿金填报_04组织人员多维度人数_按月' date_source,
    	'经济补偿金使用情况' theme_name,
      '人均经济补偿金' indicator_name,
      t.nyear_month,
			left(t.nyear_month,4) nyear,
			right(t.nyear_month,2) nmonth,
      t.org_code,
      t.org_name,
    	'' dim,
    	'' dim1,
    	'' dim2,
      t.budget_amount*1.0 AS val,
    	t.usage_amount*1.0 AS val1,
    	SUM(t1.person_count) val2,
    	0 val3,
			 0 val4,  --新增人数dwd_hrm_hrd_month_psndoc 基本人信息这里边没有燕京啤酒
     0 val5,
     0 val6
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
			t.budget_amount,
      t.usage_amount	
      
   -- add by zhshrui
   -- 招聘费用
      UNION ALL

SELECT
    '月度资金计划编制调整_人力付款申请' AS date_source,
    '招聘费用概况' AS theme_name,
    '招聘费用' AS indicator_name,
    TO_CHAR(COALESCE(b.stat_date, p.stat_date), 'YYYY-MM') AS nyear_month,
    LEFT(TO_CHAR(COALESCE(b.stat_date, p.stat_date), 'YYYY-MM'), 4) AS nyear,
    RIGHT(TO_CHAR(COALESCE(b.stat_date, p.stat_date), 'YYYY-MM'), 2) AS nmonth,
    COALESCE(b.organization_code, p.organization_code) AS org_code,
    COALESCE(b.organization_name, p.organization_name) AS org_name,
    '' AS dim,
    '' AS dim1,
    '' AS dim2,

    -- 实际数
    COALESCE(p.payment_amount, 0) AS val,

    -- 预算数
    COALESCE(b.budget_amount, 0) AS val1,

    -- 实际 / 预算
    CASE
        WHEN COALESCE(b.budget_amount, 0) = 0 THEN 0
        ELSE ROUND(
            COALESCE(p.payment_amount, 0) / b.budget_amount,
            4
        )
    END AS val2,

    0 AS val3,
    0 AS val4,
    0 AS val5,
    0 AS val6

FROM (
    SELECT
        stat_date,
        organization_code,
        organization_name,
        SUM(total_budget_amount) AS budget_amount
    FROM dws_hrm_hrd_month_fund_plan_summary_df
    where 1=1
--    and stat_date >= DATE '2026-03-01'
      AND business_type = '招聘费'
    GROUP BY
        stat_date,
        organization_code,
        organization_name
) b

FULL JOIN (
    SELECT
        stat_date,
        organization_code,
        organization_name,
        SUM(total_payment_amount) AS payment_amount
    FROM dws_hrm_hrd_month_payment_apply_summary_df
    WHERE 1=1
--    and stat_date >= DATE '2024-01-01'
      AND business_type = '招聘费'
    GROUP BY
        stat_date,
        organization_code,
        organization_name
) p
    ON b.stat_date = p.stat_date
   AND b.organization_code = p.organization_code
      
   -- add by zhshrui end
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
		SUM(CASE WHEN h.org_code = ofi.code THEN h.val3 ELSE 0 END) AS total_val3,
		SUM(h.val4)      AS val4,
		SUM(CASE WHEN h.org_code = ofi.code THEN h.val4 ELSE 0 END) AS total_val4,
		SUM(h.val5)      AS val5,
		SUM(CASE WHEN h.org_code = ofi.code THEN h.val5 ELSE 0 END) AS total_val5,
		SUM(h.val6)      AS val6,
		SUM(CASE WHEN h.org_code = ofi.code THEN h.val3 ELSE 0 END) AS total_val6

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
  