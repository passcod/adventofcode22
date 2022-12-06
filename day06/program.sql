\set content '''' `cat input.txt` ''''
insert into inputs (day, data) values (6, :content) on conflict (day) do update set data = excluded.data;

-- Part One
\set window 4
\set prec (:window - 1)
with
chars as (select string_to_table(data, null) ch from inputs where day = 6),
windows as (select array_agg(ch) over (rows :prec preceding) as marker from chars),
markers as (select row_number() over (rows 0 preceding) n, * from windows where array_length(marker, 1) = :window)
select n + :prec, marker from markers where (
    select count(*) from
    (select distinct unnest(marker)) t
) = :window limit 1;

-- Part Two
-- identical except for the window set
\set window 14
\set prec (:window - 1)
with
chars as (select string_to_table(data, null) ch from inputs where day = 6),
windows as (select array_agg(ch) over (rows :prec preceding) as marker from chars),
markers as (select row_number() over (rows 0 preceding) n, * from windows where array_length(marker, 1) = :window)
select n + :prec, marker from markers where (
    select count(*) from
    (select distinct unnest(marker)) t
) = :window limit 1;
