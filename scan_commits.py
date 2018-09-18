# encoding=utf8

import os
import sys

reload(sys)
sys.setdefaultencoding("utf-8")

import pandas as pd
from git import Repo
from datetime import datetime
from sqlalchemy import create_engine
from config import postgres_connectors
from sqlalchemy.engine import url

date = str(datetime.today().strftime('%Y-%m-%d'))
#date = "2017-11-17"
snapshot = "snapshot_" + date

# How to update LookML dashboards
# 1. Run scan_views.py
# 2. Now run lookMl_view_scores_combined.sql - every script in that order
# 3. Then drop TABLE if EXISTS reports.tmp_lookml_commits_combined;
# 4. Run scan_commits.py
# 5. Then rebuild reports.lookup_lookml_quality_commits_combined in lookML_commit_scores_combined.sql
# 6. Check dashboards

lookml_postgre = "lookml_postgre_snapshot_" + date
lookml_greenhouse = "lookml_greenhouse_snapshot_" + date
lookml_findb = "lookml_findb_snapshot_" + date
lookml_servicedb = "lookml_serviceDB_snapshot_" + date
lookml_analytics_base = "lookML_analytics_base_snapshot_" + date

repos = [lookml_postgre, lookml_greenhouse, lookml_findb, lookml_servicedb, lookml_analytics_base]

for repo in repos:

    if "postgre" in repo:
        model_name = "lookml_postgre"
    elif "greenhouse" in repo:
        model_name = "lookml_greenhouse"
    elif "findb" in repo:
        model_name = "lookml_findb"
    elif "serviceDB" in repo:
        model_name = "lookml_serviceDB"
    elif "analytics_base" in repo:
        model_name = "lookML_analytics_base"
    else:
        model_name = "Not defined"

    # Choose the current repository directory or a previous snapshot
    path = "G:/My Drive/Analytics/LookML/" + model_name + "_" + snapshot
    print path
    repo = Repo(path)
    snapshotDate = date

    # Initialize an array of commits
    commits_list = list(repo.iter_commits())
    print(len(commits_list))

    cols = ['model_name', 'author', 'commit_time', 'summary', 'filename', 'lines_added', 'lines_removed']
    gitdf = pd.DataFrame(columns=cols)

    for i in range(len(commits_list) - 1):
        # for i in range(1906,1928): # for testing

        commitnumber = i
        print commitnumber

        this_commit = commits_list[commitnumber]

        count_parents = len(this_commit.parents)
        # print ("parents: ",count_parents)

        if count_parents > 1:
            print("Skip: merge branch")

        else:  # Do stuff
            if count_parents == 0:
                # print 'count_parents=',count_parents
                prev_commit = commits_list[len(commits_list) - 1]

            else:  # count_parents = 1, so continue
                prev_commit = this_commit.parents[0]

            prev_summary = unicode(prev_commit.summary)

            dt = str(this_commit.committed_datetime)
            author = unicode(this_commit.author)
            summary = unicode(this_commit.summary)

            diff_object = prev_commit.diff(this_commit, create_patch=True)

            # print('current', summary, 'prev:,',prev_summary)

            for d in diff_object:
                diff = unicode(d)
                gitfilename = diff.splitlines()[0]
                # print gitfilename

                difflines = len(diff.splitlines())
                linesadded = ''
                linesremoved = ''
                for line in diff.splitlines():
                    if line.startswith('-') and not line.startswith('---'):
                        linesremoved += line
                        linesremoved += '\n'
                    if line.startswith('+'):
                        linesadded += line
                        linesadded += '\n'
                print type(dt)
                gitdf.loc[len(gitdf)] = [model_name, author, dt, summary, gitfilename, linesadded, linesremoved]

    # Write the commits back to the database
    engine = create_engine(url.URL(**postgres_connectors))
    gitdf.to_sql(con=engine, schema='reports', name='tmp_lookml_commits_combined', if_exists='append')  # , flavor='postgresql')