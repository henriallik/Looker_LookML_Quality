view: lookml_quality_views {
  sql_table_name: reports.report_lookml_view_data_and_quality_combined ;;


  dimension: define_primary_key {
    sql: concat(${TABLE}.snapshot_date,'_',${TABLE}.filename,'_',${TABLE}.field_name) ;;
    primary_key: yes
    hidden: yes
    type: string
  }

  dimension: model_name {
    label: "Model name"
    description: "This the name of the LookML mode"
    suggestions: ["Analytics Base","FinDB","Greenhouse","Payments","ServiceDB"]
    sql: ${TABLE}.model_name ;;
    case_sensitive: yes
    type: string
  }

  dimension: flag_latest_snapshot {
    description: "When YES, this is the latest snapshot of the data available. Set to *any value* if you want to look at trends in quality over time"
    type: yesno
    sql: ${TABLE}.flag_latest_snapshot ;;
  }

  dimension_group: snapshot {
    description: "This is when the LookML repository looked like it did"
    type: time
    timeframes: [date,month,quarter]
    sql: ${TABLE}.snapshot_date ;;
  }

  dimension: field_name {
    type: string
    sql: ${TABLE}.field_name ;;
  }

  dimension: field_type {
    type: string
    sql: ${TABLE}.field_type ;;
  }

  dimension: filename {
    description: "The LookML filename"
    type: string
    sql: ${TABLE}.filename ;;
  }

  dimension: filename_url {
    description: "A hyperlink to the LookML file modified"
    type: string
    sql: ${filename} ;;
    html: <a href="https://looker.transferwise.com/projects/payments/files/{{ value }}"target="_blank">
      {{value}}
      <img src="/images/qr-graph-line@2x.png" height=20 width=20>
      </a>
      ;;
  }

  dimension: git_blame_url {
    label: "Git Blame hyperlink"
    description: "A hyperlink to the Git blame page to see who modified what"
    type: string
    sql: ${filename} ;;
    html: <a href="https://github.com/transferwise/lookml_postgre/blame/master/{{ value }}"target="_blank">
      Git URL
      <img src="/images/qr-graph-line@2x.png" height=20 width=20>
      </a> ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: has_description {
    description: "YES/NO to indicate whether the column has a description or not"
    type: yesno
    sql: case when ${description} is not null then true else false end ;;
  }

  dimension: drill_fields {
    type: string
    sql: ${TABLE}.drill_fields ;;
  }

  dimension: alias {
    type: string
    sql: ${TABLE}.alias ;;
  }

  dimension: flag_hidden {
    type: string
    sql: ${TABLE}.flag_hidden ;;
  }

  dimension: flag_primary_key {
    type: string
    sql: ${TABLE}.flag_primary_key ;;
  }

  dimension: full_statement {
    description: "This is the full statement associated to the dimension/measure. You can use it for filtering anything that is missing as a column or for double-checking it"
    type: string
    sql: ${TABLE}.full_statement ;;
  }

  dimension: label {
    type: string
    sql: ${TABLE}.label ;;
  }

  dimension: suggestions {
    type: string
    sql: ${TABLE}.suggestions ;;
  }

  dimension: tiers {
    type: string
    sql: ${TABLE}.tiers ;;
  }

  dimension: timeframes {
    type: string
    sql: ${TABLE}.timeframes ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
  }

  dimension: value_format {
    type: string
    sql: ${TABLE}.value_format ;;
  }

  dimension: view_label {
    type: string
    sql: ${TABLE}.view_label ;;
  }

  measure: view_owner {
    label: "View Owners"
    type: string
    description: "People who have commited changes to that view file and first point of contact when troubleshooting"
    sql: string_agg(distinct(lookup_lookml_quality_commits.author),', ') ;;
    required_fields: [lookup_lookml_quality_commits.author]
  }

  dimension: quality_points {
    description: "The raw number of quality points associated to the dimension or measure. Useful for filtering = 0"
    type: number
    sql: ${TABLE}.quality_points ;;
  }

  measure: sum_quality_points {
    description: "The number of quality points associated with the selected dimensions and measures"
    type: sum
    value_format: "#,##0.0"
    drill_fields: [details*]
    sql: ${quality_points} ;;
  }

  measure: count_dimensions_and_measures {
    type: count
    drill_fields: [details*]
  }

  measure: average_quality_points {
    description: "The average quality points *per dimension/measure* associated with the selected dimensions and measures"
    type: number
    value_format: "#,##0.000"
    drill_fields: [details*]
    sql: ${sum_quality_points} / ${count_dimensions_and_measures} ;;
  }

  set: details {
    fields: [
      snapshot_date,
      filename_url,
      field_type,
      field_name,
      label,
      description,
      type,
      flag_hidden,
      flag_primary_key,
      value_format,
      suggestions,
      alias,
      timeframes,
      tiers,
      drill_fields,
      view_label
    ]
  }
}
