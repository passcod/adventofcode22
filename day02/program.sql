\set content '''' `cat input.txt` ''''
delete from inputs where day = 2;
insert into inputs (day, data) values (2, :content);

drop table day02_input;
create table day02_input (
  n serial primary key,
  theirs text,
  mine text
);
insert into day02_input (theirs, mine)
select ym[1] as theirs, ym[2] as mine from (
select regexp_split_to_array(round, ' ') ym from (
select regexp_split_to_table(data, '\n') round from inputs where day = 2) t1) t2;

-- Part One
with scores as (select

case
when theirs = 'A' and mine = 'X' then 3 -- draw
when theirs = 'B' and mine = 'X' then 0 -- lose
when theirs = 'C' and mine = 'X' then 6 -- win
when theirs = 'A' and mine = 'Y' then 6 -- win
when theirs = 'B' and mine = 'Y' then 3 -- draw
when theirs = 'C' and mine = 'Y' then 0 -- lose
when theirs = 'A' and mine = 'Z' then 0 -- lose
when theirs = 'B' and mine = 'Z' then 6 -- win
when theirs = 'C' and mine = 'Z' then 3 -- draw
end as round_score,

case mine
when 'X' then 1
when 'Y' then 2
when 'Z' then 3
end as play_score

from day02_input)

select sum(round_score + play_score) from scores;

-- Part Two
with scores as (select

case
when theirs = 'A' and mine = 'X' then 3 -- scissor
when theirs = 'B' and mine = 'X' then 1 -- rock
when theirs = 'C' and mine = 'X' then 2 -- paper
when theirs = 'A' and mine = 'Y' then 1 -- rock
when theirs = 'B' and mine = 'Y' then 2 -- paper
when theirs = 'C' and mine = 'Y' then 3 -- scissor
when theirs = 'A' and mine = 'Z' then 2 -- paper
when theirs = 'B' and mine = 'Z' then 3 -- scissor
when theirs = 'C' and mine = 'Z' then 1 -- rock
end as play_score,

case mine
when 'X' then 0
when 'Y' then 3
when 'Z' then 6
end as round_score

from day02_input)

select sum(round_score + play_score) from scores;
