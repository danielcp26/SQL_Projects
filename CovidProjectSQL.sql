-- 📌 Select basic COVID data sorted by location and date
select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
order by 1,2;


-- 📌 Total Cases vs Total Deaths
-- Analyzes the likelihood of dying if infected with COVID-19

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from covid_deaths
where location like '%Costa%'
order by 1,2;

-- 📌 Total Cases vs Population
-- Shows the percentage of the population that got infected with COVID-19

select location, date, total_cases, population, (total_cases/population)*100 as Percentage
from covid_deaths
where location like '%Costa%'
order by 1,2;


-- 📌 Countries with the Highest Infection Rate Compared to Population
-- Finds the highest infection count for each country

select location, population, max(total_cases) as Highest_Infection_Count, max((total_cases/population))*100 as Percentage
from covid_deaths
group by location,population
order by Percentage desc;

-- 📌 Continents with the Highest Death Count
-- Aggregates total deaths per continent

select continent, max(total_deaths) as TotalDeathCount
from covid_deaths
where continent is not null
group by continent
order by TotalDeathCount desc;

-- 📌 Countries with the Highest Death Count Per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from covid_deaths
group by location
order by TotalDeathCount desc;


-- 📌 Global COVID-19 Statistics Per Day
-- Shows the total number of new cases, deaths, and death percentage over time

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from covid_deaths
where continent is not null
group by date
order by 1,2;

-- 📌 Joining COVID Cases with Vaccination Data
-- Combines case and vaccination data by location and date

Select * from covid_deaths dea
join covid_vaccinations vac
	on dea .location = vac.location
	and dea.date = vac.date;
	
	
-- 📌 Using Common Table Expressions (CTE) for Population vs Vaccination Analysis

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100
from covid_deaths dea
join covid_vaccinations vac
	on dea .location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3;
)
select *, (RollingPeopleVaccinated/population)*100 as Percentage from PopvsVac



-- 📌 Using Temporary Table to Store Vaccination Data
-- This table holds cumulative vaccination data to avoid recalculations

drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
continent text,
location text,
date date,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100
from covid_deaths dea
join covid_vaccinations vac
	on dea .location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3;
	
select *, (RollingPeopleVaccinated/population)*100 as percentage
from PercentPopulationVaccinated


-- 📌 Creating a View for Future Visualizations
-- Stores cumulative vaccination data for dashboards

create view PercentPopulationVaccinatedV as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100
from covid_deaths dea
join covid_vaccinations vac
	on dea .location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3;
	
	
select * from PercentPopulationVaccinatedV