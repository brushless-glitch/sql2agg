-- Test SQL statement

select f1,f2,f3
--    'first_name' + ' ' + 'middle_name' + ' ' + last_name as full_name
    ,full_name = first_name + ' ' + last_name
    ,just_name = first_name
FROM t1 
WHERE ((f4=977) and f5=555) and (f6>6 or f7<=2)
    or f8 between 7 and 20
    and f9 in (1,2,3,15,222)
    or t1 = 'blablabla'
    or city like 'L_s %'
