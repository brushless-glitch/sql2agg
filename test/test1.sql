-- Test SQL statement

-- Keywords are case-insensitive
SeLeCT 
    -- TOP keyword is duplicated with LIMIT
    TOP 100

    -- Verbatim fields
    field1, field2,
    -- name = field supported
    just_name = first_name,
    -- Text concatenation
    full_name = first_name + ' ' + last_name
FROM t1
    -- See README for limitations on joins
    LEFT OUTER JOIN t2 ON t1.xx =  t2.zz
    LEFT JOIN t3 ON t1.yy =  t3.zzz

WHERE 

    -- Use parenthesis to combine logical operators
    -- notice that $and and $or are combined where possible
    ((f4=977) and f5>=555) and (f6>6 or f7<=2)
    -- BETWEEN operator supported
    or f8 between 7 and 20
    -- IN operator supported using $in
    and f9 in (1,2,3,15,222)
    -- text comparison
    or t1 = 'blablabla'
    -- LIKE operator translated to $regex
    or city like 'L_s %'

ORDER BY
    -- default
    field1,
    -- ascending
    field2 ASCENDING,
    -- ASC is an alias for ASCENDING
    field3 ASC,
    -- descending
    field4 DESCENDING,
    -- DESC is also alias
    field5 DESC

SKIP 20
LIMIT 50
