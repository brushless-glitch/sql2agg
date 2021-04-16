-- This is a sample SQL for SQL2AGG
-- demonstrates capabilities of the tool
--

SELECT 
    -- Verbatim fields
    address, zip_code,
    -- name = field supported, but not field AS name
    surname = last_name,
    -- Text concatenation
    full_name = first_name + ' ' + last_name,
    -- Arithmetic expressions
    total = ((price + tax) * number * (1 - discount)) + shipping_fee

FROM orders
    -- See README for limitations on joins
    LEFT JOIN users ON orders.user_id =  users.id

WHERE 

    ((price < 0.95 or price > 1000) and tax = 0)
    or discount between 0.01 and 0.10
    and category in (1,2,3,15,222)
    and order_status = 'complete'
    and city like 'L_s %'

ORDER BY
    price,
    number ASCENDING,
    last_name ASC,
    discount DESCENDING,
    tax DESC

SKIP 20
LIMIT 50
