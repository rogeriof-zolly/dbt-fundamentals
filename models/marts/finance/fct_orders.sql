WITH orders AS (
    SELECT * FROM {{ ref('stg_jaffle_shop__orders') }}
),

payments AS (
    SELECT * FROM {{ ref('stg_stripe__payment') }}
),

order_payments AS (
    SELECT 
        order_id, 
        SUM(CASE WHEN payments.status = 'success' THEN payments.amount ELSE 0 END) as amount 
    FROM payments
    GROUP BY 1
),

final AS (
    SELECT 
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        coalesce(order_payments.amount, 0) as amount
    FROM orders
    LEFT JOIN order_payments USING (order_id)
)

SELECT * FROM final