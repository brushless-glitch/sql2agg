-- Test SQL statement

select field1, field2,
    full_name = first_name + ' ' + last_name,
    just_name = first_name
FROM t1
    LEFT OUTER JOIN t2 ON t1.xx =  t2.zz
    LEFT JOIN t3 ON t1.yy =  t3.zzz
WHERE ((f4=977) and f5>=555) and (f6>6 or f7<=2)
    or f8 between 7 and 20
    and f9 in (1,2,3,15,222)
    or t1 = 'blablabla'
    or city like 'L_s %'
