-- PostgreSQL (pgsql) 标准建表语句
DROP TABLE IF EXISTS dwd_hrm_hrd_month_fund_plan_adjust_df;

CREATE TABLE dwd_hrm_hrd_month_fund_plan_adjust_df (

    -- 主表基础信息
    fund_plan_adjust_no VARCHAR(100),
    budget_year VARCHAR(50),
    budget_month VARCHAR(50),

    -- 新增：预算单位信息
    budget_unit_id VARCHAR(100),
    budget_unit_code VARCHAR(100),
    budget_unit_name VARCHAR(200),

    budget_unit VARCHAR(20),
    budget_dept VARCHAR(20),
    prepare_person VARCHAR(20),
    prepare_date TIMESTAMP,
    business_type NUMERIC(19,0),
    total_budget_adjust_amount NUMERIC(20,2),
    business_dept VARCHAR(20),
    business_dept_code VARCHAR(100),

    -- 主表签字字段
    member_unit_handler_sign VARCHAR(4000),
    member_unit_biz_dept_head_sign VARCHAR(4000),
    member_unit_finance_vice_sign VARCHAR(4000),
    member_unit_gm_sign VARCHAR(4000),
    member_unit_chairman_sign VARCHAR(4000),
    hq_chairman_sign VARCHAR(4000),
    hq_handler_multi_sign VARCHAR(4000),
    hq_biz_dept_handler_sign VARCHAR(4000),
    hq_biz_dept_head_sign VARCHAR(4000),
    hq_biz_vice_gm_sign VARCHAR(4000),
    hq_finance_dept_head_sign VARCHAR(4000),
    hq_finance_vice_sign VARCHAR(4000),
    hq_gm_sign VARCHAR(4000),

    -- 明细表字段
    serial_no NUMERIC(20,0),
    fund_subcategory_name VARCHAR(100),
    fund_subcategory_code VARCHAR(100),
    fund_category_name VARCHAR(100),
    fund_category_code VARCHAR(100),
    adjust_amount NUMERIC(20,2),
    control_strength NUMERIC(19,0),
    purpose_desc VARCHAR(100),
    fund_type VARCHAR(100),
    is_bid NUMERIC(19,0),
    is_instruct NUMERIC(19,0),
    is_three_important_one_large NUMERIC(19,0),
    topic_no VARCHAR(300),
    topic_status VARCHAR(100),
    over_budget_type NUMERIC(19,0),
    over_budget_amount NUMERIC(20,2),
    usage_note VARCHAR(100),
    
            -- ========== 业务类型字段 ==========
    ywlx VARCHAR(4000),
    ywlxbm VARCHAR(4000),
	ywlxmc VARCHAR(4000),

    etl_load_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 表注释
COMMENT ON TABLE dwd_hrm_hrd_month_fund_plan_adjust_df
IS 'DWD_人力人事费用域_月度资金计划调整单明细事实表';

-- ============================================================
-- 基础字段注释
-- ============================================================

COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.fund_plan_adjust_no IS '月度资金预算编制流水号';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.budget_year IS '预算年';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.budget_month IS '预算月';

COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.budget_unit_id IS '预算单位ID';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.budget_unit_code IS '预算单位编码';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.budget_unit_name IS '预算单位名称';

COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.budget_unit IS '预算单位';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.budget_dept IS '预算部门';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.prepare_person IS '编制人';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.prepare_date IS '编制日期';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.business_type IS '业务类型';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.total_budget_adjust_amount IS '预算金额合计';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.business_dept IS '业务归口部门';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.business_dept_code IS '业务归口部门代码';

-- ============================================================
-- 签字字段注释
-- ============================================================

COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.member_unit_handler_sign IS '成员单位经办人签字';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.member_unit_biz_dept_head_sign IS '成员单位业务部门负责人签字';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.member_unit_finance_vice_sign IS '成员单位主管业务副总签字';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.member_unit_gm_sign IS '成员单位总经理签字';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.member_unit_chairman_sign IS '成员单位董事长签字';

COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.hq_chairman_sign IS '总部董事长';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.hq_handler_multi_sign IS '总部经办人（多选）';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.hq_biz_dept_handler_sign IS '总部业务部门经办人';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.hq_biz_dept_head_sign IS '总部业务部门负责人';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.hq_biz_vice_gm_sign IS '总部业务主管副总';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.hq_finance_dept_head_sign IS '总部财务部部长';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.hq_finance_vice_sign IS '总部财务副总';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.hq_gm_sign IS '总部总经理';

-- ============================================================
-- 明细字段注释
-- ============================================================

COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.serial_no IS '序号1';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.fund_subcategory_name IS '小类名称';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.fund_subcategory_code IS '小类编码';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.fund_category_name IS '大类名称';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.fund_category_code IS '大类编码';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.adjust_amount IS '预算调增金额';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.control_strength IS '管控强度';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.purpose_desc IS '用途描述';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.fund_type IS '资金类别';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.is_bid IS '是否招标';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.is_instruct IS '是否批示';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.is_three_important_one_large IS '是否三重一大';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.topic_no IS '议题编号';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.topic_status IS '议题状态';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.over_budget_type IS '超预算类型';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.over_budget_amount IS '超预算金额';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.usage_note IS '用款事项';

COMMENT ON column dwd_hrm_hrd_month_fund_plan_adjust_df.ywlx is '业务类型';
COMMENT ON column dwd_hrm_hrd_month_fund_plan_adjust_df.ywlxbm is '业务类型编码';
COMMENT ON column dwd_hrm_hrd_month_fund_plan_adjust_df.ywlxmc is '业务类型名称';

COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_adjust_df.etl_load_time IS 'ETL加载时间';

-- 清空数据
TRUNCATE TABLE dwd_hrm_hrd_month_fund_plan_adjust_df;

-- 插入数据
INSERT INTO dwd_hrm_hrd_month_fund_plan_adjust_df (

    fund_plan_adjust_no,
    budget_year,
    budget_month,

    budget_unit_id,
    budget_unit_code,
    budget_unit_name,

    budget_unit,
    budget_dept,
    prepare_person,
    prepare_date,
    business_type,
    total_budget_adjust_amount,
    business_dept,
    business_dept_code,

    member_unit_handler_sign,
    member_unit_biz_dept_head_sign,
    member_unit_finance_vice_sign,
    member_unit_gm_sign,
    member_unit_chairman_sign,
    hq_chairman_sign,
    hq_handler_multi_sign,
    hq_biz_dept_handler_sign,
    hq_biz_dept_head_sign,
    hq_biz_vice_gm_sign,
    hq_finance_dept_head_sign,
    hq_finance_vice_sign,
    hq_gm_sign,

    serial_no,
    fund_subcategory_name,
    fund_subcategory_code,
    fund_category_name,
    fund_category_code,
    adjust_amount,
    control_strength,
    purpose_desc,
    fund_type,
    is_bid,
    is_instruct,
    is_three_important_one_large,
    topic_no,
    topic_status,
    over_budget_type,
    over_budget_amount,
    usage_note,
            ywlx,
    ywlxbm,
    ywlxmc,

    etl_load_time
)

SELECT

    main.field0020 AS fund_plan_adjust_no,
    main.field0008 AS budget_year,
    main.field0032 AS budget_month,

    -- 新增预算单位信息
    main.field0070 AS budget_unit_id,
    org.code AS budget_unit_code,
    org.name AS budget_unit_name,

    main.field0070 AS budget_unit,
    main.field0001 AS budget_dept,
    main.field0021 AS prepare_person,
    main.field0022 AS prepare_date,
    main.field0054 AS business_type,
    main.field0071 AS total_budget_adjust_amount,
    main.field0080 AS business_dept,
    main.field0081 AS business_dept_code,

    main.field0055 AS member_unit_handler_sign,
    main.field0056 AS member_unit_biz_dept_head_sign,
    main.field0057 AS member_unit_finance_vice_sign,
    main.field0058 AS member_unit_gm_sign,
    main.field0059 AS member_unit_chairman_sign,
    main.field0061 AS hq_chairman_sign,
    main.field0062 AS hq_handler_multi_sign,
    main.field0063 AS hq_biz_dept_handler_sign,
    main.field0064 AS hq_biz_dept_head_sign,
    main.field0065 AS hq_biz_vice_gm_sign,
    main.field0066 AS hq_finance_dept_head_sign,
    main.field0067 AS hq_finance_vice_sign,
    main.field0068 AS hq_gm_sign,

    detail1.field0034 AS serial_no,
    detail1.field0035 AS fund_subcategory_name,
    detail1.field0036 AS fund_subcategory_code,
    detail1.field0037 AS fund_category_name,
    detail1.field0038 AS fund_category_code,
    CAST(detail1.field0039 AS NUMERIC(20,2)) AS adjust_amount,
    detail1.field0040 AS control_strength,
    detail1.field0041 AS purpose_desc,
    detail1.field0042 AS fund_type,
    detail1.field0073 AS is_bid,
    detail1.field0074 AS is_instruct,
    detail1.field0075 AS is_three_important_one_large,
    detail1.field0076 AS topic_no,
    detail1.field0077 AS topic_status,
    detail1.field0078 AS over_budget_type,
    CAST(detail1.field0079 AS NUMERIC(20,2)) AS over_budget_amount,
    detail1.field0082 AS usage_note,
    
            -- 业务类型
    CAST(main.field0054 as VARCHAR(4000)) as ywlx,
    CAST(ywlx.field0005 as VARCHAR(4000)) as ywlxbm,
    CAST(null as VARCHAR(4000)) as ywlxmc,

    CURRENT_TIMESTAMP AS etl_load_time

FROM ods_oa_formmain_0768 main

LEFT JOIN ods_oa_formson_0769 detail1
    ON main.id = detail1.formmain_id

LEFT JOIN ods_oa_org_unit org
    ON org.id = CASE
                    WHEN main.field0070 ~ '^\d+$'
                    THEN main.field0070::BIGINT
                end
 
                left join ods_oa_formmain_0680 ywlx
on ywlx.field0001=main.field0054

WHERE detail1.formmain_id IS NOT NULL;

-- 查询验证
select *
FROM dwd_hrm_hrd_month_fund_plan_adjust_df;