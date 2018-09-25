# Looker_LookML_Quality
Concept of LookML Quality was defined and developed by Jeff McClelland. Currently it is being maintained by Henri Allik 

## What is LookML Quality?

Finding the right dimension or measure is the hardest part of using Looker. This is made 10x worse when there's incorrect data, errors, duplicates, or incomprehensible names.

![Explore](https://github.com/henriallik/Looker_LookML_Quality/blob/master/img/explore.PNG)  


__Ideally__ in Looker there should be:
* __Only necessary__ data
* Everything is __clearly labelled__
* __Unambiguous__ (no dupes)

But code quality is hard to measure
(and measure over time)

Thus we have created a __proxy for quality__ called the __LookML Quality Score__

![Score](https://github.com/henriallik/Looker_LookML_Quality/blob/master/img/score.PNG)


![Views](https://github.com/henriallik/Looker_LookML_Quality/blob/master/img/views.PNG)


![Commits](https://github.com/henriallik/Looker_LookML_Quality/blob/master/img/commits.PNG)




## How to use it?

1. Create `lookup_lookML_points` table => `lookup_lookML_points.sql`
2. Add your database connection details to `config.py` file
3. Run [`master.py`](https://github.com/henriallik/Looker_LookML_Quality/blob/master/master.py) => This will execute following scripts  
  3.1 [`scan_views.py`](https://github.com/henriallik/Looker_LookML_Quality/blob/master/scan_views.py)  
  3.2 [`view_scores.sql`](https://github.com/henriallik/Looker_LookML_Quality/blob/master/view_scores.sql)  
  3.3 [`scan_commits.py`](https://github.com/henriallik/Looker_LookML_Quality/blob/master/scan_commits.py)  
  3.4 [`commit_scores.sql`](https://github.com/henriallik/Looker_LookML_Quality/blob/master/commit_scores.sql)  
4. View data in Looker


## LookML - TBA
