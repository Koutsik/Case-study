-- get cities with more than 500 orders
WITH cities_with_more_than_500_orders
AS (
SELECT  city
  ,count(DISTINCT order_id) AS number_of_orders
FROM `bi-2019-test.ad_hoc.orders_jan2021`
GROUP BY city
HAVING count(DISTINCT order_id) > 500
)
,
-- get breakfast orders per city
breakfast_orders_table
AS (
SELECT  city
  ,count(DISTINCT order_id) AS breakfast_orders
FROM `bi-2019-test.ad_hoc.orders_jan2021`
WHERE cuisine_parent = 'Breakfast' --- Filter only for Breakfast cuisine
GROUP BY city
)
,
-- get number of breakfast users per city
number_of_breakfast_users_table
AS (
SELECT city
 ,count(DISTINCT user_id) AS breakfast_users
FROM `bi-2019-test.ad_hoc.orders_jan2021`
WHERE cuisine_parent = 'Breakfast'
GROUP BY city
)
,
-- get breakfast users per city
list_of_breakfast_users_table
AS (
SELECT DISTINCT city
          ,user_id
FROM `bi-2019-test.ad_hoc.orders_jan2021`
WHERE cuisine_parent = 'Breakfast'
)
,
-- estimate average basket size per user as
average_basket_size
AS (
SELECT l.user_id
 ,l.city
 ,sum(basket) AS total_basket
 ,count(order_id) AS all_orders
FROM `bi-2019-test.ad_hoc.orders_jan2021` b
INNER JOIN list_of_breakfast_users_table l ON b.user_id = l.user_id
GROUP BY l.user_id
,l.city
)

,final_basket
AS (
SELECT city
,(sum(total_basket) / sum(all_orders)) AS avg_basket
FROM average_basket_size
GROUP BY city
)

SELECT DISTINCT c.city
,br.breakfast_orders
,n.breakfast_users
,f.avg_basket
FROM cities_with_more_than_500_orders c
LEFT JOIN final_basket f ON f.city = c.city
LEFT JOIN breakfast_orders_table br ON c.city = br.city
LEFT JOIN number_of_breakfast_users_table n ON c.city = n.city
ORDER BY breakfast_orders DESC limit 10