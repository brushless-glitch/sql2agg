# SQL2AGG


## Limitations:

### JOINS:

- only one left outer join is supported, and assumption is that format is

```
 [LEFT [OUTER]] JOIN <collection> ON <maincollection>.<field> = <collection>.<field>
```