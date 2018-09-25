# Looker_LookML_Quality
Concept of LookML Quality was defined and developed by Jeff McClelland. Currently it is being maintained by Henri Allik 

## What is LookML Quality?

Finding the right dimension or measure is the hardest part of using Looker. This is made 10x worse when there's incorrect data, errors, duplicates, or incomprehensible names.

![Score](https://github.com/henriallik/Looker_LookML_Quality/blob/master/score.PNG)

## How to use it?

1. Create `lookup_lookML_points` table => `lookup_lookML_points.sql`
2. Add your database connection details to `config.py` file
3. Run `master.py` => This will execute following scripts  
  3.1 `scan_views.py`  
  3.2 `view_scores.sql`  
  3.3 `scan_commits.py`  
  3.4 `commit_scores.sql`  
4. View data in Looker


