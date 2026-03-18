-- BASIC
-- 1. Retrieve the total number of orders placed.
SELECT 
    COUNT(*) AS total_orders
FROM
    orders;
-- 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS revenue
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id;
    
-- 3. Identify the highest-priced pizza.
select pt.name,p.price
from pizza_types pt
join pizzas p
on pt.pizza_type_id = p.pizza_type_id
order by 2 desc
limit 1;

-- 4. Identify the most common pizza size ordered.

select p.size,count(o.order_id) as total_orders
from pizzas p
join order_details o
on p.pizza_id = o.pizza_id
group by 1
order by 2 desc
limit 1;

-- 5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    p.name, SUM(o.quantity) AS total_qty
FROM
    pizza_types p
        JOIN
    pizzas pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details o ON pt.pizza_id = o.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- INTERMEDIATE
-- 6. Total quantity of each pizza category ordered.
select p.category, sum(o.quantity) as totalqty
from order_details o
join pizzas pt
on o.pizza_id = pt.pizza_id
join pizza_types p
on pt.pizza_type_id = p.pizza_type_id
group by 1
order by 2 desc;
-- 7. Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_date) AS hours, COUNT(order_id) AS totalorders
FROM
    orders
GROUP BY 1
ORDER BY 2 DESC;

-- 8. Find the category-wise distribution of pizzas.
select category, count(category) as distribution
from pizza_types
group by 1
order by 2 desc;
-- 9. Group the orders by date and calculate 
-- the average number of pizzas ordered per day.

select orders.order_date,round(avg(sum(order_details.quantity)),0) as avgorder
from orders 
join order_details
on orders.order_id = order_details.order_id;

-- 10. Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, ROUND(SUM(o.quantity * p.price), 0) AS revenue
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY 1
ORDER BY 2 DESC
limit 3;


-- ADVANCED
-- 11. Calculate the percentage contribution of each pizza type to total revenue.
SELECT pt.name,
       ROUND(SUM(od.quantity * p.price), 2) AS revenue,
       ROUND(SUM(od.quantity * p.price) /
            (SELECT SUM(od2.quantity * p2.price)
             FROM order_details od2
             JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id) * 100, 2) AS percentage_contribution
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC;



-- 12. Analyze the cumulative revenue generated over time.
with YTD as (select Year(od.Order_time) as Year,
round(sum(o.quantity * pt.price),2) as Revenue
from order_details o
join pizzas pt
on o.pizza_id = pt.pizza_id
join pizza_types p
on pt.pizza_type_id = p.pizza_type_id
join orders od
on o.order_id = od.order_id
group by Year
order by Year asc) 
select *,
round(sum(revenue) over(order by Year asc),2) as Cumsum
from YTD;
-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
with agg as (select p.category as Category, p.name as PIzza_Type,
sum(o.quantity * pt.price) as Revenue
from order_details o
join pizzas pt
on o.pizza_id = pt.pizza_id
join pizza_types p
on pt.pizza_type_id = p.pizza_type_id
join orders od 
on o.order_id = od.order_id
group by Category,pizza_Type 
order by Revenue desc),
filtering as (
select *, 
row_number() over(partition by Category order by Revenue Desc) as ranks
from agg) 
select Category,
Pizza_Type,Revenue
from filtering 
where ranks  <= 3
order by category asc,Revenue desc;