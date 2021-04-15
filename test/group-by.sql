SELECT COUNT(*), avg(x), max(x), min(x)
FROM t1 
WHERE field='xx'
GROUP BY xx,yy,year % 4
