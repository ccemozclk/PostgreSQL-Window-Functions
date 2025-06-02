/*
Goal1: Find the top 3 best-selling products (by (total quantity) * unit_price_discounted) in each category.
Tools: SUM(), RANK() OVER (PARTITION BY category_id ORDER BY sum((total quantity) * unit_price_discounted)) DESC)
*/
WITH CategoryRanking AS (
    SELECT 
        C.CATEGORY_NAME "CATEGORY_NAME",
        ROUND(CAST(SUM((COALESCE(P.UNIT_PRICE, 0) * (1 - COALESCE(ODS.DISCOUNT, 0))) * COALESCE(ODS.QUANTITY, 0)) AS numeric), 2) AS "TOTAL_AVENUE",
        RANK() OVER (ORDER BY SUM((COALESCE(P.UNIT_PRICE, 0) * (1 - COALESCE(ODS.DISCOUNT, 0))) * COALESCE(ODS.QUANTITY, 0)) DESC) AS "RANK_ORD"
    FROM ORDERS OD
    LEFT JOIN ORDER_DETAILS ODS ON ODS.ORDER_ID = OD.ORDER_ID
    LEFT JOIN PRODUCTS P ON P.PRODUCT_ID = ODS.PRODUCT_ID
    LEFT JOIN CATEGORIES C ON C.CATEGORY_ID = P.CATEGORY_ID
    GROUP BY C.CATEGORY_NAME
)
SELECT * FROM CategoryRanking WHERE "RANK_ORD" <= 5 ORDER BY "TOTAL_AVENUE" DESC;

/*
Goal 2 : Show total revenue per month along with the month-over-month difference and cumulative totals. 
Tools: DATE_TRUNC(), SUM(), LAG(), SUM() OVER (ORDER BY month)
*/
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', OD.ORDER_DATE) AS month,
        ROUND(CAST(SUM(
            (COALESCE(P.UNIT_PRICE, 0) * (1 - COALESCE(ODT.DISCOUNT, 0))) 
            * COALESCE(ODT.QUANTITY, 0)
        ) AS NUMERIC), 2) AS total_revenue
    FROM ORDERS OD
    LEFT JOIN ORDER_DETAILS ODT ON ODT.ORDER_ID = OD.ORDER_ID
    LEFT JOIN PRODUCTS P ON P.PRODUCT_ID = ODT.PRODUCT_ID
    WHERE EXTRACT(YEAR FROM OD.ORDER_DATE) = 1998
    GROUP BY DATE_TRUNC('month', OD.ORDER_DATE)
)

