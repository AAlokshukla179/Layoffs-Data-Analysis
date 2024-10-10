-- Data Cleaning

use layoffs;

select * from layoffs;
 
CREATE TABLE `layoffs2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select* from layoffs2;

insert into layoffs2
select * ,
row_number() over (partition by company,industry,
total_laid_off,percentage_laid_off,'date') as row_num
from layoffs;

select * from layoffs2;

--1. Remove Duplicates
select* from layoffs2
where row_num>1;

delete from layoffs2
where row_num>1;

select* from layoffs2;

-- 2. Standardize the data

select company,trim(company) from layoffs2;

update layoffs2
set company=trim(company);

select company from layoffs2; 

select industry from layoffs2
group by industry;

update layoffs2
set industry= "Crypto"
where industry like "Crypto%";


select distinct location
from layoffs2
order by 1;

select distinct country,trim(trailing ' . 'from country)
from layoffs2
order by 1;

update layoffs2
set country=trim(trailing '.' from country)
where country like 'United States%';

select distinct country 
from layoffs2
order by 1;

select `date`
from layoffs2;

update layoffs2
set `date` = str_to_date(`date`,'%m/%d/%Y');

alter table layoffs2
modify column `date` Date;

-- check null values

select *
from layoffs2
where industry is null 
or industry = '';

update layoffs2 
set industry = null
where industry='';

select *
from layoffs2
where company like 'Bally%';

select t1.industry,t2.industry
from layoffs2 t1
join layoffs2 t2
on t1.company = t2.company
and t1.location = t2.location
where(t1.industry is null or t2.industry = '')
and t2.industry is not null;

update layoffs2 t1
join layoffs2 t2
on t1.company=t2.company
set t1.industry=t2.industry 
where t1.industry is null
and t2.industry is not null;

select * from layoffs2
where total_laid_off is null
and percentage_laid_off is null;

delete from layoffs2
where total_laid_off is null
and percentage_laid_off is null;

select * from layoffs2;


-- exploratory analysis
-- 1.How many layoffs happend per country?

select country, sum(total_laid_off)
as total_layoffs
from layoffs2
group by country
order by total_layoffs desc
limit 10;

-- 2.Which industry faced the highest number of layoffs?

select industry, sum(total_laid_off)
as total_layoffs
from layoffs2
group by industry
order by total_layoffs desc;

-- 3.Which companies laid off more than a
-- certain threshold of employees(e.g.,1000)?

select company,total_laid_off
from layoffs2
where total_laid_off>5000
order by total_laid_off desc; 

-- 4.What is the average percentage of workforce laid off per industry?

select industry,Avg(percentage_laid_off)
as avg_percentage_laid_off
from layoffs2
group by industry 
order by avg_percentage_laid_off desc;

-- 5. What are the top 10 companies with the most layoffs?

select company ,total_laid_off
from layoffs2
order by total_laid_off desc 
limit 10;

-- 6.What is the total number of layoffs across all companies?

select sum(total_laid_off) as total_offs
from layoffs2;

-- 7.How many layoffs occured in each funding stage(e.g., Post-IPO, Series B)?

select stage, count(*) as num_layoffs
from layoffs2
group by stage 
order by  num_layoffs desc;

-- 8.Which country raised the highest amount of funds?

select country, SUM(funds_raised_millions) 
as total_fund_raised
from layoffs2
group by country
order by total_fund_raised desc
limit 10;

-- 9.WHich companies had layoffs with missing data for percentage laid off?

select company, total_laid_off
from layoffs2
where percentage_laid_off is null
order by total_laid_off desc;

-- 10. How many layoffs occured in a specific time period(e.g.,2023)?

select count(*) as layoffs_in_2023
from layoffs2
where year(date)=2023; 

-- 11. Which countries have the higest percentage of layoffs relative to their total workforce?

select country,avg(percentage_laid_off) as avg_percentage_laid_off
from layoffs2
group by country
order by avg_percentage_laid_off desc
limit 10; 

-- 12. Which is the distribution of layoffs across different locations(cities)?

select location,count(*) as num_offs
from layoffs2
group by location
order by num_offs desc;

-- 13. What are the top 5 industries that raised the most funds and had layoffs?

select 
industry,sum(funds_raised_millions)
as total_funds_raised
from layoffs2
where total_laid_off>0
group by industry
order by total_funds_raised desc
limit 5;

-- 14.Maximum of total_laid_off and percentage_laid_off ?

select max(total_laid_off),
max(percentage_laid_off)
from layoffs2;

-- 15.Layoffs from start date to end date?

select min(date),max(date)
from layoffs2;

-- 16.Sum of total_laid_off by year?

select year(date),sum(total_laid_off)
from layoffs2
group by year(date)
order by 1 desc;

