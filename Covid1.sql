Select *
From PortfolioProject..['covid-deaths$']
Where continent is not null
order by 3,4


--Select *
--From PortfolioProject..[covid-vax$']


--Select Data that we are going to use.

Select Location,date,total_cases,new_cases, total_deaths, population
From PortfolioProject..['covid-deaths$']
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in your country

Select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['covid-deaths$']
Where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of popuplation got Covid

Select Location,date,population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..['covid-deaths$']
Where location like '%states%'
order by 1,2


-- Looing at Countries with Highest Infection rate compared to Population

Select Location,population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..['covid-deaths$']
Group by Location, population
order by PercentPopulationInfected desc


-- Shows Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid-deaths$']
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- Highest Death Count per Population By Continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid-deaths$']
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers


Select date,SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['covid-deaths$']
Where continent is not null
Group by date
order by 1,2

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['covid-deaths$']
Where continent is not null
order by 1,2

-- Toal Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..['covid-deaths$'] dea
Join PortfolioProject..[covid-vax$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['covid-deaths$'] dea
Join PortfolioProject..[covid-vax$'] vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['covid-deaths$'] dea
Join PortfolioProject..[covid-vax$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
