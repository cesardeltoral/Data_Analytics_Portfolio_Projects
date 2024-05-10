SELECT *
FROM PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$	
--order by 3,4

-- Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at the total cases vs total death
-- Shows likelyhood of dying if you contract  covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as deathpercentage
FROM PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

-- Looking at the total cases vs the population
-- shows what percentage of population got covid
SELECT Location, date, population, total_cases, (total_cases / population) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
-- Where location like '%states%'
order by 1,2

--  Looking at Countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population)) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
-- Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
-- Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- LETS BREAK THING DOWN BY CONTINENTS
-- Showing the continent with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,  SUM(cast(new_deaths as int)) / SUM(New_cases) * 100  as deathpercentage
FROM PortfolioProject..CovidDeaths$
-- Where location like '%states%'
where continent is not null
-- Group By date
order by 1,2

-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject.. CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 1,2,3


-- USE CTE	

with PopvsVac (continent, Location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject.. CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
-- order by 1,2,3
)
Select *, (RollingPeopleVaccinated/population) * 100
FROM PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date DateTime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject.. CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
-- order by 1,2,3

Select *, (RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject.. CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
-- order by 1,2,3

Select *
From PercentPopulationVaccinated