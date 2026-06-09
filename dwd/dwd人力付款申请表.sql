-- ============================================================
-- 表名: dwd_hrm_hrd_month_payment_apply_df
-- 中文表名: 人力付款申请明细事实表（HRD月度报表）
-- 表描述: DWD-HRD月度人力付款申请明细事实表
-- ============================================================

 DROP TABLE IF EXISTS dwd_hrm_hrd_month_payment_apply_df;

CREATE TABLE dwd_hrm_hrd_month_payment_apply_df (

    -- ========== 组织字段 ==========
    organization_id VARCHAR(100),
    organization_code VARCHAR(100),
    organization_name VARCHAR(500),

    -- ========== 基础信息字段 ==========
    budget_year VARCHAR(50),
    budget_month VARCHAR(50),
    business_serial_no VARCHAR(100),

    -- ========== 资金分类字段 ==========
    fund_category_code VARCHAR(50),
    fund_category_name VARCHAR(500),
    fund_subcategory_code VARCHAR(50),
    fund_subcategory_name VARCHAR(500),
    fund_type VARCHAR(100),

    -- ========== 金额与往来单位字段 ==========
    apply_payment_amount DECIMAL(18,2),
    counterparty_name VARCHAR(500),
    counterparty_bank VARCHAR(500),

    -- ========== 成员单位签字字段 ==========
    member_unit_handler_sign VARCHAR(4000),
    member_unit_dept_head_sign VARCHAR(4000),
    member_unit_vice_gm_sign VARCHAR(4000),
    member_unit_finance_vice_sign VARCHAR(4000),
    member_unit_gm_sign VARCHAR(4000),
    member_unit_chairman_sign VARCHAR(4000),

    -- ========== 总部人力资源部签字字段 ==========
    hq_hr_handler_sign VARCHAR(4000),
    hq_hr_dept_head_sign VARCHAR(4000),
    hq_hr_vice_gm_sign VARCHAR(4000),

    -- ========== 总部财务部签字字段 ==========
    hq_finance_dept_head_sign VARCHAR(4000),
    hq_finance_vice_sign VARCHAR(4000),

    -- ========== 总部高层签字字段 ==========
    hq_gm_sign VARCHAR(4000),
    hq_chairman_sign VARCHAR(4000),

    -- ========== 结算中心签字字段 ==========
    settlement_auditor_sign VARCHAR(4000),
    settlement_creator_sign VARCHAR(4000),
    -- ========== 业务类型字段 ==========
    ywlx VARCHAR(4000),
    ywlxbm VARCHAR(4000),
	ywlxmc VARCHAR(4000),
    -- ========== ETL字段 ==========
    etl_load_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 表注释
-- ============================================================

COMMENT ON TABLE dwd_hrm_hrd_month_payment_apply_df
IS 'DWD-HRD月度人力付款申请明细事实表 | 中文名：人力付款申请明细事实表';

-- ============================================================
-- 字段注释
-- ============================================================

COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.organization_id IS '组织ID';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.organization_code IS '组织编码';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.organization_name IS '组织名称';

COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.budget_year IS '预算年份';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.budget_month IS '预算月份';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.business_serial_no IS '业务流水号';

COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.fund_category_code IS '资金大类编码';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.fund_category_name IS '资金大类名称';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.fund_subcategory_code IS '资金小类编码';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.fund_subcategory_name IS '资金小类名称';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.fund_type IS '资金类别';

COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.apply_payment_amount IS '本次申请付款金额';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.counterparty_name IS '对方单位名称';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.counterparty_bank IS '对方开户银行';

COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.member_unit_handler_sign IS '成员单位经办人签字';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.member_unit_dept_head_sign IS '成员单位主管部长签字';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.member_unit_vice_gm_sign IS '成员单位主管副总签字';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.member_unit_finance_vice_sign IS '成员单位财务副总签字';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.member_unit_gm_sign IS '成员单位总经理签字';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.member_unit_chairman_sign IS '成员单位董事长签字';

COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.hq_hr_handler_sign IS '总部人力资源部经办人签字';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.hq_hr_dept_head_sign IS '总部人力资源部部长签字';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.hq_hr_vice_gm_sign IS '总部人力资源部主管副总签字';

COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.hq_finance_dept_head_sign IS '总部财务部部长签字';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.hq_finance_vice_sign IS '总部财务副总签字';

COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.hq_gm_sign IS '总部总经理签字';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.hq_chairman_sign IS '总部董事长签字';

COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.settlement_auditor_sign IS '结算中心审核人签字';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.settlement_creator_sign IS '结算中心制单人签字';

COMMENT ON column dwd_hrm_hrd_month_payment_apply_df.ywlx is '业务类型';
COMMENT ON column dwd_hrm_hrd_month_payment_apply_df.ywlxbm is '业务类型编码';
COMMENT ON column dwd_hrm_hrd_month_payment_apply_df.ywlxmc is '业务类型名称';
COMMENT ON COLUMN dwd_hrm_hrd_month_payment_apply_df.etl_load_time IS 'ETL加载时间';

-- ============================================================
-- 清空全量数据
-- ============================================================

TRUNCATE TABLE dwd_hrm_hrd_month_payment_apply_df;

-- ============================================================
-- 插入全量数据
-- ============================================================

INSERT INTO dwd_hrm_hrd_month_payment_apply_df (

    organization_id,
    organization_code,
    organization_name,

    budget_year,
    budget_month,
    business_serial_no,

    fund_category_code,
    fund_category_name,
    fund_subcategory_code,
    fund_subcategory_name,
    fund_type,

    apply_payment_amount,
    counterparty_name,
    counterparty_bank,

    member_unit_handler_sign,
    member_unit_dept_head_sign,
    member_unit_vice_gm_sign,
    member_unit_finance_vice_sign,
    member_unit_gm_sign,
    member_unit_chairman_sign,

    hq_hr_handler_sign,
    hq_hr_dept_head_sign,
    hq_hr_vice_gm_sign,

    hq_finance_dept_head_sign,
    hq_finance_vice_sign,

    hq_gm_sign,
    hq_chairman_sign,

    settlement_auditor_sign,
    settlement_creator_sign,
    
    ywlx,
    ywlxbm,
    ywlxmc,

    etl_load_time
)

SELECT

    -- 组织信息
    main.field0001 AS organization_id,
    org.code AS organization_code,
    org.name AS organization_name,

    -- 主表基础信息
    main.field0040 AS budget_year,
    main.field0041 AS budget_month,
    main.field0002 AS business_serial_no,

    -- 明细表资金分类信息
    detail3.field0044 AS fund_category_code,
    detail3.field0043 AS fund_category_name,
    detail3.field0006 AS fund_subcategory_code,
    detail3.field0033 AS fund_subcategory_name,
    detail3.field0056 AS fund_type,

    -- 明细表金额与往来单位
    CAST(detail3.field0007 AS DECIMAL(18,2)) AS apply_payment_amount,
    detail3.field0035 AS counterparty_name,
    detail3.field0075 AS counterparty_bank,

    -- 成员单位签字
    main.field0017 AS member_unit_handler_sign,
    main.field0018 AS member_unit_dept_head_sign,
    main.field0020 AS member_unit_vice_gm_sign,
    main.field0037 AS member_unit_finance_vice_sign,
    main.field0021 AS member_unit_gm_sign,
    main.field0022 AS member_unit_chairman_sign,

    -- 总部人力资源部签字
    main.field0027 AS hq_hr_handler_sign,
    main.field0026 AS hq_hr_dept_head_sign,
    main.field0038 AS hq_hr_vice_gm_sign,

    -- 总部财务部签字
    main.field0039 AS hq_finance_dept_head_sign,
    main.field0066 AS hq_finance_vice_sign,

    -- 总部高层签字
    main.field0064 AS hq_gm_sign,
    main.field0065 AS hq_chairman_sign,

    -- 结算中心签字
    main.field0031 AS settlement_auditor_sign,
    main.field0032 AS settlement_creator_sign,
    
    -- 业务类型
    CAST(main.field0058 as VARCHAR(4000)) as ywlx,
    CAST(ywlx.field0005 as VARCHAR(4000)) as ywlxbm,
    CAST(null as VARCHAR(4000)) as ywlxmc,
    

    CURRENT_TIMESTAMP AS etl_load_time

FROM ods_oa_formmain_0663 main

INNER JOIN ods_oa_formson_0664 detail3
    ON main.id = detail3.formmain_id

LEFT JOIN ods_oa_org_unit org
    ON org.id = CASE
                    WHEN main.field0001 ~ '^\d+$'
                    THEN main.field0001::BIGINT
                end
left join ods_oa_formmain_0680 ywlx
on ywlx.field0001=main.field0058
                
                ;

-- ============================================================
-- 查询验证
-- ============================================================

SELECT distinct organization_code
FROM dwd_hrm_hrd_month_payment_apply_df  ;

select * from dwd_hrm_hrd_month_payment_apply_df where organization_code='北京工厂';
-- 北京工厂
select * from ods_oa_org_unit where id='2089741071008025012';

select * from ods_oa_org_unit where name='北京工厂';

select * from ods_oa_org_unit where "right"(name,1)='Z';


select * from dwd_hrm_hrd_month_payment_apply_df where organization_id in('2130906607892383263'
,'2089741071008025012'
,'-6789248597258907709'
,'8105509894338201247');

select * FROM ods_oa_formmain_0663 main where main.field0001='2089741071008025012';


select field0002,count(field0002) FROM ods_oa_formmain_0663 group by field0002 having count(field0002)>1;


