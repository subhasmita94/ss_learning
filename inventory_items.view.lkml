view: inventory_items {
  sql_table_name: PUBLIC.INVENTORY_ITEMS ;;

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}."ID" ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}."COST" ;;
  }

  dimension_group: created {
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
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension: product_brand {
    type: string
    sql: ${TABLE}."PRODUCT_BRAND" ;;
  }

  dimension: product_category {
    type: string
    sql: ${TABLE}."PRODUCT_CATEGORY" ;;
  }

  dimension: product_department {
    type: string
    sql: ${TABLE}."PRODUCT_DEPARTMENT" ;;
  }

  dimension: product_distribution_center_id {
    type: string
    sql: ${TABLE}."PRODUCT_DISTRIBUTION_CENTER_ID" ;;
  }

  dimension: product_id {
    type: string
    # hidden: yes
    sql: ${TABLE}."PRODUCT_ID" ;;
  }

  dimension: product_name {
    type: string
    sql: ${TABLE}."PRODUCT_NAME" ;;
  }

  dimension: product_retail_price {
    type: number
    sql: ${TABLE}."PRODUCT_RETAIL_PRICE" ;;
  }

  dimension: product_sku {
    type: string
    sql: ${TABLE}."PRODUCT_SKU" ;;
  }

  dimension_group: sold {
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
    sql: ${TABLE}."SOLD_AT" ;;
  }

  dimension: is_sold {
    type: yesno
    sql: ${sold_raw} is not null ;;

  }

  dimension: days_since_arrival {
    description: "days since created - useful when filtering on sold yesno for items still in inventory"
    type: number
    sql: DATEDIFF('day',${created_date},CURRENT_DATE) ;;

  }

  dimension: days_since_arrival_grp {
    type: tier
    sql: ${days_since_arrival} ;;
    style: integer
    tiers: [0,10,30,60,100,150,200,250]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: average_cost {
    type: average
    sql: ${cost} ;;
  }

  measure: sold_count {
    type: count
    drill_fields: [detail*]

    filters: {
      field: is_sold
      value: "Yes"
    }
  }

  measure: sold_percent {
    type: number
    value_format_name: percent_2
    sql: 1.0* ${sold_count} / NULLIF(${count},0) ;;
  }

  measure: total_cost {
    type: sum
    value_format: "usd"
    sql: ${cost} ;;
  }

  measure: product_on_hand {
    type: count
    drill_fields: [detail*]

    filters: {
      field: is_sold
      value: "No"
    }
  }



  set: detail {
    fields: [id, products.item_name, products.category, products.brand, products.department, cost, created_time, sold_time]
  }

}
