\set content '''' `cat input.txt` ''''
insert into inputs (day, data) values (4, :content) on conflict (day) do update set data = excluded.data;

drop table if exists day04_pairs;
create table day04_pairs (
    id serial primary key,
    one int4range not null,
    two int4range not null
);
create index on day04_pairs using gist (one);
create index on day04_pairs using gist (two);

insert into day04_pairs (one, two)
select
    ('[' || n[1] || ',' || n[2] || ']')::int4range as one,
    ('[' || n[3] || ',' || n[4] || ']')::int4range as two
from (
    select regexp_split_to_array(pair, '[,-]') n from (
        select regexp_split_to_table(data, '\n') pair from inputs where day = 4
    ) t1
) t2;

-- Part One
select count(*) as part1 from day04_pairs where one @> two or two @> one;

-- Part Two
select count(*) as part2 from day04_pairs where one && two;