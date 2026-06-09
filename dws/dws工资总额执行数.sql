-- ============================================================
-- 表名: dws_hrm_hrd_month_payment_apply_summary_df
-- 表描述: DWS人力人事费用域_月度付款申请汇总表
-- 数据来源: dwd_hrm_hrd_month_payment_apply_df
-- 语法规范: PostgreSQL
-- ============================================================

DROP TABLE IF EXISTS dws_hrm_hrd_month_payment_apply_summary_df;

CREATE TABLE dws_hrm_hrd_month_payment_apply_summary_df (

    stat_date DATE,
    budget_year VARCHAR(50),
    budget_month VARCHAR(50),

    -- 新增：预算单位字段
    organization_code VARCHAR(100),
    organization_name VARCHAR(500),

    fund_subcategory_code VARCHAR(50),
    fund_subcategory_name VARCHAR(500),
    fund_sub_type VARCHAR(100),
    business_type VARCHAR(100),

    apply_count BIGINT,
    total_payment_amount DECIMAL(18,2),

    etl_load_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 表注释
-- ============================================================

COMMENT ON TABLE dws_hrm_hrd_month_payment_apply_summary_df
IS 'DWS人力人事费用域_月度付款申请汇总表';

-- ============================================================
-- 字段注释
-- ============================================================

COMMENT ON COLUMN dws_hrm_hrd_month_payment_apply_summary_df.stat_date IS '统计年月';
COMMENT ON COLUMN dws_hrm_hrd_month_payment_apply_summary_df.budget_year IS '预算年度';
COMMENT ON COLUMN dws_hrm_hrd_month_payment_apply_summary_df.budget_month IS '预算月度';

COMMENT ON COLUMN dws_hrm_hrd_month_payment_apply_summary_df.organization_code IS '预算单位编码';
COMMENT ON COLUMN dws_hrm_hrd_month_payment_apply_summary_df.organization_name IS '预算单位名称';

COMMENT ON COLUMN dws_hrm_hrd_month_payment_apply_summary_df.fund_subcategory_code IS '资金小类编码';
COMMENT ON COLUMN dws_hrm_hrd_month_payment_apply_summary_df.fund_subcategory_name IS '资金小类名称';
COMMENT ON COLUMN dws_hrm_hrd_month_payment_apply_summary_df.fund_sub_type IS '资金小类分类';
COMMENT ON COLUMN dws_hrm_hrd_month_payment_apply_summary_df.business_type IS '业务分类';

COMMENT ON COLUMN dws_hrm_hrd_month_payment_apply_summary_df.apply_count IS '申请单据笔数';
COMMENT ON COLUMN dws_hrm_hrd_month_payment_apply_summary_df.total_payment_amount IS '付款金额';

COMMENT ON COLUMN dws_hrm_hrd_month_payment_apply_summary_df.etl_load_time IS 'ETL加载时间';

-- ============================================================
-- 清空数据
-- ============================================================

TRUNCATE TABLE dws_hrm_hrd_month_payment_apply_summary_df;

-- ============================================================
-- 插入汇总数据
-- ============================================================

INSERT INTO dws_hrm_hrd_month_payment_apply_summary_df (

    stat_date,
    budget_year,
    budget_month,

    organization_code,
    organization_name,

    fund_subcategory_code,
    fund_subcategory_name,
    fund_sub_type,
    business_type,

    apply_count,
    total_payment_amount
)

SELECT

    make_date(budget_year::INTEGER, budget_month::INTEGER, 1) AS stat_date,

    budget_year::VARCHAR AS budget_year,

    LPAD(budget_month::VARCHAR, 2, '0') AS budget_month,

    -- 使用改造后的预算单位字段
    organization_code,
    organization_name,

    fund_subcategory_code,
    fund_subcategory_name,

    -- ===================== 资金小类分类 =====================
    CASE
        WHEN fund_subcategory_name LIKE '%工资%'         THEN '工资'
        WHEN fund_subcategory_name LIKE '%奖金%'         THEN '奖金'
        WHEN fund_subcategory_name LIKE '%个人社保%'     THEN '个人社保'
        WHEN fund_subcategory_name LIKE '%个人公积金%'   THEN '个人公积金'
        WHEN fund_subcategory_name LIKE '%计件工资%'     THEN '计件工资'
        WHEN fund_subcategory_name LIKE '%劳务派遣工资%' THEN '劳务派遣工资'
        WHEN fund_subcategory_name LIKE '%招聘费%'       THEN '招聘费'
        ELSE '其他人力费用'
    END AS fund_sub_type,

    -- ===================== 业务分类 =====================
    CASE
--        WHEN fund_subcategory_name LIKE '%工资%'
--          OR fund_subcategory_name LIKE '%奖金%'
--          OR fund_subcategory_name LIKE '%个人社保%'
--          OR fund_subcategory_name LIKE '%个人公积金%'
--          OR fund_subcategory_name LIKE '%计件工资%'
--          OR fund_subcategory_name LIKE '%劳务派遣工资%'
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

    COUNT(*) AS apply_count,

    SUM(apply_payment_amount) AS total_payment_amount

FROM dwd_hrm_hrd_month_payment_apply_df

WHERE 1 = 1

    -- 过滤：总部财务部部长签字【同意】
    AND LEFT(hq_finance_dept_head_sign, 4) = '【同意】'
    and ywlxbm='Z10'

    -- 过滤：工资类 + 招聘费
--    AND (
----        fund_subcategory_name LIKE '%工资%'
----        OR fund_subcategory_name LIKE '%奖金%'
----        OR fund_subcategory_name LIKE '%个人社保%'
----        OR fund_subcategory_name LIKE '%个人公积金%'
----        OR fund_subcategory_name LIKE '%计件工资%'
----        OR fund_subcategory_name LIKE '%劳务派遣工资%'
----        OR fund_subcategory_name LIKE '%招聘费%'
--        (fund_subcategory_code IN (
--    'Z10-001-0101',
--    'Z10-002-0201',
--    'Z10-005-0501',
--    'Z10-006-0601',
--    'z10-009',
--    'Z10-C003-0301',
--    'Z10-C004-0401'
--))  OR fund_subcategory_name LIKE '%招聘费%'
--    )

GROUP BY

    budget_year,
    budget_month,

    organization_code,
    organization_name,

    fund_subcategory_code,
    fund_subcategory_name

ORDER BY

    stat_date,
    organization_code;

-- 查询验证
 SELECT *
 FROM dws_hrm_hrd_month_payment_apply_summary_df
 where 1=1
 and budget_year='2024';
