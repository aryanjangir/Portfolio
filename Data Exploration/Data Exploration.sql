/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
Database name: 'Covid'
Tables name: 'Deaths' and 'Vaccinations'
*/

select *
from Covid..Deaths
where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

select Location, date, total_cases, new_cases, total_deaths, population
from Covid..Deaths
where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in India/ any other country

select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from Covid..Deaths
where location like 'India'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select Location, date, Population, total_cases,  (total_cases/population)*100 as Percent_Population_Infected
from Covid..Deaths
order by 1,2

-- Countries with Highest Infection Rate compared to Population

select Location, Population, MAX(total_cases) as Highest_Infection_Count,  Max((total_cases/population))*100 as Percent_Population_Infected
from Covid..Deaths
group by Location, Population
order by Percent_Population_Infected desc

-- Countries with Highest Death Count per Population

select Location, MAX(cast(Total_deaths as int)) as Total_Death_Count
from Covid..Deaths
where continent is not null 
group by Location
order by Total_Death_Count desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select continent, MAX(cast(Total_deaths as int)) as Total_Death_Count
from Covid..Deaths
where continent is not null 
group by continent
order by Total_Death_Count desc

-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
from Covid..Deaths
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
from Covid..Deaths dea
join Covid..Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
from Covid..Deaths dea
join Covid..Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
select *, (Rolling_People_Vaccinated/Population)*100
from PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

drop Table if exists #Percent_Population_Vaccinated
create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

insert into #Percent_Population_Vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
from Covid..Deaths dea
join Covid..Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

select *, (Rolling_People_Vaccinated/Population)*100
from #Percent_Population_Vaccinated

-- Creating View to store data for later visualizations

create View Percent_Population_Vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
from Covid..Deaths dea
join Covid..Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 