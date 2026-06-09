-- PostgreSQL 标准语法
 DROP TABLE IF EXISTS dwd_hrm_hrd_month_fund_plan_prepare_df;

CREATE TABLE dwd_hrm_hrd_month_fund_plan_prepare_df (
    -- 主表基础信息
    fund_plan_no VARCHAR(100),
    budget_year NUMERIC(20,0),
    budget_month NUMERIC(20,0),

    -- 新增：预算单位编码、名称
    budget_unit_code VARCHAR(100),
    budget_unit_name VARCHAR(200),

    budget_unit VARCHAR(20),
    budget_dept VARCHAR(20),
    prepare_person VARCHAR(20),
    prepare_date TIMESTAMP,
    business_type NUMERIC(19,0),
    total_budget_amount NUMERIC(20,2),
    business_dept VARCHAR(100),
    business_dept_code VARCHAR(100),
    unit_code VARCHAR(100),
    unit_attribute NUMERIC(19,0),
    monthly_fund_total NUMERIC(22,2),

    -- 主表签字流程字段
    member_unit_handler_sign VARCHAR(4000),
    member_unit_biz_dept_head_sign VARCHAR(4000),
    member_unit_finance_vice_sign VARCHAR(4000),
    member_unit_gm_sign VARCHAR(4000),
    member_unit_chairman_sign VARCHAR(4000),
    hq_handler_multi_sign VARCHAR(4000),
    hq_biz_dept_handler_sign VARCHAR(4000),
    hq_biz_dept_head_sign VARCHAR(4000),
    hq_biz_vice_gm_sign VARCHAR(4000),
    hq_finance_dept_head_sign VARCHAR(4000),
    hq_finance_vice_sign VARCHAR(4000),
    hq_gm_sign VARCHAR(4000),

    -- 明细表1业务字段
    serial_no NUMERIC(20,0),
    fund_subcategory_name VARCHAR(100),
    fund_subcategory_code VARCHAR(100),
    fund_category_name VARCHAR(100),
    fund_category_code VARCHAR(100),
    budget_amount NUMERIC(20,2),
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
    contract_no VARCHAR(100),
    counterparty_name VARCHAR(100),
    counterparty_bank VARCHAR(100),
    counterparty_account VARCHAR(100),
    contract_total_amount NUMERIC(20,2),
    paid_contract_amount NUMERIC(20,2),
    
        -- ========== 业务类型字段 ==========
    ywlx VARCHAR(4000),
    ywlxbm VARCHAR(4000),
	ywlxmc VARCHAR(4000),

    etl_load_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 表注释
COMMENT ON TABLE dwd_hrm_hrd_month_fund_plan_prepare_df IS 'DWD-HRD月度资金计划编制明细事实表 | 中文名：资金计划编制明细事实表（HRD月度报表）';

-- 主表基础信息字段注释
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.fund_plan_no IS '月度资金预算编制流水号';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.budget_year IS '预算年';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.budget_month IS '预算月';

-- 新增字段注释
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.budget_unit_code IS '预算单位编码';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.budget_unit_name IS '预算单位名称';

COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.budget_unit IS '预算单位';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.budget_dept IS '预算部门';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.prepare_person IS '编制人';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.prepare_date IS '编制日期';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.business_type IS '业务类型';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.total_budget_amount IS '预算金额合计';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.business_dept IS '业务归口部门';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.business_dept_code IS '业务归口部门代码';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.unit_code IS '单位编号';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.unit_attribute IS '单位属性';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.monthly_fund_total IS '月度资金合计';

-- 主表签字流程字段注释
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.member_unit_handler_sign IS '成员单位经办人签字';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.member_unit_biz_dept_head_sign IS '成员单位业务部门负责人签字';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.member_unit_finance_vice_sign IS '成员单位主管业务副总签字';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.member_unit_gm_sign IS '成员单位总经理签字';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.member_unit_chairman_sign IS '成员单位董事长签字';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.hq_handler_multi_sign IS '总部经办人（多选）';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.hq_biz_dept_handler_sign IS '总部业务部门经办人';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.hq_biz_dept_head_sign IS '总部业务部门负责人';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.hq_biz_vice_gm_sign IS '总部业务主管副总';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.hq_finance_dept_head_sign IS '总部财务部部长';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.hq_finance_vice_sign IS '总部财务副总';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.hq_gm_sign IS '总部总经理';

-- 明细表1业务字段注释
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.serial_no IS '序号';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.fund_subcategory_name IS '小类名称';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.fund_subcategory_code IS '小类编码';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.fund_category_name IS '大类名称';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.fund_category_code IS '大类编码';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.budget_amount IS '预算金额';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.control_strength IS '管控强度';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.purpose_desc IS '用途描述';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.fund_type IS '资金类别';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.is_bid IS '是否招标';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.is_instruct IS '是否批示';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.is_three_important_one_large IS '是否三重一大';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.topic_no IS '议题编号';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.topic_status IS '议题状态';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.over_budget_type IS '超预算类型';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.over_budget_amount IS '超预算金额';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.usage_note IS '用款事项';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.contract_no IS '合同编号';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.counterparty_name IS '对方单位名称';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.counterparty_bank IS '对方开户银行';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.counterparty_account IS '对方账号';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.contract_total_amount IS '合同总金额';
COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.paid_contract_amount IS '已付款合同金额';

COMMENT ON column dwd_hrm_hrd_month_fund_plan_prepare_df.ywlx is '业务类型';
COMMENT ON column dwd_hrm_hrd_month_fund_plan_prepare_df.ywlxbm is '业务类型编码';
COMMENT ON column dwd_hrm_hrd_month_fund_plan_prepare_df.ywlxmc is '业务类型名称';


COMMENT ON COLUMN dwd_hrm_hrd_month_fund_plan_prepare_df.etl_load_time IS 'ETL加载时间';

-- 清空全量数据
TRUNCATE TABLE dwd_hrm_hrd_month_fund_plan_prepare_df;

-- 插入全量数据
INSERT INTO dwd_hrm_hrd_month_fund_plan_prepare_df (
    fund_plan_no,
    budget_year,
    budget_month,

    -- 新增字段
    budget_unit_code,
    budget_unit_name,

    budget_unit,
    budget_dept,
    prepare_person,
    prepare_date,
    business_type,
    total_budget_amount,
    business_dept,
    business_dept_code,
    unit_code,
    unit_attribute,
    monthly_fund_total,

    member_unit_handler_sign,
    member_unit_biz_dept_head_sign,
    member_unit_finance_vice_sign,
    member_unit_gm_sign,
    member_unit_chairman_sign,
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
    budget_amount,
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
    contract_no,
    counterparty_name,
    counterparty_bank,
    counterparty_account,
    contract_total_amount,
    paid_contract_amount,

        ywlx,
    ywlxbm,
    ywlxmc,
    
    etl_load_time
)
SELECT 
    -- 主表基础信息
    main.field0020 AS fund_plan_no,
    main.field0008 AS budget_year,
    main.field0032 AS budget_month,

    -- 新增：预算单位编码、名称
    org.code AS budget_unit_code,
    org.name AS budget_unit_name,

    main.field0070 AS budget_unit,
    main.field0001 AS budget_dept,
    main.field0021 AS prepare_person,
    main.field0022 AS prepare_date,
    main.field0054 AS business_type,
    main.field0071 AS total_budget_amount,
    main.field0080 AS business_dept,
    main.field0081 AS business_dept_code,
    main.field0083 AS unit_code,
    main.field0088 AS unit_attribute,
    main.field0090 AS monthly_fund_total,

    -- 主表签字流程字段
    main.field0055 AS member_unit_handler_sign,
    main.field0056 AS member_unit_biz_dept_head_sign,
    main.field0057 AS member_unit_finance_vice_sign,
    main.field0058 AS member_unit_gm_sign,
    main.field0059 AS member_unit_chairman_sign,
    main.field0062 AS hq_handler_multi_sign,
    main.field0063 AS hq_biz_dept_handler_sign,
    main.field0064 AS hq_biz_dept_head_sign,
    main.field0065 AS hq_biz_vice_gm_sign,
    main.field0066 AS hq_finance_dept_head_sign,
    main.field0067 AS hq_finance_vice_sign,
    main.field0068 AS hq_gm_sign,

    -- 明细表1业务字段
    detail1.field0034 AS serial_no,
    detail1.field0035 AS fund_subcategory_name,
    detail1.field0036 AS fund_subcategory_code,
    detail1.field0037 AS fund_category_name,
    detail1.field0038 AS fund_category_code,
    CAST(detail1.field0039 AS NUMERIC(20,2)) AS budget_amount,
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
    detail1.field0084 AS contract_no,
    detail1.field0085 AS counterparty_name,
    detail1.field0086 AS counterparty_bank,
    detail1.field0087 AS counterparty_account,
    CAST(detail1.field0091 AS NUMERIC(20,2)) AS contract_total_amount,
    CAST(detail1.field0092 AS NUMERIC(20,2)) AS paid_contract_amount,
    
        -- 业务类型
    CAST(main.field0054 as VARCHAR(4000)) as ywlx,
    CAST(ywlx.field0005 as VARCHAR(4000)) as ywlxbm,
    CAST(null as VARCHAR(4000)) as ywlxmc,

    CURRENT_TIMESTAMP AS etl_load_time
FROM 
    ods_oa_formmain_0648 main
LEFT JOIN ods_oa_formson_0651 detail1
    ON main.id = detail1.formmain_id

-- 新增关联预算单位表
LEFT JOIN ods_oa_org_unit org
    ON org.id = main.field0070::BIGINT
    
left join ods_oa_formmain_0680 ywlx
on ywlx.field0001=main.field0054

WHERE 
    detail1.formmain_id IS NOT NULL;

-- 查询验证
SELECT * 
FROM dwd_hrm_hrd_month_fund_plan_prepare_df;


SELECT 
    -- 主表基础信息
    main.field0020 AS fund_plan_no,
    main.field0008 AS budget_year,
    main.field0032 AS budget_month,

    -- 新增：预算单位编码、名称
    org.code AS budget_unit_code,
    org.name AS budget_unit_name,

    main.field0070 AS budget_unit,
    main.field0001 AS budget_dept,
    main.field0021 AS prepare_person,
    main.field0022 AS prepare_date,
    main.field0054 AS business_type,
    main.field0071 AS total_budget_amount,
    main.field0080 AS business_dept,
    main.field0081 AS business_dept_code,
    main.field0083 AS unit_code,
    main.field0088 AS unit_attribute,
    main.field0090 AS monthly_fund_total,

    -- 主表签字流程字段
    main.field0055 AS member_unit_handler_sign,
    main.field0056 AS member_unit_biz_dept_head_sign,
    main.field0057 AS member_unit_finance_vice_sign,
    main.field0058 AS member_unit_gm_sign,
    main.field0059 AS member_unit_chairman_sign,
    main.field0062 AS hq_handler_multi_sign,
    main.field0063 AS hq_biz_dept_handler_sign,
    main.field0064 AS hq_biz_dept_head_sign,
    main.field0065 AS hq_biz_vice_gm_sign,
    main.field0066 AS hq_finance_dept_head_sign,
    main.field0067 AS hq_finance_vice_sign,
    main.field0068 AS hq_gm_sign,

    -- 明细表1业务字段
    detail1.field0034 AS serial_no,
    detail1.field0035 AS fund_subcategory_name,
    detail1.field0036 AS fund_subcategory_code,
    detail1.field0037 AS fund_category_name,
    detail1.field0038 AS fund_category_code,
    CAST(detail1.field0039 AS NUMERIC(20,2)) AS budget_amount,
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
    detail1.field0084 AS contract_no,
    detail1.field0085 AS counterparty_name,
    detail1.field0086 AS counterparty_bank,
    detail1.field0087 AS counterparty_account,
    CAST(detail1.field0091 AS NUMERIC(20,2)) AS contract_total_amount,
    CAST(detail1.field0092 AS NUMERIC(20,2)) AS paid_contract_amount,
    
        -- 业务类型
    CAST(main.field0054 as VARCHAR(4000)) as ywlx,
    CAST(ywlx.field0005 as VARCHAR(4000)) as ywlxbm,
    CAST(null as VARCHAR(4000)) as ywlxmc,

    CURRENT_TIMESTAMP AS etl_load_time
FROM 
    ods_oa_formmain_0648 main
LEFT JOIN ods_oa_formson_0651 detail1
    ON main.id = detail1.formmain_id

-- 新增关联预算单位表
LEFT JOIN ods_oa_org_unit org
    ON org.id = main.field0070::BIGINT
    
left join ods_oa_formmain_0680 ywlx
on ywlx.field0001=main.field0054

WHERE 
    detail1.formmain_id IS NOT NULL and ;
