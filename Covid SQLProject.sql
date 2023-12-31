Select *
From portfolioproject..CovidDeaths
--where continent is not null
Order by 3,4

Select *
From portfolioproject..CovidVaccinations
Order by 3,4


--Select the data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..CovidDeaths
where continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage
from portfolioproject..CovidDeaths
--where location like '%India%' and continent is not null
order by 1,2 desc


--Looking at Total Cases vs Population
--Shows what percentage of population got covid

Select location, date, Population, total_cases, round((total_cases/Population)*100,2) as InfectedPercentage
from portfolioproject..CovidDeaths
--where location like '%India%' and continent is not null
order by 1,2 desc


--Looking at Countries with Highest Infection Rate compared to population

Select location, Population, MAX(total_cases) as HighestInfectionCount, round(MAX(total_cases/Population)*100,2) as CasesPercentage
from portfolioproject..CovidDeaths
--where location like '%India%' and continent is not null
Group by Location, Population
order by CasesPercentage desc


--Showing Countries with Highest Death Count per Population

Select location, MAX(cast (total_deaths as int)) as TotalDeath_per_country
from portfolioproject..CovidDeaths
--where location like '%India%' 
where continent is not null
Group by Location
order by TotalDeath_per_country desc


--Data for Continent

Select continent, MAX(cast (total_deaths as int)) as TotalDeath_per_continent
from portfolioproject..CovidDeaths
--where location like '%India%' 
where continent is not null
Group by continent
order by TotalDeath_per_continent desc


--Global Numbers

Select sum(cast(new_cases as numeric)) as total_cases, sum(cast(total_deaths as int))as total_deaths, 
round(Sum(cast(new_deaths as int))/sum(new_cases)*100,2) as DeathPercentage--, date
from portfolioproject..CovidDeaths
where continent is not null
--Group by date
order by 1,2


--Looking at Total Population vs Vaccinations
Select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dae.location order by dae.location, dea.date) as RollingpeopleVaccinated
--, (RollingpeopleVaccinated/population)*100
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac 
	on dae.location = vac.location 
	and dae.date= vac.date
where dae.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingpeopleVaccinated) 
as 
(
Select dae.continent, dae.location, dae.date, dae.population, vac.New_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dae.location order by dae.location, dea.date) as RollingpeopleVaccinated
--, (RollingpeopleVaccinated/population)*100
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac 
	on dae.location = vac.location 
	and dae.date= vac.date
where dae.continent is not null
--order by 2,3
)
Select *, (RollingpeopleVaccinated/population)*100 
from PopvsVac



--TEMP Table

Create Table #PercentPeopleVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)

Insert into #PercentPeopleVaccinated
Select dae.continent, dae.location, dae.date, dae.population, vac.New_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dae.location order by dae.location, dea.date) as RollingpeopleVaccinated
--, (RollingpeopleVaccinated/population)*100
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac 
	on dae.location = vac.location 
	and dae.date= vac.date
where dae.continent is not null
--order by 2,3

Select *, (RollingpeopleVaccinated/population)*100
from #PercentPeopleVaccinated


--Creating View to store data for later Visualizations
Create View PercentPopulationVaccinated as 
Select dae.continent, dae.location, dae.date, dae.population, vac.New_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dae.location order by dae.location, dea.date) as RollingpeopleVaccinated
--, (RollingpeopleVaccinated/population)*100
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac 
	on dae.location = vac.location 
	and dae.date= vac.date
where dae.continent is not null
--order by 2,3


Select *
from PercentPopulationVaccinated