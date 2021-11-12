-- look for data types before using aggregrate functions on them
select *
from CovidV$

select *
from CovidD$

-- Looking at total cases vs total deaths

select location, date, total_cases, total_deaths, round((total_deaths/total_cases) * 100,2) as death_percentage
from CovidD$
where location like '%india%'

-- looking at total cases vs population
select location,date, population, total_cases, (total_cases/population) * 100 as infected_percentage
from CovidD$
where location like '%india%'

-- looking at countries with highest infection rate compared to their population
select location, population, max(total_cases) highest_infection_count, max((total_cases/population) * 100) as infected_percentage
from CovidD$
group by location, population
order by infected_percentage desc

-- showing countries with highest deat counts per population
select location, max(cast(total_deaths as bigint)) as total_death_count
from CovidD$
where continent is not null
group by location
order by total_death_count desc

-- breaking things down by continent
-- Showing continents with highest death counts
select continent, max(cast(total_deaths as bigint)) as total_death_count
from CovidD$
where continent is not null
group by continent
order by total_death_count desc

-- global numbers across the world
select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)* 100 as death_percentage
from CovidD$ 
where continent is not null  
order by 1,2


-- total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
		sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidD$ dea
join CovidV$ vac
	on	dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- using CTE 
with popvsvac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
		sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidD$ dea
join CovidV$ vac
	on	dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

select *, (RollingPeopleVaccinated/population) * 100
from popvsvac


-- temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
		sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidD$ dea
join CovidV$ vac
	on	dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

select *, (RollingPeopleVaccinated/population) * 100
from #PercentPopulationVaccinated


-- creating view to store data for later visulasiation

create view PercentPopulationVaccinated
as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
		sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidD$ dea
join CovidV$ vac
	on	dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated






















