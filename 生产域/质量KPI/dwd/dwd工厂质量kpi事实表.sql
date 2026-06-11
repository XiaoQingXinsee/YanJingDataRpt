CREATE TABLE ads_kpi_monthly_analysis_report (
    org_name           VARCHAR(512),
    org_level          VARCHAR(512),
    department         VARCHAR(20),
    index_name         VARCHAR(512),
    parent_index_name  VARCHAR(512),
    index_level        INTEGER,
    time_dimension     VARCHAR(512),
    time_value         VARCHAR(20),
    actual_value       NUMERIC(18,10),
    target_value       NUMERIC(6,2),
    reach_flag         VARCHAR(512),
    yoy_value          NUMERIC(18,10),
    mom_value          NUMERIC(18,10),
    create_time        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. 添加表注释
COMMENT ON TABLE ads_kpi_monthly_analysis_report IS 'KPI月度分析报表(含同比环比)';

-- 3. 添加字段注释
COMMENT ON COLUMN ads_kpi_monthly_analysis_report.org_name IS '组织名称';
COMMENT ON COLUMN ads_kpi_monthly_analysis_report.org_level IS '组织层级';
COMMENT ON COLUMN ads_kpi_monthly_analysis_report.department IS '部门(酿造部/包装部)';
COMMENT ON COLUMN ads_kpi_monthly_analysis_report.index_name IS '指标名称';
COMMENT ON COLUMN ads_kpi_monthly_analysis_report.parent_index_name IS '父级指标名称';
COMMENT ON COLUMN ads_kpi_monthly_analysis_report.index_level IS '指标层级';
COMMENT ON COLUMN ads_kpi_monthly_analysis_report.time_dimension IS '时间维度';
COMMENT ON COLUMN ads_kpi_monthly_analysis_report.time_value IS '时间值(如: 2025-10)';
COMMENT ON COLUMN ads_kpi_monthly_analysis_report.actual_value IS '实际值';
COMMENT ON COLUMN ads_kpi_monthly_analysis_report.target_value IS '目标值';
COMMENT ON COLUMN ads_kpi_monthly_analysis_report.reach_flag IS '是否达标';
COMMENT ON COLUMN ads_kpi_monthly_analysis_report.yoy_value IS '同比(市场投诉:上年同月-当月; 其他:当月-上年同月)';
COMMENT ON COLUMN ads_kpi_monthly_analysis_report.mom_value IS '环比(当月-上月)';
COMMENT ON COLUMN ads_kpi_monthly_analysis_report.create_time IS '记录创建时间';

truncate table ads_kpi_monthly_analysis_report;
INSERT INTO ads_kpi_monthly_analysis_report (
    org_name, org_level, department, index_name, parent_index_name, 
    index_level, time_dimension, time_value, actual_value, target_value, 
    reach_flag, yoy_value, mom_value
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

    