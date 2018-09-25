view: lookml_quality_commits {
  sql_table_name: reports.lookup_lookml_quality_commits_combined ;;

  dimension: author {
    description: "The person who committed the LookML changes"
    type: string
    sql: ${TABLE}.author ;;
  }

  measure: count_distinct_authors {
    description: "Count of distinct developers"
    type: count_distinct
    sql: ${TABLE}.author ;;
  }

  dimension: model_name {
    label: "Model name"
    description: "This the name of the LookML mode"
    suggestions: ["Analytics Base", "FinDB", "Greenhouse", "Payments", "ServiceDB" ]
    type: string
    sql: ${TABLE}.model_name  ;;
  }

  dimension_group: commit {
    description: "When the change was committed"
    type: time
    timeframes: [time, date, week, month, year]
    sql: ${TABLE}.commit_time ;;
  }

  dimension: keyword_type {
    description: "numerator = quality point or denominator = dimension/dimension_group/measure)"
    type: string
    sql: ${TABLE}.keyword_type ;;
  }

  dimension: keyword {
    description: "The lookML keyword (i.e. value_format, alias, description)"
    type: string
    sql: ${TABLE}.keyword ;;
  }

  dimension: quality_points_per {
    description: "how many quality points accrue each time this is used"
    type: number
    value_format: "0.00"
    sql: ${TABLE}.quality_points ;;
  }

  dimension: commit_summary {
    description: "The description associated to the lookML commit"
    type: string
    sql: ${TABLE}.summary ;;
  }

  dimension: filename {
    description: "The filename (LookML view name) associated to the commit. Each file modified has its own row"
    type: string
    sql: ${TABLE}.filename ;;
  }

  dimension: filename_url {
    alias: [filename_link]
    description: "A link to the LookML file modified"
    type: string
    sql: ${filename} ;;
    html: <a href="https://looker.transferwise.com/projects/payments/files/{{ value }}">
      {{ value }}
      <img src="/images/qr-graph-line@2x.png" height=20 width=20>
      </a>
      ;;
  }

  dimension: lines_added {
    description: "The diff lines that were added in the commit. Always starts with a plus(+)"
    type: string
    sql: ${TABLE}.lines_added ;;
  }

  dimension: lines_removed {
    description: "The diff lines that were removed in the commit. Always starts with a minus (-)"
    type: string
    sql: ${TABLE}.lines_removed ;;
  }

  dimension: count_points_added {
    description: "The number of times the particular keyword (i.e. value_format) was added in that file, in that commit *multiplied by the number of points associated to that keyword*"
    type: number
    sql: ${TABLE}.count_points_added ;;
  }

  dimension: count_points_removed {
    description: "The number of times the particular keyword (i.e. value_format) was removed in that file, in that commit *multiplied by the number of points associated to that keyword*"
    type: number
    sql: ${TABLE}.count_points_removed ;;
  }

  # HIDDEN DIMENSIONS
  dimension: dimensions_and_measures_added {
    type: number
    hidden: yes
    sql: case when ${keyword_type} = 'denominator'
        then ${count_points_added}
        else 0 end
       ;;
  }

  dimension: dimensions_and_measures_removed {
    type: number
    hidden: yes
    sql: case when ${keyword_type} = 'denominator'
        then ${count_points_removed}
        else 0 end
       ;;
  }

  dimension: quality_points_added {
    type: number
    hidden: yes
    sql: case when ${keyword_type} = 'numerator'
        then ${count_points_added}
        else 0 end
       ;;
  }

  dimension: quality_points_removed {
    type: number
    hidden: yes
    sql: case when ${keyword_type} = 'numerator'
        then ${count_points_removed}
        else 0 end
       ;;
  }

  dimension: quality_points_net {
    type: number
    hidden: yes
    sql: ${quality_points_added} - ${quality_points_removed} ;;
  }

  dimension: dimensions_and_measures_net {
    type: number
    hidden: yes
    sql: ${dimensions_and_measures_added} - ${dimensions_and_measures_removed} ;;
  }

  # MEASURES

  measure: commit_count {
    description: "Count of commits made"
    drill_fields: [details*]
    type: count_distinct
    sql: concat(${commit_summary},${commit_date}) ;;
  }

  measure: count_keyword_added {
    description: "The number of times the particular keyword (i.e. value_format) was added in that file, in that commit"
    type: sum
    hidden: yes
    drill_fields: [details*]
    sql: ${TABLE}.count_keyword_added ;;
  }

  measure: count_keyword_removed {
    description: "The number of times the particular keyword (i.e. value_format) was removed in that file, in that commit"
    type: sum
    hidden: yes
    drill_fields: [details*]
    sql: ${TABLE}.count_keyword_removed ;;
  }

  measure: sum_dimensions_and_measures_added {
    label: "Dimensions and Measures Added"
    type: sum
    description: "The amount of dimensions & measures added (making new data available in Looker)"
    drill_fields: [details*]
    sql: ${dimensions_and_measures_added} ;;
  }

  measure: sum_dimensions_and_measures_removed {
    label: "Dimensions and Measures Removed"
    type: sum
    description: "The amount of dimensions & measures removed (removing data from Looker)"
    drill_fields: [details*]
    sql: ${dimensions_and_measures_removed} ;;
  }

  measure: sum_quality_points_added {
    label: "Quality Points Added"
    type: sum
    description: "The amount of points added to the numerator (making higher quality LookML)"
    drill_fields: [details*]
    sql: ${quality_points_added} ;;
  }

  measure: sum_quality_points_removed {
    label: "Quality Points Removed"
    type: sum
    description: "The amount of points removed to the numerator (making quality lower)"
    drill_fields: [details*]
    sql: ${quality_points_removed} ;;
  }

  measure: net_quality_points_added {
    label: "Quality Points Added (net)"
    description: "The net amount of points added to the numerator (making higher quality LookML)"
    type: sum
    value_format: "+#,##0;#,##0;0;"
    drill_fields: [details*]
    sql: ${quality_points_net} ;;
  }

  measure: net_dimensions_and_measures_added {
    label: "Dimensions and Measures Added (net)"
    description: "The net amount of dimensions & measures added (making new data available in Looker)"
    type: sum
    value_format: "+#,##0;#,##0;0;"
    drill_fields: [details*]
    sql: ${dimensions_and_measures_net} ;;
  }

  measure: lookml_quality_score {
    label: "LookML Commit Quality Score"
    description: "The ratio of *Quality Points* to the number of dimensions & measures added. Higher is better"
    type: number
    value_format: "+#,##0;#,##0;0;"
    drill_fields: [details*]
    sql: ${net_quality_points_added} - ${net_dimensions_and_measures_added} ;;
  }

  set: details {
    fields: [
      author,
      commit_date,
      commit_summary,
      lines_added,
      lines_removed,
      lookml_quality_score,
      sum_dimensions_and_measures_added,
      sum_dimensions_and_measures_removed,
      net_dimensions_and_measures_added,
      sum_quality_points_added,
      sum_quality_points_removed,
      net_quality_points_added
    ]
  }
}