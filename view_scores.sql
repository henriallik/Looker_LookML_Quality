delete from reports.lookup_looker_file_contents_combined
where field_type = '';

update reports.lookup_looker_file_contents_combined set label = null where label = '';
update reports.lookup_looker_file_contents_combined set description = null where description = '';
update reports.lookup_looker_file_contents_combined set type = null where type = '';
update reports.lookup_looker_file_contents_combined set flag_hidden = null where flag_hidden = '';
update reports.lookup_looker_file_contents_combined set flag_primary_key = null where flag_primary_key = '';
update reports.lookup_looker_file_contents_combined set value_format = null where value_format = '';
update reports.lookup_looker_file_contents_combined set suggestions = null where suggestions = '';
update reports.lookup_looker_file_contents_combined set alias = null where alias = '';
update reports.lookup_looker_file_contents_combined set timeframes = null where timeframes = '';
update reports.lookup_looker_file_contents_combined set tiers = null where tiers = '';
update reports.lookup_looker_file_contents_combined set drill_fields = null where drill_fields = '';
update reports.lookup_looker_file_contents_combined set view_label = null where view_label = '';
update reports.lookup_looker_file_contents_combined set field_name = split_part(field_name,' ',1) where field_name ilike '%{%';


-- -------------------------------------------------------------------------------
--  Add up all the points for each column
-- -------------------------------------------------------------------------------
drop table if exists reports.tmp_file_points;
create table reports.tmp_file_points
( model_name     varchar(255)
, filename			varchar(255)
, field_name		varchar(255)
, snapshot_date		text
, keyword_type  	varchar(255)
, keyword		  	varchar(255)
, quality_points 	decimal
);


insert into reports.tmp_file_points
select
thelist.model_name
, thelist.filename
, thelist.field_name
, thelist.snapshot_date
, points.keyword_type
, points.keyword
, points.quality_points
from reports.lookup_looker_file_contents_combined thelist
join reports.lookup_lookml_points	points
       on points.keyword = 'label:'
where thelist.label is not null
;

insert into reports.tmp_file_points
select
thelist.model_name
, thelist.filename
, thelist.field_name
, thelist.snapshot_date
, points.keyword_type
, points.keyword
, points.quality_points
from reports.lookup_looker_file_contents_combined thelist
join reports.lookup_lookml_points	points
       on points.keyword = 'description:'
where thelist.description is not null
;

insert into reports.tmp_file_points
select
  thelist.model_name
, thelist.filename
, thelist.field_name
, thelist.snapshot_date
, points.keyword_type
, points.keyword
, points.quality_points
from reports.lookup_looker_file_contents_combined thelist
join reports.lookup_lookml_points	points
       on points.keyword = 'type:'
where thelist.type is not null
;

insert into reports.tmp_file_points
select
  thelist.model_name
, thelist.filename
, thelist.field_name
, thelist.snapshot_date
, points.keyword_type
, points.keyword
, points.quality_points
from reports.lookup_looker_file_contents_combined thelist
join reports.lookup_lookml_points	points
       on points.keyword = 'hidden: true'
where thelist.flag_hidden ilike '%hidden:%true%'
  and thelist.flag_hidden not ilike '%-- %hidden%'
;

insert into reports.tmp_file_points
select
  thelist.model_name
, thelist.filename
, thelist.field_name
, thelist.snapshot_date
, points.keyword_type
, points.keyword
, points.quality_points
from reports.lookup_looker_file_contents_combined thelist
join reports.lookup_lookml_points	points
       on points.keyword = 'primary_key: true'
where thelist.flag_primary_key ilike '%primary_key:%true%'
  and thelist.flag_hidden not ilike '%-- %primary%'
;

insert into reports.tmp_file_points
select
  thelist.model_name
, thelist.filename
, thelist.field_name
, thelist.snapshot_date
, points.keyword_type
, points.keyword
, points.quality_points
from reports.lookup_looker_file_contents_combined thelist
join reports.lookup_lookml_points	points
       on points.keyword = 'value_format:'
where thelist.value_format is not null
;

insert into reports.tmp_file_points
select
  thelist.model_name
, thelist.filename
, thelist.field_name
, thelist.snapshot_date
, points.keyword_type
, points.keyword
, points.quality_points
from reports.lookup_looker_file_contents_combined thelist
join reports.lookup_lookml_points	points
       on points.keyword = 'suggestions:'
where thelist.suggestions is not null
;

insert into reports.tmp_file_points
select
  thelist.model_name
, thelist.filename
, thelist.field_name
, thelist.snapshot_date
, points.keyword_type
, points.keyword
, points.quality_points
from reports.lookup_looker_file_contents_combined thelist
join reports.lookup_lookml_points	points
       on points.keyword = 'alias:'
