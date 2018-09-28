
--drop TABLE if EXISTS reports.tmp_lookml_commits_combined;

drop table if exists reports.lookup_lookml_quality_commits_combined;
create table reports.lookup_lookml_quality_commits_combined as
-- delete from lookup_lookml_quality_commits;
-- insert into lookup_lookml_quality_commits
select distinct
  CASE
    WHEN c.model_name = 'lookml_postgre' THEN 'Payments'
    WHEN c.model_name = 'lookML_analytics_base' THEN 'Analytics Base'
    WHEN c.model_name = 'lookml_greenhouse' THEN 'Greenhouse'
    WHEN c.model_name = 'lookml_serviceDB' THEN 'ServiceDB'
    WHEN c.model_name = 'lookml_findb' THEN 'FinDB'
    end as model_name
, c.author
, c.commit_time::DATE
, p.keyword_type
, p.keyword
, p.quality_points
, c.summary
, c.filename
, c.lines_added
, c.lines_removed
--, str_count(c.lines_added,p.keyword) 						as count_keyword_added
,array_length(string_to_array(c.lines_added, p.keyword), 1) - 1 as count_keyword_added
, p.quality_points * (SELECT count(*) from regexp_matches(c.lines_added,p.keyword,'g')) 	as count_points_added
--, str_count(c.lines_removed,p.keyword) 					    as count_keyword_removed
,(SELECT count(*) from regexp_matches(c.lines_removed,p.keyword,'g')) as count_keyword_removed
--, p.quality_points * str_count(c.lines_removed,p.keyword) 	as count_points_removed
, p.quality_points * (SELECT count(*) from regexp_matches(c.lines_removed,p.keyword,'g')) as count_points_removed
from reports.tmp_lookml_commits_combined	c
join reports.lookup_lookml_points p
  on (1=1)
group by 1,2,3,4,5,6,7,8,9,10
having (SELECT count(*) from regexp_matches(c.lines_removed,p.keyword,'g')) > 0 or (SELECT count(*) from regexp_matches(c.lines_added,p.keyword,'g')) > 0 -- cartesian join so this will kick out the dummies
;

-- Removing commits by Segah - he was developer from Looker who helped us to set up LookML models
UPDATE reports.lookup_lookml_quality_commits_combined set author= null where author = 'Segah Meer';
-- Deleting commits from 10.04.2017 since we upgraded LookML version                                                                                                                      
DELETE FROM reports.lookup_lookml_quality_commits_combined where commit_time = '2017-04-10';

CREATE INDEX IF NOT EXISTS ix1_lookup_lookml_quality_commits_combined on reports.lookup_lookml_quality_commits_combined(model_name);
CREATE INDEX IF NOT EXISTS ix2_lookup_lookml_quality_commits_combined on reports.lookup_lookml_quality_commits_combined(commit_time);
CREATE INDEX IF NOT EXISTS ix3_lookup_lookml_quality_commits_combined on reports.lookup_lookml_quality_commits_combined(filename);
CREATE INDEX IF NOT EXISTS ix4_lookup_lookml_quality_commits_combined on reports.lookup_lookml_quality_commits_combined(author);

