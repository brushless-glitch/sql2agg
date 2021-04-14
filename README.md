# SQL2AGG

This project is designed for educational purposes. It is a quick way for "what-if" translation
of SQL to MondoDB query.

## Limitations:

### Schame Validation

there is no schema validation whatsoever. Fields are assumed to exist.

### Text strings

- test strings are not escaped, e.g.: 'Johnson''s car' is not valid string
- LIKE operator does not sanitize string for regex characters

### JOINS:

- only one left outer join is supported, and assumption is that format is

```
 [LEFT [OUTER]] JOIN <collection> ON <maincollection>.<field> = <collection>.<field>
```