create database Portfolio_Project;

use Portfolio_project;

select location, date, total_cases, new_cases, total_deaths, population
from dv
order by 1,2;

-- Looking at Total cases vs total deaths as percentage

select location, date, total_cases, total_deaths, format((total_deaths / total_cases) * 100 , 2) as Percentage
from dv
where location like '%states%'
order by 1,2;

-- Total Cases vc Population
-- Show what percentage of population got Covid

select location, date, population, total_cases, format((total_cases / population) * 100 , 2) as Percentage
from dv
where location like '%states%'
order by date;

-- Countris with the highest infection rate compared to population 

select location, population, max(total_cases) as HighestInfectionCount, 
max(format((total_cases / population) * 100 , 2)) as PercentagePopulationInfected
from dv
group by population, location order by PercentagePopulationInfected desc;

-- Showing countries with highest death count per population

select location, max(cast(total_deaths as unsigned)) as TotalDeathCount
from dv
where continent is not NULL
group by location
order by TotalDeathCount desc;

-- Breaking things down by continent

select continent, max(cast(total_deaths as unsigned)) as TotalDeathCount
from dv
where continent is not null
group by continent
order by TotalDeathCount desc;

-- Showing the continents with the highest death count per population
select continent, max(cast(total_deaths as unsigned)) as TotalDeathCount
from dv
where continent is not null
group by continent
order by TotalDeathCount desc;

-- Global numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as unsigned)) as total_deaths, sum(cast(new_deaths as unsigned)) / sum (new_cases) * 100 as DeathPercentage
from dv
where continent is not null
-- group by date
order by 1,2;

-- Total Population vs Vaccination

select d.continent, d.location, d.date, d.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as unsigned)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated,
(RollingPeopleVaccinated / population) * 100
from dv d
join covidvaccinations vac
on d.location = vac.location and d.date = vac.date
where d.continent is not null
order by 2,3;

-- Use CTE

with Popvsvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select d.continent, d.location, d.date, d.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as unsigned)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated / population) * 100
from dv d
join covidvaccinations vac
on d.location = vac.location and d.date = vac.date
where d.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated / Population) * 100
from Popvsvac;


-- Temp Table
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as unsigned)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated / population) * 100
from dv d
join covidvaccinations vac
on d.location = vac.location and d.date = vac.date
-- where d.continent is not null
-- order by 2,3
Select *, (RollingPeopleVaccinated / Population) * 100
from #PercentPopulationVaccinated;

-- Creating view to store data

Create view PercentPopulationVaccinated as 
select d.continent, d.location, d.date, d.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as unsigned)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated / population) * 100
from dv d
join covidvaccinations vac
on d.location = vac.location and d.date = vac.date
where d.continent is not null
-- order by 2,3

select *
from PercentPopulationVaccinated;


 







 



