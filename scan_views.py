# encoding=utf8

import os
import sys
import re
reload(sys)
sys.setdefaultencoding("utf-8")
import pandas as pd
from config import postgres_connectors
from sqlalchemy.engine import url
from sqlalchemy import create_engine
from git import Repo

from datetime import datetime

date = str(datetime.today().strftime('%Y-%m-%d'))
snapshot = "snapshot_" + date

# How to update LookML dashboards
# 1. Run scan_views.py
# 2. Now run lookMl_view_scores_combined.sql - every script in that order
# 3. Then drop TABLE if EXISTS reports.tmp_lookml_commits_combined;
# 4. Run scan_commits.py
# 5. Then rebuild reports.lookup_lookml_quality_commits_combined in lookML_commit_scores_combined.sql
# 6. Check dashboards

print snapshot

# Here you can define your repo locations
lookml_postgre = 'https://github.com/transferwise/lookml_postgre.git'
lookml_greenhouse = 'https://github.com/transferwise/lookml_greenhouse.git'
lookml_findb = 'https://github.com/transferwise/lookml_findb.git'
lookml_servicedb = 'https://github.com/transferwise/lookml_serviceDB.git'
lookml_analytics_base = 'https://github.com/transferwise/lookML_analytics_base.git'


repos = [lookml_postgre, lookml_greenhouse, lookml_findb, lookml_servicedb, lookml_analytics_base]


