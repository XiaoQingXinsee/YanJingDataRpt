-- 创建 DWD 层 KPI月度指标明细事实表
drop table if exists dwd_kpi_monthly_index_detail;
CREATE TABLE if not exists dwd_kpi_monthly_index_detail (
    -- 外键/主键字段
 org_id               VARCHAR(64),
    index_code           VARCHAR(64),
    parent_index_code    VARCHAR(64),
    
    -- 退化维度字段
    org_name             VARCHAR(512),
    org_level            VARCHAR(512),
    department           VARCHAR(20),
    index_name           VARCHAR(512),
    parent_index_name    VARCHAR(512),
    index_level          INTEGER,
    time_dimension       VARCHAR(512),
    time_value           VARCHAR(20),
    
    -- 度量/事实字段
    actual_value         NUMERIC(18,10),
    target_value         NUMERIC(6,2),
    reach_flag           VARCHAR(512),
    
    -- 衍生计算字段 (注: 同比环比通常在DWS/ADS计算，此处按需求保留在DWD)
    yoy_value            NUMERIC(18,10),
    mom_value            NUMERIC(18,10),
    
    -- 审计字段
    create_time          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 表注释
COMMENT ON TABLE dwd_kpi_monthly_index_detail IS 'KPI月度指标明细事实表';

-- 外键/主键字段注释
COMMENT ON COLUMN dwd_kpi_monthly_index_detail.org_id IS '组织ID';
COMMENT ON COLUMN dwd_kpi_monthly_index_detail.index_code IS '指标编码';
COMMENT ON COLUMN dwd_kpi_monthly_index_detail.parent_index_code IS '父级指标编码';

-- 退化维度字段注释
COMMENT ON COLUMN dwd_kpi_monthly_index_detail.org_name IS '组织名称';
COMMENT ON COLUMN dwd_kpi_monthly_index_detail.org_level IS '组织层级';
COMMENT ON COLUMN dwd_kpi_monthly_index_detail.department IS '部门(酿造部/包装部)';
COMMENT ON COLUMN dwd_kpi_monthly_index_detail.index_name IS '指标名称';
COMMENT ON COLUMN dwd_kpi_monthly_index_detail.parent_index_name IS '父级指标名称';
COMMENT ON COLUMN dwd_kpi_monthly_index_detail.index_level IS '指标层级';
COMMENT ON COLUMN dwd_kpi_monthly_index_detail.time_dimension IS '时间维度(month/week/year)';
COMMENT ON COLUMN dwd_kpi_monthly_index_detail.time_value IS '时间值(如: 2025-10)';

-- 度量/事实字段注释
COMMENT ON COLUMN dwd_kpi_monthly_index_detail.actual_value IS '实际值';
COMMENT ON COLUMN dwd_kpi_monthly_index_detail.target_value IS '目标值';
COMMENT ON COLUMN dwd_kpi_monthly_index_detail.reach_flag IS '是否达标';

-- 衍生计算字段注释
COMMENT ON COLUMN dwd_kpi_monthly_index_detail.yoy_value IS '同比(市场投诉:上年同月-当月; 其他:当月-上年同月)';
COMMENT ON COLUMN dwd_kpi_monthly_index_detail.mom_value IS '环比(当月-上月)';

-- 审计字段注释
COMMENT ON COLUMN dwd_kpi_monthly_index_detail.create_time IS '数据加载时间';

truncate table dwd_kpi_monthly_index_detail;

INSERT INTO dwd_kpi_monthly_index_detail (
    org_id, index_code, parent_index_code,
    org_name, org_level, department, index_name, parent_index_name, 
    index_level, time_dimension, time_value, 
    actual_value, target_value, reach_flag, 
    yoy_value, mom_value
)
WITH base AS (
    SELECT 
        k.orgid, k.indexcode, k.parentindexcode, k.month, k.indexnum, 
        k.targetvalue, k.reachflag, k.timedimension,
        o.orgname, o.orglevel AS org_orglevel,
        i.name AS index_name, pi.name AS parent_index_name, i.level AS index_level,
        TO_CHAR((k.month || '-01')::date - INTERVAL '1 year', 'YYYY-MM') AS prev_year_month,
        TO_CHAR((k.month || '-01')::date - INTERVAL '1 month', 'YYYY-MM') AS prev_month_str
    FROM ods_kpidata k
    JOIN ods_t_core_org o ON k.orgid = o.id
    JOIN ods_t_lims_kpi_index i ON k.indexcode = i.code
    LEFT JOIN ods_t_lims_kpi_index pi ON k.parentindexcode = pi.code
    WHERE k.timedimension = 'month'
)
SELECT 
    b.orgid,
    b.indexcode,
    b.parentindexcode,
    b.orgname,
    b.org_orglevel,
    CASE WHEN b.index_name LIKE '酿造%' THEN '酿造部'
         WHEN b.index_name LIKE '包装%' THEN '包装部'
         WHEN b.parent_index_name LIKE '酿造%' THEN '酿造部'
         WHEN b.parent_index_name LIKE '包装%' THEN '包装部'
         ELSE NULL END,
    b.index_name,
    b.parent_index_name,
    b.index_level,
    b.timedimension,
    b.month,
    b.indexnum,
    b.targetvalue,
    b.reachflag,
    CASE WHEN b.index_name LIKE '%市场投诉%' THEN py.indexnum - b.indexnum
         ELSE b.indexnum - py.indexnum END,
    b.indexnum - pm.indexnum
FROM base b
LEFT JOIN ods_kpidata py 
    ON py.orgid = b.orgid AND py.indexcode = b.indexcode 
    AND py.month = b.prev_year_month AND py.timedimension = 'month'
LEFT JOIN ods_kpidata pm 
    ON pm.orgid = b.orgid AND pm.indexcode = b.indexcode 
    AND pm.month = b.prev_month_str AND pm.timedimension = 'month';