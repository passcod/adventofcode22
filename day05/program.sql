\set content '''' `cat input.txt` ''''
insert into inputs (day, data) values (5, :content) on conflict (day) do update set data = excluded.data;

drop table if exists day05_moves;
create table day05_moves (
    id serial primary key,
    crate int not null,
    from_stack int not null,
    to_stack int not null
);

drop table if exists day05_crates;
create table day05_crates (
    height int not null,
    stack int not null,
    crate text
);

with
moves as (select regexp_split_to_table(substring(data from (position('move' in data) - 4)), '\n') m from inputs where day = 5),
parsed as (select regexp_match(m, 'move (\d+) from (\d+) to (\d+)') p from moves)
insert into day05_moves (crate, from_stack, to_stack)
select p[1]::int, p[2]::int, p[3]::int from parsed where p[1] != '';

with
crates as (select regexp_split_to_table(substring(data for (position('move' in data) - 4)), '\n') m from inputs where day = 5),
layers as (select (
    select array_agg(
        case regexp_matches[1]
        when '   ' then null
        else substring(regexp_matches[1] from 2 for 1)
        end
    ) crates from regexp_matches(m || ' ', '(\[.\]| {3}) ', 'g')
) layer, row_number() over (rows 0 preceding) n from crates),
parsed as (
    SELECT (select max(n) from layers) - n as height, s AS stack, layer[s] AS crate
    from (select generate_subscripts(layer, 1) as s, n, layer from layers) t1
    order by height asc, stack asc
)
insert into day05_crates (height, stack, crate)
select * from parsed;

select * from day05_crates \crosstabview

-- Part One
-- Part Two