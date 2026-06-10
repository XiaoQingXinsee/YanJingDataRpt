
drop table if exists dim_hrm_hrd_org_unit;
CREATE TABLE dim_hrm_hrd_org_unit (
    id             BIGSERIAL PRIMARY KEY,                  -- 组织单元唯一标识ID（自增）
    name           VARCHAR(200) NOT NULL,                  -- 组织单元名称
    code           VARCHAR(100),                           -- 组织单元编码
    short_name     VARCHAR(100),                           -- 组织单元简称
    type           VARCHAR(50),                            -- 组织单元类型（如：部门、子公司等）
    is_group       bigint,                  -- 是否集团
    is_enable      bigint,                   -- 是否启用
    path           VARCHAR(500),                           -- 组织路径（如：/1/2/3）
    is_deleted     bigint,                  -- 是否删除（逻辑删除）
    status         VARCHAR(20),                            -- 状态（如：active, inactive）
    level_scope    VARCHAR(50),                            -- 层级范围
    org_account_id BIGINT                                  -- 组织账户ID（关联账户表）
);

-- 添加表注释
COMMENT ON TABLE dim_hrm_hrd_org_unit IS 'OA组织维度表';

-- 添加字段注释
COMMENT ON COLUMN dim_hrm_hrd_org_unit.id IS '组织单元唯一标识ID';
COMMENT ON COLUMN dim_hrm_hrd_org_unit.name IS '组织单元名称';
COMMENT ON COLUMN dim_hrm_hrd_org_unit.code IS '组织单元编码';
COMMENT ON COLUMN dim_hrm_hrd_org_unit.short_name IS '组织单元简称';
COMMENT ON COLUMN dim_hrm_hrd_org_unit.type IS '组织单元类型';
COMMENT ON COLUMN dim_hrm_hrd_org_unit.is_group IS '是否集团';
COMMENT ON COLUMN dim_hrm_hrd_org_unit.is_enable IS '是否启用';
COMMENT ON COLUMN dim_hrm_hrd_org_unit.path IS '组织路径';
COMMENT ON COLUMN dim_hrm_hrd_org_unit.is_deleted IS '是否删除';
COMMENT ON COLUMN dim_hrm_hrd_org_unit.status IS '状态';
COMMENT ON COLUMN dim_hrm_hrd_org_unit.level_scope IS '层级范围';
COMMENT ON COLUMN dim_hrm_hrd_org_unit.org_account_id IS '组织账户ID';
truncate table dim_hrm_hrd_org_unit;
insert into dim_hrm_hrd_org_unit
select id,
       name,
       code,
       short_name,
       type,
       is_group,
       is_enable,
       path,
       is_deleted,
       status,
       level_scope,
       org_account_id
from ods_oa_org_unit;