SELECT 
    TO_CHAR(month, 'YYYY-MM') AS month,
    total_revenue AS total_avenue,
	ROUND(total_revenue - LAG(total_revenue) OVER (ORDER BY month), 2) AS mom_difference,
	ROUND(SUM(total_revenue) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS cumulative_revenue
FROM monthly_sales
ORDER BY month;

/*
Goal 3 : Calculate each employee’s total sales, rank them, and show how much above or below average they performed.
Tools: SUM(), RANK(), AVG() OVER (), ROUND(), JOIN with Employees
*/

SELECT 
  		(EM.FIRST_NAME || ' ' || EM.LAST_NAME) AS EMPLOYEE_NAME,

  		ROUND(CAST(SUM( (COALESCE(P.UNIT_PRICE, 0) * (1 - COALESCE(ODT.DISCOUNT, 0))) * COALESCE(ODT.QUANTITY, 0) ) AS NUMERIC), 2) AS TOTAL_REVENUE,

		RANK() OVER ( ORDER BY SUM( (COALESCE(P.UNIT_PRICE, 0) * (1 - COALESCE(ODT.DISCOUNT, 0))) * COALESCE(ODT.QUANTITY, 0)  ) DESC ) AS EMPLOYEE_RANK,
   
  		ROUND(CAST(AVG(SUM( (COALESCE(P.UNIT_PRICE, 0) * (1 - COALESCE(ODT.DISCOUNT, 0))) * COALESCE(ODT.QUANTITY, 0) )) OVER () AS NUMERIC), 2) AS AVG_REVENUE,
    
  		ROUND(CAST( SUM( (COALESCE(P.UNIT_PRICE, 0) * (1 - COALESCE(ODT.DISCOUNT, 0))) * COALESCE(ODT.QUANTITY, 0) )
      						- AVG(SUM( (COALESCE(P.UNIT_PRICE, 0) * (1 - COALESCE(ODT.DISCOUNT, 0))) * COALESCE(ODT.QUANTITY, 0)  )) OVER () AS NUMERIC), 2) AS ABOVE_BELOW_AVG
      
FROM ORDERS OD
LEFT JOIN ORDER_DETAILS ODT ON ODT.ORDER_ID = OD.ORDER_ID
LEFT JOIN PRODUCTS P ON P.PRODUCT_ID = ODT.PRODUCT_ID
LEFT JOIN EMPLOYEES EM ON EM.EMPLOYEE_ID = OD.EMPLOYEE_ID
GROUP BY EM.EMPLOYEE_ID, EM.FIRST_NAME, EM.LAST_NAME
ORDER BY TOTAL_REVENUE DESC;

/*
Goal 4: Show the total revenue from each customer, their first and latest order date, and how many days they've been active.
Tools: MIN(), MAX(), SUM(), AGE(), COUNT(DISTINCT order_id)
*/

SELECT 
		'[' || C.CUSTOMER_ID || ']' || '-' || C.COMPANY_NAME "CUSTOMER_NAME",
		ROUND(CAST(SUM( (COALESCE(P.UNIT_PRICE, 0) * (1 - COALESCE(ODT.DISCOUNT, 0))) * COALESCE(ODT.QUANTITY, 0) ) AS NUMERIC), 2) TOTAL_REVENUE,
		MIN(OD.ORDER_DATE) AS MIN_ORDER_DATE,
    	MAX(OD.ORDER_DATE) AS MAX_ORDER_DATE,
		(MAX(OD.ORDER_DATE) - MIN(OD.ORDER_DATE)) AS ACTIVE_DAYS,
		AGE(MAX(OD.ORDER_DATE), MIN(OD.ORDER_DATE) ) ACTIVE_DAYS_DESC,
		COUNT(DISTINCT OD.ORDER_ID) AS TOTAL_ORDERS
	FROM ORDERS OD
	LEFT JOIN ORDER_DETAILS ODT ON ODT.ORDER_ID = OD.ORDER_ID
	LEFT JOIN PRODUCTS P ON P.PRODUCT_ID = ODT.PRODUCT_ID
	LEFT JOIN CUSTOMERS C ON C.CUSTOMER_ID = OD.CUSTOMER_ID
	GROUP BY C.CUSTOMER_ID, C.COMPANY_NAME

/*
Goal 5: Calculate the average delivery time for orders, and flag ones that took longer than the 75th percentile.
Tools: AGE(), PERCENTILE_CONT(0.75) WITHIN GROUP, CASE WHEN
*/

WITH order_delivery AS (
    SELECT 
        OD.ORDER_ID,
        OD.CUSTOMER_ID,
        OD.ORDER_DATE,
        OD.SHIPPED_DATE,
        (OD.SHIPPED_DATE - OD.ORDER_DATE) DELIVERY_DATE
    FROM ORDERS OD
    WHERE OD.SHIPPED_DATE IS NOT NULL
),
percentile_val AS (
    SELECT 
        PERCENTILE_CONT(0.75) 
        WITHIN GROUP (ORDER BY DELIVERY_DATE) AS p75_delivery_days
		
    FROM order_delivery
),

avg_val AS (
    SELECT 
        AVG(DELIVERY_DATE) AS avg_delivery_days
    FROM order_delivery
)

SELECT 
    O.ORDER_ID,
    O.CUSTOMER_ID,
    O.ORDER_DATE,
    O.SHIPPED_DATE,
    O.DELIVERY_DATE,
    P.p75_delivery_days,
	ROUND( CAST(A.avg_delivery_days AS NUMERIC),2) avg_delivery_days,
    CASE 
        WHEN O.DELIVERY_DATE > P.p75_delivery_days THEN 'DELAYED'
        ELSE 'On Time'
    END AS delivery_flag

FROM order_delivery O
CROSS JOIN percentile_val P
CROSS JOIN avg_val A
ORDER BY O.DELIVERY_DATE DESC;

/*
Goal 6: Identify how many customers placed more than one order, and the percentage of repeat customers per country.
Tools: COUNT(order_id) OVER (PARTITION BY customer_id), CASE, GROUP BY
*/

WITH customer_orders AS (
    SELECT DISTINCT
        C.CUSTOMER_ID,
        C.COUNTRY,
        COUNT(OD.ORDER_ID) OVER (PARTITION BY C.CUSTOMER_ID) AS order_count
    FROM ORDERS OD
    LEFT JOIN CUSTOMERS C ON C.CUSTOMER_ID = OD.CUSTOMER_ID
	
),
tagged_customers AS (
    SELECT *,
        CASE 
            WHEN order_count > 1 THEN 1 ELSE 0
        END AS is_repeat
    FROM customer_orders
),
with_country_stats AS (
    SELECT 
        *,
        COUNT(*) OVER (PARTITION BY COUNTRY) AS total_customers_in_country,
        SUM(is_repeat) OVER (PARTITION BY COUNTRY) AS repeat_customers_in_country
    FROM tagged_customers
)
SELECT DISTINCT
    COUNTRY,
    total_customers_in_country,
    repeat_customers_in_country,
    ROUND(100.0 * repeat_customers_in_country / total_customers_in_country, 2) AS repeat_customer_percentage
FROM with_country_stats
ORDER BY repeat_customer_percentage DESC;



/*
Goal 7 : Calculate how quickly each product is being sold relative to its stock level.
Tools: SUM(quantity), JOIN with products for stock quantity, RATIO
*/

WITH product_sales AS (
    SELECT 
        P.PRODUCT_ID,
        P.PRODUCT_NAME,
        P.UNITS_IN_STOCK,
        SUM(ODT.QUANTITY) AS total_sold
    FROM ORDERS OD
    LEFT JOIN ORDER_DETAILS ODT ON ODT.ORDER_ID = OD.ORDER_ID
	LEFT JOIN PRODUCTS P ON P.PRODUCT_ID = ODT.PRODUCT_ID
	WHERE EXTRACT(YEAR FROM OD.ORDER_DATE) = 1998 AND P.PRODUCT_ID <> 1
    GROUP BY P.PRODUCT_ID, P.PRODUCT_NAME, P.UNITS_IN_STOCK
)

SELECT 
    PRODUCT_ID,
    PRODUCT_NAME,
    UNITS_IN_STOCK,
    total_sold,
    ROUND(CASE 
        WHEN UNITS_IN_STOCK = 0 THEN NULL
        ELSE total_sold::numeric / UNITS_IN_STOCK
    END, 2) AS sell_through_ratio

FROM product_sales
ORDER BY sell_through_ratio DESC NULLS LAST;