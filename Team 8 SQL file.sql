-- TEAM 8 - SING (our first initials put together!)

--VIEWS:

-- Address: We created a view that showed all address information.
-- This was used for the master table and our graph which showed 
--countries by revenue
CREATE VIEW v_address AS
SELECT
    address_id,
    city,
    state,
    country,
    postal_code,
    address_line_1,
    address_line_2
FROM
    offuture.address;

-- Customer: This highlights our customer data
CREATE VIEW v_customer AS
SELECT
    customer_id_long,
    customer_id_short,
    customer_name,
    segment
FROM
    offuture.customer;

--Customer id_union table: this view matched the short_id's to the long id's 
CREATE OR REPLACE VIEW all_2509.id_union AS
SELECT
    customer_id_long AS customer_id,
    customer_name
FROM offuture.customer

UNION

SELECT
    customer_id_short AS customer_id,
    customer_name
FROM offuture.customer

ORDER BY customer_name;


-- Product: This highlights our product information
CREATE VIEW v_product AS
SELECT
    product_id,
    product_name,
    category,
    sub_category
FROM
    offuture.product;

-- Order: This highlights information relating to all orders
CREATE VIEW v_order AS
SELECT
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    address_id,
    market,
    region,
    order_priority
FROM
    offuture.orders;


-- Order_item: This highlights order data in regards to costs and profits
CREATE VIEW v_order_item AS
SELECT
    order_id,
    product_id,
    sales,
    quantity,
    discount,
    profit,
    shipping_cost
FROM
    offuture.order_item;

-- Shipping summary: This shows total shipping costs per order_id
CREATE OR REPLACE VIEW all_2509.team8_order_shipping_summary AS
SELECT
    offuture.order_item.order_id,
    SUM(offuture.order_item.shipping_costs) AS total_shipping_costs
FROM offuture.order_item
GROUP BY offuture.order_item.order_id;

-- Orginal Prices: This view shows the prices of orders before a 
--discount has been applied
CREATE OR REPLACE VIEW all_2509.team8_originalprices AS
SELECT
    order_id,
    product_id,
    (sales - profit) AS original_cost,
    (sales / (1 - discount)) AS before_discount_price
FROM all_2509.team8_fulltable;

-- Original Profit: This view shows the profit 
--that would have been gained if discounts had not been given to customers
CREATE OR REPLACE VIEW all_2509.team8_org_profit AS
SELECT
    order_id,
    product_id,
    (profit + discount_value) AS original_profit
FROM all_2509.team8_fulltable;

-- Discount impact: This view shows the original price of the product
-- As well as the discount applied and discount value for each item in the table
CREATE VIEW all_2509.team8_discount_impact AS
SELECT
    offuture.order_item.order_id,
    offuture.order_item.product_id,
    offuture.order_item.sales,
    offuture.order_item.discount,
    (offuture.order_item.sales / (1 - offuture.order_item.discount))
        AS original_amount,
    (offuture.order_item.sales / (1 - offuture.order_item.discount))
    - offuture.order_item.sales AS discount_value
FROM offuture.order_item;


--Discount impact cost: This includes the original cost of each product

CREATE OR REPLACE VIEW all_2509.team8_discount_impact_cost AS
SELECT
    p.order_id,
    p.product_id,
    p.original_cost,
    p.before_discount_price,
    d.discount_value
FROM all_2509.team8_originalprices AS p
INNER JOIN all_2509.team8_discount_impact AS d
    ON
        p.order_id = d.order_id
        AND p.product_id = d.product_id;

--TABLES:

--First Fulltable: This was our first master table that
--initially joined, the product, order and adress tables as 
--well as the id_union view
CREATE OR REPLACE VIEW all_2509.team8_fulltable AS
SELECT
    offuture."order".customer_id,
    offuture."order".address_id,
    offuture.order_item.order_id,
    offuture.product.product_id,
    offuture.product.product_name,
    offuture.product.category,
    offuture.product.sub_category,
    offuture.order_item.sales,
    offuture.order_item.quantity,
    offuture.order_item.discount,
    offuture.order_item.profit,
    offuture.order_item.shipping_cost,
    offuture."order".order_date,
    offuture."order".ship_date,
    offuture."order".ship_mode,
    offuture."order".market,
    offuture."order".region,
    offuture."order".order_priority,
    offuture.address.city,
    offuture.address.state,
    offuture.address.country,
    offuture.address.postal_code,
    offuture.address.address_line_1,
    offuture.address.address_line_2,
    all_2509.id_union.customer_name
FROM offuture.order_item
INNER JOIN offuture.product
    ON offuture.product.product_id = offuture.order_item.product_id
INNER JOIN offuture."order"
    ON offuture."order".order_id = offuture.order_item.order_id
INNER JOIN offuture.address
    ON offuture.address.address_id = offuture."order".address_id
INNER JOIN all_2509.id_union
    ON all_2509.id_union.customer_id = offuture."order".customer_id;

--Master table: This table was built off of fulltable and includes the 
--original profit
CREATE OR REPLACE VIEW all_2509.team8_master AS
SELECT
    mv.order_id,
    mv.product_id,
    mv.customer_id,
    mv.address_id,
    mv.product_name,
    mv.category,
    mv.sub_category,
    mv.sales,
    mv.quantity,
    mv.discount,
    mv.profit,
    mv.shipping_cost,
    mv.order_date,
    mv.ship_date,
    mv.ship_mode,
    mv.market,
    mv.region,
    mv.order_priority,
    mv.city,
    mv.state,
    mv.country,
    mv.postal_code,
    mv.address_line_1,
    mv.address_line_2,
    mv.customer_name,
    mv.original_cost,
    mv.before_discount_price,
    mv.discount_value,
    op.original_profit
