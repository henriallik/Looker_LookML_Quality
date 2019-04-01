import importlib
from snowflake.sqlalchemy import URL
from sqlalchemy import create_engine

# How to update LookML dashboards
# 1. Run LookML_quality_views_combined.py
# 2. Now run lookMl_view_scores_combined.sql - every script in that order
# 4. Run LookML_quality_commits_combined.py
# 5. Then rebuild reports.lookup_lookml_quality_commits_combined in lookML_commit_scores_combined.sql
# 6. Check dashboards

#Enter your username for database connection
user = ''

def executeScriptsFromFile(filename):
    # Open and read the file as a single buffer
    f = open(filename, 'r')
    sqlFile = f.read()
    f.close()

    # all SQL commands (split on ';')
    #sqlCommands = sqlFile.split(';')

    print("Connecting to DB - Snowflake")
    try:
        engine = create_engine(URL(
            account='',
            region='',
            user=user,
            database='',
            schema='',
            warehouse='',
            authenticator='externalbrowser',
            role='' 
        ))
    except Exception as e:
        print(e)
        engine = create_engine(URL(
            account='',
            region='',
            user=user,
            database='',
            schema='',
            warehouse='',
            authenticator='externalbrowser',
            role=''  
        ))
    try:
        connection = engine.connect()
        print("Executing SQL")
        results = connection.execute(sqlFile).fetchall()
        print("Got data")
        print(results)
        return results

    except Exception, e:
        print("Can't query: {0}").format(e)

    finally:
        connection.close()
        engine.dispose()



errors = []
#1
print("Running LookML Quality Views Combined Python")
importlib.import_module('LookML_quality_views_combined')
print("Finished first script")
#2
print("Executing LookML View Scores Combined SQL")
executeScriptsFromFile('lookML_view_scores_combined.sql')
print("Finished second script")
#3
print("Running LookML Quality Commits Combined Python")
importlib.import_module('LookML_quality_commits_combined')
print("Finished third script")
#4
print("Executing LookML Commit Scores Combined")
executeScriptsFromFile('lookML_commit_scores_combined.sql')
print("Finished final script")



# Write errors to file
with open("error_log.txt", "w") as fp:
    for line in errors:
        fp.write(line + "\n")
