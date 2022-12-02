\set content '''' `cat input.txt` ''''
delete from inputs where day = 1;
insert into inputs (day, data) values (1, :content);

-- Part One
with
elf_text as (
select regexp_split_to_table(data, '\n\n') cals from inputs where day = 1
),
elf_arrays as (
select regexp_split_to_array(cals, '\n')::int[] cals from elf_text
),
elf_food as (
select cals, (select sum(c) from unnest(cals) c) total from elf_arrays
)
select max(total) from elf_food;

-- Part Two
with
elf_text as (
select regexp_split_to_table(data, '\n\n') cals from inputs where day = 1
),
elf_arrays as (
select regexp_split_to_array(cals, '\n')::int[] cals from elf_text
),
elf_food as (
select cals, (select sum(c) from unnest(cals) c) total from elf_arrays
),
elf_top_three as (
select * from elf_food order by total desc limit 3
)
select sum(total) from elf_top_three;