for repo in repos:
    name = (repo.split("/"))[-1].split(".")[0]
    path_base = "G:/My Drive/Analytics/LookML//" + name + "_" + snapshot

    Repo.clone_from(repo, path_base)

    snapshotDate = date
    model_name = name

    os.chdir(path_base)
    path_base
    from pathlib import Path

    lookml_files = [pth for pth in Path.cwd().iterdir()
                    if pth.suffix == '.lkml']


    def find_between(s, first, last):
        try:
            start = s.index(first) + len(first)
            end = s.index(last, start)
            return s[start:end]
        except ValueError:
            return ""


    # Initialize the empty data frame
    cols = ['model_name', 'snapshot_date', 'filename', 'field_type', 'field_name', 'label', 'description', 'type', 'flag_hidden',
            'flag_primary_key', 'value_format', 'suggestions', 'alias', 'timeframes', 'tiers', 'drill_fields',
            'view_label',
            'full_statement']  # 'sql', 'html', 'filters']
    df = pd.DataFrame(columns=cols)

    for fileNumber in range(len(lookml_files)):
        # for fileNumber in range(2,3):
        filePath = lookml_files[fileNumber]
        filePathStr = unicode(filePath)
        filePath, fileName = os.path.split(filePathStr)
        print (fileName)

        with open(filePathStr, 'r') as fileData:
            fileContents = fileData.read()
            fieldsList = re.split(r'\s(?=(?: dimension| measure| dimension_group)\b)', fileContents)
            print(len(fieldsList))

            fieldNumber = 1
            for fieldNumber in range(len(fieldsList)):
                fieldType = ""
                fieldName = ""
                description = ""
                hidden = ""
                primaryKey = ""
                datatype = ""
                timeframes = ""
                tiers = ""
                valueFormat = ""
                suggestions = ""
                alias = ""
                drillFields = ""
                viewLabel = ""
                label = ""
                sql = ""
                html = ""
                filters = ""

                fieldContents = fieldsList[fieldNumber]
                fieldLines = fieldContents.splitlines()

                lineNumber = 0
                for lineNumber in range(len(fieldLines)):
                    fieldLine = fieldLines[lineNumber]
                    if not fieldType:
                        if "dimension: " in fieldLine:
                            fieldType = "Dimension"
                            fieldName = fieldLine.partition("dimension: ")[2]
                        elif "dimension_group: " in fieldLine:
                            fieldType = "Dimension Group"
                            fieldName = fieldLine.partition("dimension_group: ")[2]
                        elif "measure: " in fieldLine:
                            fieldType = "Measure"
                            fieldName = fieldLine.partition("measure: ")[2]
                        else:
                            fieldType = ""
                            fieldName = ""

                    # DESCRIPTION
                    if not description:
                        if "description: " in fieldLine:
                            description = fieldLine.partition("description: ")[2]
                            description = description.replace('"', '').replace("'", "")
                        else:
                            description = ""

                    # HIDDEN FLAG
                    if not hidden:
                        if "hidden: " in fieldLine:
                            hidden = fieldLine.strip()
                        else:
                            hidden = ""

                    # PRIMARY KEY
                    if not primaryKey:
                        if "primary_key: " in fieldLine:
                            primaryKey = fieldLine.strip()
                        else:
                            primaryKey = ""

                    # TYPE
                    if not datatype:
                        if "type: " in fieldLine:
                            datatype = fieldLine.partition("type: ")[2]
                        else:
                            datatype = ""

                    # TIERS
                    if not tiers:
                        if "tiers: " in fieldLine:
                            tiers = fieldLine.partition("tiers: ")[2]
                        else:
                            tiers = ""

                    # TIMEFRAMES (FOR DIMENSION GROUPS)
                    if not timeframes:
                        if "timeframes: " in fieldLine:
                            timeframes = fieldLine.partition("timeframes: ")[2]
                        else:
                            timeframes = ""

                    # VALUE FORMAT
                    if not valueFormat:
                        if "value_format: " in fieldLine:
                            valueFormat = fieldLine.partition("value_format: ")[2]
                            valueFormat = valueFormat.replace('"', '').replace("'", "")
                        else:
                            valueFormat = ""

                            # SUGGESTIONS
                    if not suggestions:
                        if "suggestions: " in fieldLine:
                            suggestions = fieldLine.partition("suggestions: ")[2]
                        else:
                            suggestions = ""

                    # ALIAS
                    if not alias:
                        if "alias: " in fieldLine:
                            alias = fieldLine.partition("alias: ")[2]
                        else:
                            alias = ""

                    # DRILL FIELDS
                    if not drillFields:
                        if "drill_fields:" in fieldLine:
                            drillFields = fieldLine.partition("drill_fields: ")[2]
                        else:
                            drillFields = ""

                    # VIEW LABEL
                    if not viewLabel:
                        if "view_label: " in fieldLine:
                            viewLabel = fieldLine.partition("view_label: ")[2]
                            viewLabel = viewLabel.replace('"', '').replace("'", "")
                        else:
                            viewLabel = ""

                            # LABEL
                    if not label:
                        if " label: " in fieldLine:
                            label = fieldLine.partition(" label: ")[2]
                            label = label.replace('"', '').replace("'", "")
                        else:
                            label = ""

                    """
                    # SQL 
                    # a bit complicated for multi-line SQLs but works 
                    if not sql:
                        if "sql: " in fieldLine:
                            sql = fieldLine.partition("sql: ")[2]
                        else:
                            sql = ""  

                    # HTML 
                    # a bit complicated for multi-line HTML but works 
                    if not html:
                        if "html: " in fieldLine:
                            html = fieldLine.partition("html: ")[2]
                        else:
                            html = ""  

                    # FILTERS
                    # a bit complicated for multi-line FILTERS but works 
                    if not filters:
                        if "filters: " in fieldLine:
                            filters = fieldLine.partition("filters: ")[2]
                        else:
                            filters = ""  

                if "|" in sql:
                    sql = find_between( fieldContents, "|", "\n\n" ) #searches for the next variable
                    sql = sql.replace("'", "''").lstrip()

                if "|" in html:
                    html = find_between( fieldContents, "|", "\n\n" ) #searches for the next variable
                    html = html.replace("'", "''").lstrip()

                if "|" in filters:
                    html = find_between( fieldContents, "|", "  - " ) #searches for the next variable
                    html = filters.replace("'", "''").lstrip()
                    """
                df.loc[len(df)] = [model_name, snapshotDate, fileName, fieldType, fieldName, label, description, datatype, hidden,
                                   primaryKey, valueFormat, suggestions, alias, timeframes, tiers, drillFields,
                                   viewLabel,
                                   fieldContents]  # sql, html, filters]

    # Write the commits back to the database
    engine = create_engine(url.URL(**postgres_connectors))

    df.to_sql(con=engine, schema='reports', name='lookup_looker_file_contents_combined',

              if_exists='append')  # , flavor='postgresql')
