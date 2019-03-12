view: etl_jobs {
  sql_table_name: PUBLIC.ETL_JOBS ;;

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}."ID" ;;
  }

  dimension_group: completed {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."COMPLETED_AT" ;;
  }

  measure: count {
    type: count
    drill_fields: [id]
  }
}
