drop table if exists lookup_lookml_points;
create table lookup_lookml_points
( keyword_type		varchar(50)
, keyword			varchar(50)
, quality_points	decimal
); 

--  NUMERATORS
insert into lookup_lookml_points values ('denominator'	,'measure:'				,1);
insert into lookup_lookml_points values ('denominator'	,'dimension:'			,1);
insert into lookup_lookml_points values ('denominator'	,'dimension_group:'		,1);

--  VIP QUALITY IMPROVEMENTS
insert into lookup_lookml_points values ('numerator'    ,'hidden: true'         ,1);    -- remove junk
insert into lookup_lookml_points values ('numerator'    ,'suggestions:'         ,1);    -- aid understanding
insert into lookup_lookml_points values ('numerator'    ,'description:'         ,1);    -- aid understanding
insert into lookup_lookml_points values ('numerator'    ,'alias:'               ,1);    -- prevent errors
insert into lookup_lookml_points values ('numerator'    ,'drill_fields:'        ,1);    -- expand capability
insert into lookup_lookml_points values ('numerator'    ,'html:'                ,1);    -- expand capability
insert into lookup_lookml_points values ('numerator'    ,'links:'               ,1);    -- expand capability

--  MODERATELY IMPORTANT QUALITY IMPROVEMENTS
insert into lookup_lookml_points values ('numerator'    ,'view_label:'          ,0.5);    -- aid understanding
insert into lookup_lookml_points values ('numerator'    ,'group_label:'         ,0.5);    -- aid understanding
insert into lookup_lookml_points values ('numerator'    ,'label:'               ,0.5);    -- aid understanding
insert into lookup_lookml_points values ('numerator'    ,'value_format:'        ,0.5);    -- format results
insert into lookup_lookml_points values ('numerator'    ,'value_format_name:'   ,0.5);    -- format results
insert into lookup_lookml_points values ('numerator'    ,'primary_key: true'    ,0.5);    -- increase performance
insert into lookup_lookml_points values ('numerator'    ,'type:'                ,0.5);    -- increase performance
insert into lookup_lookml_points values ('numerator'    ,'alpha_sort:'          ,0.5);    -- format results
insert into lookup_lookml_points values ('numerator'    ,'suggest_persist_for:' ,0.5);    -- increase performance
insert into lookup_lookml_points values ('numerator'    ,'suggest_dimension:'   ,0.5);    -- increase performance
insert into lookup_lookml_points values ('numerator'    ,'suggest_explore:'     ,0.5);    -- increase performance
insert into lookup_lookml_points values ('numerator'    ,'order_by_field:'      ,0.5);    -- format results
insert into lookup_lookml_points values ('numerator'    ,'can_filter:'          ,0.5);    -- aid understanding (remove irrelevant option)

--  NOT USED BECAUSE THEY ARE REQUIRED
-- insert into lookup_lookml_points values ('numerator'    ,'filters:'             ,0);
-- insert into lookup_lookml_points values ('numerator'    ,'tiers:'               ,0);
-- insert into lookup_lookml_points values ('numerator'    ,'style:'               ,0);