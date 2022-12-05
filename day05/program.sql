\set content '''' `cat input.txt` ''''
insert into inputs (day, data) values (5, :content) on conflict (day) do update set data = excluded.data;

drop materialized view if exists d5p2_enumerated_moves;
drop materialized view if exists d5p1_enumerated_moves;
drop type if exists onemove;
create type onemove as (from_stack int, to_stack int);

drop table if exists day05_moves;
create table day05_moves (
    id serial primary key,
    crates int not null,
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
insert into day05_moves (crates, from_stack, to_stack)
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
create materialized view d5p1_enumerated_moves as (
    select
        row_number() over (rows 0 preceding) as id,
        (moves).from_stack, (moves).to_stack
    from (
        select unnest(('{' || rtrim(repeat('"(' || from_stack || ',' || to_stack || ')",', crates), ',') || '}')::onemove[]) as moves
        from day05_moves
    ) t
);
create index on d5p1_enumerated_moves (id);

with recursive stacks(n, thismove, height, stack, crate) as (
    select 1, null::onemove, height, stack, crate from day05_crates
    union all
    select * from (
    with
    withmove as (
        select n, stacks.height, stacks.stack, stacks.crate, (
            select (moves.from_stack, moves.to_stack)::onemove
            from d5p1_enumerated_moves moves
            where moves.id = stacks.n
        ) thismove
        from stacks
        where crate is not null
    ),
    max_heights as (
        select max(height) as max_height, stack from withmove group by stack
    )
    select n + 1, thismove,
        case
        when
            stack = (thismove).from_stack and
            height = (select max_height from max_heights mh where mh.stack = withmove.stack)
        then coalesce((select max_height from max_heights mh where mh.stack = (thismove).to_stack), 0) + 1
        else height
        end as height,

        case
        when
            stack = (thismove).from_stack and
            height = (select max_height from max_heights mh where mh.stack = withmove.stack)
        then (thismove).to_stack
        else stack
        end as stack,

        crate
    from withmove
    where thismove is not null
    -- and n < 2
    ) u
)
select height, stack, crate from stacks where n = (select max(n) from stacks) order by height, stack \crosstabview
-- select * from stacks;
-- select * from stacks where n = (select max(n) from stacks);


-- Part Two
create materialized view d5p2_enumerated_moves as (
    select
        row_number() over (rows 0 preceding) as id,
        (moves).from_stack, (moves).to_stack
    from (
        select unnest(('{' || rtrim(
            repeat('"(' || from_stack || ',0)",', crates) ||
            repeat('"(0,' || to_stack || ')",', crates)
            -- move first into a 0 stack, then to the right place, and that
            -- simulates moving the whole part of the stack into the right place
        , ',') || '}')::onemove[]) as moves
        from day05_moves
    ) t
);
create index on d5p2_enumerated_moves (id);

-- identical to part 1, all that changes is the enumerated moves
with recursive stacks(n, thismove, height, stack, crate) as (
    select 1, null::onemove, height, stack, crate from day05_crates
    union all
    select * from (
    with
    withmove as (
        select n, stacks.height, stacks.stack, stacks.crate, (
            select (moves.from_stack, moves.to_stack)::onemove
            from d5p2_enumerated_moves moves
            where moves.id = stacks.n
        ) thismove
        from stacks
        where crate is not null
    ),
    max_heights as (
        select max(height) as max_height, stack from withmove group by stack
    )
    select n + 1, thismove,
        case
        when
            stack = (thismove).from_stack and
            height = (select max_height from max_heights mh where mh.stack = withmove.stack)
        then coalesce((select max_height from max_heights mh where mh.stack = (thismove).to_stack), 0) + 1
        else height
        end as height,

        case
        when
            stack = (thismove).from_stack and
            height = (select max_height from max_heights mh where mh.stack = withmove.stack)
        then (thismove).to_stack
        else stack
        end as stack,

        crate
    from withmove
    where thismove is not null
    -- and n < 2
    ) u
)
select height, stack, crate from stacks where n = (select max(n) from stacks) order by height, stack \crosstabview
-- select * from stacks;
-- select * from stacks where n = (select max(n) from stacks);