FROM
    all_2509.team8_fulltable AS mv
INNER JOIN
    all_2509.team8_org_profit AS op
    ON
        mv.order_id = op.order_id
        AND mv.product_id = op.product_id;

-- QUERIES TO ANALYSE DATA
-- Total revenue by year and quarter:
-- In our presentation thsi was used to produce the 
--'Monthly Sales Trends by Year
-- And 'Quarterly Sales Trends by Year' graph
SELECT
    mv.order_date,
    SUM(mv.sales) AS total_revenue
FROM
    team8_fulltable AS mv
GROUP BY
    mv.order_date
ORDER BY
    total_revenue DESC;

-- Total Profit by year and quarter:
-- In our presentattion this was used to produce the 
--'Quarterly Profit by Year'graph
SELECT
    mv.order_date,
    SUM(mv.profit) AS total_profit
FROM
    team8_fulltable AS mv
GROUP BY
    mv.order_date
ORDER BY
    total_profit DESC;

-- Loss of profit
SELECT (SUM(original_profit) - SUM(profit)) AS total_profit_lost
FROM
    all_2509.team8_master;

--Top 5 products by sales in the furniture category as a sum:
-- This was used to produce the 'Highest Sales Revenue in Each Category' graph
SELECT
    product_name,
    SUM(sales) AS sales_sum
FROM all_2509.team8_fulltable
WHERE category ILIKE 'furniture'
GROUP BY product_name
ORDER BY sales_sum DESC
LIMIT 5;


--Top 5 products by sales in the office supplies category as a sum
-- This was used to produce the 'Top Performing Office Supplies by Sales' graph
SELECT
    product_name,
    SUM(sales) AS sales_sum
FROM all_2509.team8_fulltable
WHERE category ILIKE 'office supplies'
GROUP BY product_name
ORDER BY sales_sum DESC
LIMIT 5;


--Top 5 products by profit in total as a sum
SELECT
    product_name,
    SUM(profit) AS profit_sum
FROM all_2509.team8_fulltable
GROUP BY product_name
ORDER BY profit_sum DESC
LIMIT 5;


-- Top 5 Profitable products:
-- This was used to produce the 'Where is your profit coimg from?' graph
SELECT
    mv.product_name,
    SUM(mv.profit) AS total_profit,
    SUM(mv.quantity) AS total_quantity
FROM
    team8_fulltable AS mv
GROUP BY
    mv.product_name
ORDER BY
    total_profit DESC, total_quantity DESC
LIMIT 5;

-- Least 5 Profitable products
SELECT
    mv.product_name,
    mv.category,
    SUM(mv.profit) AS total_profit,
    SUM(mv.quantity) AS total_quantity
FROM
    team8_fulltable AS mv
GROUP BY
    mv.product_name
ORDER BY
    total_profit ASC, total_quantity DESC
LIMIT 5;

-- How many of the Top 50 products are technology
SELECT COUNT(category) AS tech_count
FROM (
    SELECT
        product_name,
        category,
        SUM(profit) AS total_profit
    FROM all_2509.team8_fulltable
    GROUP BY product_name, category
    ORDER BY SUM(profit) DESC
    LIMIT 50
) AS top_products
WHERE category = 'Technology';


-- Top 10 Countries by revenue 
-- This was used to create the 'Countries by Revenue' Map in our presentation
SELECT
    mv.country,
    SUM(mv.sales) AS total_revenue
FROM
    team8_fulltable AS mv
GROUP BY
    mv.country
ORDER BY
    total_revenue DESC
LIMIT 10;
SELECT
    ft.country,
    SUM(ft.sales) AS total_revenue
FROM
    team8_fulltable AS ft
GROUP BY
    ft.country
ORDER BY
    total_revenue DESC
LIMIT 10;

-- Bottom 10 countries by revenue
-- This was used to create the 'Countries by Revenue' Map in our presentation
SELECT
    ft.country,
    SUM(ft.sales) AS total_revenue
FROM
    team8_fulltable AS ft
GROUP BY
    ft.country
ORDER BY
    total_revenue ASC
LIMIT 10;

-- All Countries by revenue
SELECT
    ft.country,
    SUM(ft.sales) AS total_revenue
FROM
    team8_fulltable AS ft
GROUP BY
    ft.country
ORDER BY
    total_revenue DESC;

-- Creates temporary table of country revenue totals
WITH country_revenues AS (
    SELECT
        ft.country,
        SUM(ft.sales) AS total_revenue
    FROM
        team8_fulltable AS ft
    GROUP BY
        ft.country
)

-- Calculates revenue distribution percentiles from ordered table
SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_revenue)
        AS percentile_25,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_revenue) AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_revenue) AS percentile_75
FROM
    country_revenues;

-- Top 10 countries - average selling price
SELECT
    ft.country,
    SUM(ft.sales) / SUM(ft.quantity) AS average_selling_price
FROM
    team8_fulltable AS ft
GROUP BY
    ft.country
HAVING
    SUM(ft.quantity) >= 5000
ORDER BY
    average_selling_price DESC
LIMIT 10;

-- Average shipping cost by country
SELECT
    ft.country,
    AVG(ft.shipping_cost) AS average_shipping_cost
FROM
    team8_fulltable AS ft
GROUP BY
    ft.country
ORDER BY
    average_shipping_cost DESC;
