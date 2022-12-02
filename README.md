# Advent of Code 2022: PostgreSQL

First create a database and load the schema with

```console
psql < schema.sql
```

Then each day is self-contained and written in PSQL:

```console
cd day01
psql < program.sql
```

The input is placed in `input.txt` alongside the program.

## Limitations

- PSQL syntax and macros are allowed
- PostgreSQL version is 14.5
- User running the code is a postgres superuser
- Extensions, PLPgSQL, others languages, etc *are* allowed but solutions should primarily be in SQL where possible.
