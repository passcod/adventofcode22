\set content '''' `cat input.txt` ''''
insert into inputs (day, data) values (3, :content) on conflict (day) do update set data = excluded.data;

drop table day03_input;
create table day03_input (
  n serial primary key,
  l text not null,
  r text not null
);
insert into day03_input (l, r)
select
substring(sack for char_length(sack) / 2) as l,
substring(sack from char_length(sack) / 2 + 1) as r
from (
select regexp_split_to_table(data, '\n') sack from inputs where day = 3) t1;


-- Part One
with
common_item as (select
  (select item from (
    select regexp_split_to_table(l, '') as item
    intersect
    select regexp_split_to_table(r, '') as item
  ) i limit 1)
  from day03_input
),
charcodes as (select item, ascii(item) priority from common_item),
priorities as (select
    item,
    case
      when priority >= 97 then priority - 96
      else priority - 65 + 27
    end priority
  from charcodes
)
select sum(priority) from priorities;

-- Part Two
with
group_sacks as (select distinct
  array_agg(l || r) over (partition by ceil(((n - 1) / 3))) sacks
from day03_input),
common_item as (select
  (select item from (
    select regexp_split_to_table(sacks[1], '') as item
    intersect
    select regexp_split_to_table(sacks[2], '') as item
    intersect
    select regexp_split_to_table(sacks[3], '') as item
  ) i limit 1)
from group_sacks),
charcodes as (select item, ascii(item) priority from common_item),
priorities as (select
    item,
    case
      when priority >= 97 then priority - 96
      else priority - 65 + 27
    end priority
  from charcodes
)
select sum(priority) from priorities;

