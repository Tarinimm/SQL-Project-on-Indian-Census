select * from [project 1].dbo.data1;
select * from [project 1].dbo.data2;

-- no of rows into our dataset --
select COUNT(*)from [project 1]..data1;
select COUNT(*)from [project 1]..data2;

-- dataset for jharkhand and bihar --

select * from [project 1]..data1 where state in ( 'Jharkhand','Bihar')

-- population of india --

select sum (population)as population from [project 1]..data2

-- avg growth --

select state, AVG(growth)*100 avg_growth from [project 1]..data1 group by state;

-- avg sex ratio --

select state, round(AVG(sex_ratio),0) avg_sex_ratio from [project 1]..data1 group by state order by avg_sex_ratio desc;

-- avg literacy rate --
select state, round(AVG(literacy),0) avg_literacy_ratio from [project 1]..data1 
group by state having round (avg(literacy),0)>90 order by avg_literacy_ratio desc;

-- top 3 state showing highest growth ratio --

select top 3 state, AVG(growth)*100 avg_growth from [project 1]..data1 group by state order by avg_growth desc;

-- bottom  3 state showing lowest sex ratio --

select top 3 state, round(AVG(sex_ratio),0) avg_sex_ratio from [project 1]..data1 group by state order by avg_sex_ratio asc;

-- top and bottom 3 sataes in literacy state --
drop table if exists #topstates1;
create table #topstates1
( state nvarchar(255),
topstates float )

insert into #topstates1
select state, round(AVG(literacy),0) avg_literacy_ratio from [project 1]..data1 group by state order by avg_literacy_ratio desc;

select top 3 * from #topstates1 order by #topstates1.topstates desc;


drop table if exists #bottomstates1;
create table #bottomstates1
( state nvarchar(255),
bottomstates float )

insert into #bottomstates1
select state, round(AVG(literacy),0) avg_literacy_ratio from [project 1]..data1 group by state order by avg_literacy_ratio desc;

select top 3 * from #bottomstates1 order by #bottomstates1.bottomstates asc;

-- union opertaor --
select * from (
select top 3 * from #topstates1 order by #topstates1.topstates desc) a
union
select * from ( 
select top 3 * from #bottomstates1 order by #bottomstates1.bottomstates asc) b;

-- states starting from letter a --

select distinct state from [project 1]..data1 where lower (state) like 'a%' or lower(state) like'b%'

select distinct state from [project 1]..data1 where lower (state) like 'a%' and lower(state) like'%m'

-- joining table --
select a.district,a.state,a.sex_ratio,b.population from [project 1]..data1 a inner join [project 1]..data2 b on a.district=b.district


-- total males and females --
-- female / males = sex_ratio .....1  --
--  female + males = population ....2 --
-- female = population - males .....3 --
-- ( population - males) = (sex_ratio)*males --
-- population= males (sex_ratio+1)--
-- males = population /(sex_ratio+1).... males --
-- female = population - population /(sex_ratio+1)...female --
-- = population(1-1/(sex_ratio+1)) --
-- = (population * (sex_ratio )) / (sex_ratio+1)


SELECT d.state, SUM(d.males) AS total_males, SUM(d.females) AS total_females
FROM (
    SELECT c.district, c.state, ROUND(c.population / (c.sex_ratio + 1), 0) AS males, ROUND((c.population * c.sex_ratio) / (c.sex_ratio + 1), 0) AS females
    FROM (
        SELECT a.district, a.state, a.sex_ratio / 1000 AS sex_ratio, b.population
        FROM [project 1]..data1 a
        INNER JOIN [project 1]..data2 b ON a.district = b.district
    ) c
) d
GROUP BY d.state;

-- total literacy rate --
-- total literate people/population=literacy_ratio --
-- total literate people = litera_ratio*population --
-- total literate people= (1-literate_ratio)*population --

select c.state,sum(literate_people) total_literate_pop,sum(illiterate_people) total_lliterate_pop from 
(select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people,
round((1-d.literacy_ratio)* d.population,0) illiterate_people from
(select a.district,a.state,a.literacy/100 literacy_ratio,b.population from [project 1]..data1 a 
inner join [project 1]..data2 b on a.district=b.district) d) c
group by c.state

-- population in previous census --
-- previous census + growth*previous census = population --
-- previous census = population / (1+ growths) --


select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from [project 1]..data1 a inner join [project 1]..data2 b on a.district=b.district) d) e
group by e.state)m


-- population vs area

select (g.total_area/g.previous_census_population)  as previous_census_population_vs_area, (g.total_area/g.current_census_population) as 
current_census_population_vs_area from
(select q.*,r.total_area from (

select '1' as keyy,n.* from
(select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from [project 1]..data1 a inner join [project 1]..data2 b on a.district=b.district) d) e
group by e.state)m) n) q inner join (

select '1' as keyy,z.* from (
select sum(area_km2) total_area from [project 1]..data2)z) r on q.keyy=r.keyy)g

--window 

--output top 3 districts from each state with highest literacy rate--


select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from [project 1]..data1) a

where a.rnk in (1,2,3) order by state