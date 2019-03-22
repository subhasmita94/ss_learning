view: order_items {
  sql_table_name: PUBLIC.ORDER_ITEMS ;;

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}."ID" ;;
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

  dimension: reporting_period{
    group_label: "Order date"
    sql: CASE
         WHEN date_part('year',${created_raw}) = date_part('year' , current_date)
         AND ${created_raw} < current_date THEN 'This Year To Date'

        WHEN date_part('year',${created_raw}) +1 = date_part('year',current_date)
        AND date_part('dayofyear',${created_raw}) <= date_part('dayofyear',current_date)
        THEN 'Last Year to Date'

        END


        ;;
  }

  dimension: days_since_sold {
    hidden: yes
    sql:  datediff('day',${created_raw},current_date) ;;

  }

  dimension: months_since_signup {
    view_label: "Orders"
    type: number
    sql: datediff('month',${users.created_raw},${created_raw} ;;
  }




  dimension_group: delivered {
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
    sql: ${TABLE}."DELIVERED_AT" ;;
  }

  dimension: inventory_item_id {
    type: string
    # hidden: yes
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension_group: returned {
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
    sql: ${TABLE}."RETURNED_AT" ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}."SALE_PRICE" ;;
  }

  dimension_group: shipped {
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
    sql: ${TABLE}."SHIPPED_AT" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }


  dimension: days_to_process {
    type: number
    sql: CASE
        WHEN ${status} = 'Processing' THEN DATEDIFF('day',${created_raw},CURRENT_DATE())*1.0
        WHEN ${status} IN ('Shipped', 'Complete', 'Returned') THEN DATEDIFF('day',${created_raw},${shipped_raw})*1.0
        WHEN ${status} = 'Cancelled' THEN NULL
      END
       ;;
  }

  dimension: shipping_time {
    type: number
    sql: datediff('day',${shipped_raw},${delivered_raw})*1.0 ;;
  }

  measure: average_days_to_process {
    type: average
    value_format_name: decimal_2
    sql: ${days_to_process} ;;
  }

  measure: average_shipping_time {
    type: average
    value_format_name: decimal_2
    sql: ${shipping_time} ;;
  }

  dimension: user_id {
    type: string
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: gross_margin {
    type: number
    sql: ${sale_price} - ${inventory_items.cost} ;;
  }
  dimension: age_group {
    type:  tier
    sql: ${users.age} ;;
    tiers: [19,30,45,60]
    style: integer
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: order_count {
    view_label: "Orders"
    type: count_distinct
    sql: ${order_id} ;;
    drill_fields: [detail*]
  }

  measure: total_revenue {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
    drill_fields: [detail*]

  }

  measure: total_profit {
    type:  sum
    sql: ${gross_margin} ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: curr_month_revenue  {
    type: sum
    sql:  ${sale_price} ;;
    value_format_name: usd
    drill_fields: [detail*]
    filters: {field:created_month value:"this month"}
  }

  parameter: item_to_add_up {
    type: unquoted
    allowed_value: {
      label: "Total Sale Price"
      value: "total_revenue"
    }
    allowed_value: {
      label: "Total Cost"
      value: "total_profit"
    }
  }

  measure: dynamic_sum {
    type: sum
    sql: ${TABLE}.{% parameter item_to_add_up %} ;;
    value_format_name: "usd"
  }

  measure: count_last_28d {
    label: "Count sold in trailing 28 days"
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: created_date
      value: "28 days"
    }

  }

  measure: month_count {
    type: count_distinct
    drill_fields: [detail*]
    sql: ${created_month} ;;
  }

  measure: first_order {
    type: date_raw
    sql: MIN(${created_date} ;;
  }

  measure: last_order {
    type: date_raw
    sql: MAX(${created_date} ;;
  }




  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      users.id,
      users.first_name,
      users.last_name,
      inventory_items.id,
      inventory_items.product_name
    ]
  }
}
