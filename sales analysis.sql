-- Retrieve the total number of orders placed?
select count(order_id) 
from orders;

-- Calculate the total revenue generated from pizza sales
select 
sum(od.quantity*pz.price) as Total_revenue
from order_details as od 
join pizzas as pz
on pz.pizza_id = od.pizza_id;

-- Identify the highest-priced pizza.
select pt.name as Name, pz.price as Highest_Price
from pizza_types as pt 
join Pizzas as pz
on pz.pizza_type_id = pt.pizza_type_id
order by price desc limit 1;

-- Identify the most common pizza size ordered.


-- List the top 5 most ordered pizza types along with their quantities.
select sum(od.quantity) as total, pt.name
from pizza_types as pt  
join pizzas as pz
on pt.pizza_type_id = pz.pizza_type_id
join order_details as od 
on od.pizza_id = pz.pizza_id
group by pt.name
order by total desc limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pt.category, sum(od.quantity) as sum 
from pizza_types as pt  join pizzas as pz
on pt.pizza_type_id = pz.pizza_type_id
join order_details as od
on od.pizza_id = pz.pizza_id
group by pt.category
order by sum desc;

-- Determine the distribution of orders by hour of the day.
select hour(order_time), count(order_id) from orders
group by hour(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity), 2) from
(select o.order_date, sum(od.quantity) as quantity
from orders as o join order_details as od 
on o.order_id = od.order_id
group by o.order_date) as order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
select pt.name, sum(od.quantity*pz.price) as pizza_price
from order_details as od join pizzas as pz
on od.pizza_id = pz.pizza_id
join pizza_types as pt 
on pt.pizza_type_id = pz.pizza_type_id
group by pt.name 
order by pizza_price desc limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
select pt.category, (round(sum(od.quantity*pz.price),2) / (select 
sum(od.quantity*pz.price) as pizza_sales
from order_details as od join pizzas as pz
on pz.pizza_id = od.pizza_id))*100 as revenue
from pizza_types as pt join pizzas as pz
on pt.pizza_type_id = pz.pizza_type_id
join order_details as od 
on od.pizza_id = pz.pizza_id
group by pt.category;

-- Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over(order by order_date) as cum_revenue
from
(select o.order_date, round(sum(od.quantity*pz.price), 2) as revenue 
from order_details as od join pizzas as pz 
on od.pizza_id = pz.pizza_id
join orders as o
on o.order_id = od.order_id
group by o.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, revenue,
rank() over(partition by category order by revenue desc ) as rn
from 
(select pt.category, pt.name, sum(od.quantity*pz.price) as revenue 
from order_details as od join pizzas as pz
on od.pizza_id = pz.pizza_id
join pizza_types as pt 
on pt.pizza_type_id = pz.pizza_type_id
group by pt.name, pt.category) as a limit 3;
