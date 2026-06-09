-- ============================================================
-- 表名: dws_hrm_hrd_month_fund_plan_summary_df
-- 表描述: DWS人力人事费用域_月度资金计划编制调整汇总表
-- 数据来源:
--   dwd_hrm_hrd_month_fund_plan_prepare_df
--   dwd_hrm_hrd_month_fund_plan_adjust_df
-- ============================================================

-- 1. 删除旧表
DROP TABLE IF EXISTS dws_hrm_hrd_month_fund_plan_summary_df;

-- 2. 建表
CREATE TABLE dws_hrm_hrd_month_fund_plan_summary_df (

    stat_date DATE,
    budget_year VARCHAR(50),
    budget_month VARCHAR(50),

    -- 新增预算单位字段
    organization_code VARCHAR(100),
    organization_name VARCHAR(500),

    fund_subcategory_code VARCHAR(50),
    fund_subcategory_name VARCHAR(500),

    business_type VARCHAR(100),

    prepare_amount DECIMAL(18,2),
    adjust_amount DECIMAL(18,2),
    total_budget_amount DECIMAL(18,2),

    etl_load_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 表注释
-- ============================================================

COMMENT ON TABLE dws_hrm_hrd_month_fund_plan_summary_df
IS 'DWS人力人事费用域_月度资金计划编制调整汇总表';

-- ============================================================
-- 字段注释
-- ============================================================

COMMENT ON COLUMN dws_hrm_hrd_month_fund_plan_summary_df.stat_date IS '统计年月';
COMMENT ON COLUMN dws_hrm_hrd_month_fund_plan_summary_df.budget_year IS '预算年度';
COMMENT ON COLUMN dws_hrm_hrd_month_fund_plan_summary_df.budget_month IS '预算月度';

COMMENT ON COLUMN dws_hrm_hrd_month_fund_plan_summary_df.organization_code IS '预算单位编码';
COMMENT ON COLUMN dws_hrm_hrd_month_fund_plan_summary_df.organization_name IS '预算单位名称';

COMMENT ON COLUMN dws_hrm_hrd_month_fund_plan_summary_df.fund_subcategory_code IS '资金小类编码';
COMMENT ON COLUMN dws_hrm_hrd_month_fund_plan_summary_df.fund_subcategory_name IS '资金小类名称';

COMMENT ON COLUMN dws_hrm_hrd_month_fund_plan_summary_df.business_type IS '业务分类';

COMMENT ON COLUMN dws_hrm_hrd_month_fund_plan_summary_df.prepare_amount IS '资金计划编制金额';
COMMENT ON COLUMN dws_hrm_hrd_month_fund_plan_summary_df.adjust_amount IS '资金计划调整金额';
COMMENT ON COLUMN dws_hrm_hrd_month_fund_plan_summary_df.total_budget_amount IS '资金预算总额';

COMMENT ON COLUMN dws_hrm_hrd_month_fund_plan_summary_df.etl_load_time IS 'ETL加载时间';

-- ============================================================
-- 清空数据
-- ============================================================

TRUNCATE TABLE dws_hrm_hrd_month_fund_plan_summary_df;

-- ============================================================
-- 插入数据
-- ============================================================

INSERT INTO dws_hrm_hrd_month_fund_plan_summary_df (

    stat_date,
    budget_year,
    budget_month,

    organization_code,
    organization_name,

    fund_subcategory_code,
    fund_subcategory_name,

    business_type,

    prepare_amount,
    adjust_amount,
    total_budget_amount
)

SELECT

    stat_date,
    budget_year,
    budget_month,

    organization_code,
    organization_name,

    fund_subcategory_code,
    fund_subcategory_name,

    business_type,

    SUM(prepare_amount) AS prepare_amount,
    SUM(adjust_amount) AS adjust_amount,

    SUM(prepare_amount) + SUM(adjust_amount) AS total_budget_amount

FROM (

    -- ========================================================
    -- 子查询1：月度资金计划编制
    -- ========================================================

    SELECT

        make_date(budget_year::INTEGER, budget_month::INTEGER, 1) AS stat_date,

        budget_year::VARCHAR AS budget_year,

        LPAD(budget_month::VARCHAR, 2, '0') AS budget_month,

        budget_unit_code AS organization_code,
        budget_unit_name AS organization_name,

        fund_subcategory_code,
        fund_subcategory_name,

        -- 业务分类
        CASE
            WHEN fund_subcategory_name LIKE '%工资%'
              OR fund_subcategory_name LIKE '%奖金%'
              OR fund_subcategory_name LIKE '%个人社保%'
              OR fund_subcategory_name LIKE '%个人公积金%'
              OR fund_subcategory_name LIKE '%计件工资%'
              OR fund_subcategory_name LIKE '%劳务派遣工资%'
            THEN '工资总额'

            WHEN fund_subcategory_name LIKE '%招聘费%'
            THEN '招聘费'

            ELSE '其他资金'
        END AS business_type,

        COALESCE(SUM(budget_amount), 0) AS prepare_amount,

        0 AS adjust_amount

    FROM dwd_hrm_hrd_month_fund_plan_prepare_df

    WHERE 1 = 1

        -- 审批状态过滤
        AND LEFT(hq_finance_dept_head_sign, 4) = '【同意】'

        -- 脏数据过滤
        AND budget_month IS NOT NULL
        AND budget_month::VARCHAR <> ''
        AND budget_month::VARCHAR <> '2024'
        AND budget_month::INTEGER BETWEEN 1 AND 12
        and ywlxbm='Z10'

    GROUP BY

        budget_year,
        budget_month,

        budget_unit_code,
        budget_unit_name,

        fund_subcategory_code,
        fund_subcategory_name

    UNION ALL

    -- ========================================================
    -- 子查询2：月度资金计划调整
    -- ========================================================

    SELECT

        make_date(budget_year::INTEGER, budget_month::INTEGER, 1) AS stat_date,

        budget_year::VARCHAR AS budget_year,

        LPAD(budget_month::VARCHAR, 2, '0') AS budget_month,

        budget_unit_code AS organization_code,
        budget_unit_name AS organization_name,

        fund_subcategory_code,
        fund_subcategory_name,

        -- 业务分类
        CASE
--            WHEN fund_subcategory_name LIKE '%工资%'
--              OR fund_subcategory_name LIKE '%奖金%'
--              OR fund_subcategory_name LIKE '%个人社保%'
--              OR fund_subcategory_name LIKE '%个人公积金%'
--              OR fund_subcategory_name LIKE '%计件工资%'
--              OR fund_subcategory_name LIKE '%劳务派遣工资%'
--            THEN '工资总额'
	        
	         when fund_subcategory_code IN (
    'Z10-001-0101',
    'Z10-002-0201',
    'Z10-005-0501',
    'Z10-006-0601',
    'z10-009',
    'Z10-C003-0301',
    'Z10-C004-0401'
)
        THEN '工资总额'

            WHEN fund_subcategory_name LIKE '%招聘费%'
            THEN '招聘费'

            ELSE '其他资金'
        END AS business_type,

        0 AS prepare_amount,

        COALESCE(SUM(adjust_amount), 0) AS adjust_amount

    FROM dwd_hrm_hrd_month_fund_plan_adjust_df

    WHERE 1 = 1

        -- 审批状态过滤
        AND LEFT(hq_finance_dept_head_sign, 4) = '【同意】'

        -- 脏数据过滤
        AND budget_month IS NOT NULL
        AND budget_month::VARCHAR <> ''
        AND budget_month::VARCHAR <> '2024'
        AND budget_month::INTEGER BETWEEN 1 AND 12
       and ywlxbm='Z10'

    GROUP BY

        budget_year,
        budget_month,

        budget_unit_code,
        budget_unit_name,

        fund_subcategory_code,
        fund_subcategory_name

) t

GROUP BY

    stat_date,
    budget_year,
    budget_month,

    organization_code,
    organization_name,

    fund_subcategory_code,
    fund_subcategory_name,

    business_type

ORDER BY

    stat_date,
    organization_code;

-- ============================================================
-- 查询结果
-- ============================================================

SELECT *
FROM dws_hrm_hrd_month_fund_plan_summary_df;