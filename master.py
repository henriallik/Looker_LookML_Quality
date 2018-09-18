import importlib
import psycopg2
# This is to get your DB credentials from config.py file, make sure that your details are correct
from config import postgres_connectors as pc
import sqlite3
from sqlite3 import OperationalError

# How to update LookML dashboards
# 1. Run scan_views.py !
# 2. Now run lookMl_view_scores_combined.sql - every script in that order
# 4. Run scan_commits.py
# 5. Then rebuild reports.lookup_lookml_quality_commits_combined in lookML_commit_scores_combined.sql
# 6. Check dashboards

def executeScriptsFromFile(filename):
    # Open and read the file as a single buffer
    f = open(filename, 'r')
    sqlFile = f.read()
    f.close()

    # all SQL commands (split on ';')
    #sqlCommands = sqlFile.split(';')

    try:
        conn = psycopg2.connect(database=pc['db'], user=pc['user'], password=pc['passwd'], host=pc['host'], port=pc['port'])
    except Exception, e:
        print 'Could not connect to db, error message: %s' % e
    cur = conn.cursor()

    #for command in sqlCommands:
    try:
        #print command
        cur.execute(sqlFile)
    except OperationalError, msg:
        print "Command skipped: ", msg
    #results = cur.fetchall()
    #print results
    conn.commit()
    cur.close()
    conn.close()



errors = []
#1
print("Running LookML Quality Views Combined Python")
#importlib.import_module('scan_views')
print("Finished first script")
#2
print("Executing LookML View Scores Combined SQL")
executeScriptsFromFile('view_scores.sql')
print("Finished second script")
#3
print("Running LookML Quality Commits Combined Python")
importlib.import_module('scan_commits')
print("Finished third script")
#4
print("Executing LookML Commit Scores Combined")
executeScriptsFromFile('commit_scores.sql')
print("Finished final script")



# Write errors to file
with open("error_log.txt", "w") as fp:
    for line in errors:
        fp.write(line + "\n")