where thelist.alias is not null
;

insert into reports.tmp_file_points
select
	thelist.model_name
, thelist.filename
, thelist.field_name
, thelist.snapshot_date
, points.keyword_type
, points.keyword
, points.quality_points
from reports.lookup_looker_file_contents_combined thelist
join reports.lookup_lookml_points	points
       on points.keyword = 'timeframes:'
where thelist.timeframes is not null
;

insert into reports.tmp_file_points
select
	thelist.model_name
, thelist.filename
, thelist.field_name
, thelist.snapshot_date
, points.keyword_type
, points.keyword
, points.quality_points
from reports.lookup_looker_file_contents_combined thelist
join reports.lookup_lookml_points	points
       on points.keyword = 'tiers:'
where thelist.tiers is not null
;
insert into reports.tmp_file_points
select
	thelist.model_name
,  thelist.filename
, thelist.field_name
, thelist.snapshot_date
, points.keyword_type
, points.keyword
, points.quality_points
from reports.lookup_looker_file_contents_combined thelist
join reports.lookup_lookml_points	points
       on points.keyword = 'drill_fields:'
where thelist.drill_fields is not null
;

insert into reports.tmp_file_points
select
	thelist.model_name
, thelist.filename
, thelist.field_name
, thelist.snapshot_date
, points.keyword_type
, points.keyword
, points.quality_points
from reports.lookup_looker_file_contents_combined thelist
join reports.lookup_lookml_points	points
       on points.keyword = 'view_label:'
where thelist.view_label is not null
;



-- -------------------------------------------------------------------------------
--  Create the output table
-- -------------------------------------------------------------------------------
drop table if exists reports.report_lookml_view_data_and_quality_combined;
create table reports.report_lookml_view_data_and_quality_combined
as
--  explain
select
  to_date(thelist.snapshot_date, 'YYYY-MM-DD')	as snapshot_date
, case
	when latest_snapshot.latest_snapshot is not null
	then true
	else false end 					            as flag_latest_snapshot
, CASE
    WHEN thelist.model_name = 'lookml_postgre' THEN 'Payments'
    WHEN thelist.model_name = 'lookML_analytics_base' THEN 'Analytics Base'
    WHEN thelist.model_name = 'lookml_greenhouse' THEN 'Greenhouse'
    WHEN thelist.model_name = 'lookml_serviceDB' THEN 'ServiceDB'
    WHEN thelist.model_name = 'lookml_findb' THEN 'FinDB'
    end as model_name
, thelist.filename
, thelist.field_type
, thelist.field_name
, thelist.label
, thelist.description
, thelist.type
, thelist.flag_hidden
, thelist.flag_primary_key
, thelist.value_format
, thelist.suggestions
, thelist.alias
, thelist.timeframes
, thelist.tiers
, thelist.drill_fields
, thelist.view_label
, thelist.full_statement
, coalesce(points.quality_points,0) as quality_points
from reports.lookup_looker_file_contents_combined thelist
left join
(	select
		model_name
	, filename
	, field_name
	, snapshot_date
	, sum(quality_points) as quality_points
	from reports.tmp_file_points
	where keyword_type = 'numerator'
	group by 1,2,3,4
) points
on ( points.model_name = thelist.model_name
 and	 	points.snapshot_date 	= thelist.snapshot_date
 and points.filename 		= thelist.filename
 and points.field_name 		= thelist.field_name )
left join
(	select
	  max(snapshot_date) as latest_snapshot
	from
	(	select distinct
		  to_date(snapshot_date, 'YYYY-MM-DD')	as snapshot_date
		from reports.lookup_looker_file_contents_combined
	) a
) latest_snapshot
on (latest_snapshot.latest_snapshot = to_date(thelist.snapshot_date, 'YYYY-MM-DD'))
;

CREATE INDEX IF NOT EXISTS ix1_report_lookml_view_data_and_quality_combined on reports.report_lookml_view_data_and_quality_combined(model_name);
CREATE INDEX IF NOT EXISTS ix2_report_lookml_view_data_and_quality_combined on reports.report_lookml_view_data_and_quality_combined(filename);
CREATE INDEX IF NOT EXISTS ix3_report_lookml_view_data_and_quality_combined on reports.report_lookml_view_data_and_quality_combined(snapshot_date);
CREATE INDEX IF NOT EXISTS ix4_report_lookml_view_data_and_quality_combined on reports.report_lookml_view_data_and_quality_combined(flag_latest_snapshot);

drop TABLE if EXISTS reports.tmp_lookml_commits_combined;

