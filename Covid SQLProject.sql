
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
SELECT
    dae.continent,
    dae.location,
    dae.date,
    dae.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dae.location ORDER BY dae.location, dae.date) AS RollingpeopleVaccinated,
    (SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dae.location ORDER BY dae.location, dae.date) / dae.population) * 100 AS VaccinationPercentage
FROM
    portfolioproject..CovidDeaths dae
JOIN
    portfolioproject..CovidVaccinations vac ON dae.location = vac.location AND dae.date = vac.date
WHERE
    dae.continent IS NOT NULL
ORDER BY
    dae.location, dae.date;



--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingpeopleVaccinated) AS
(
    SELECT
        dae.continent,
        dae.location,
        dae.date,
        dae.population,
        vac.New_vaccinations,
        SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dae.location ORDER BY dae.location, dae.date) AS RollingpeopleVaccinated
    FROM
        portfolioproject..CovidDeaths dae
    JOIN
        portfolioproject..CovidVaccinations vac ON dae.location = vac.location AND dae.date = vac.date
    WHERE
        dae.continent IS NOT NULL
)
SELECT
    *,
    (RollingpeopleVaccinated / NULLIF(Population, 0)) * 100 AS VaccinationPercentage
FROM
    PopvsVac;



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
-- Create a temporary table to hold the data
CREATE TABLE #PercentPeopleVaccinated (
    Continent NVARCHAR(MAX),
    Location NVARCHAR(MAX),
    Date DATE,
    Population INT,
    New_vaccinations INT,
    RollingpeopleVaccinated INT
);

-- Insert data into the temporary table
INSERT INTO #PercentPeopleVaccinated (Continent, Location, Date, Population, New_vaccinations, RollingpeopleVaccinated)
SELECT
    dae.continent,
    dae.location,
    dae.date,
    dae.population,
    vac.New_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dae.location ORDER BY dae.location, dae.date) AS RollingpeopleVaccinated
FROM
    portfolioproject..CovidDeaths dae
JOIN
    portfolioproject..CovidVaccinations vac ON dae.location = vac.location AND dae.date = vac.date
WHERE
    dae.continent IS NOT NULL;

-- Select data from the temporary table with vaccination percentage calculation
SELECT
    *,
    CASE
        WHEN Population = 0 THEN NULL  -- Avoid division by zero error
        ELSE (RollingpeopleVaccinated * 1.0 / Population) * 100
    END AS VaccinationPercentage
FROM
    #PercentPeopleVaccinated;

-- Drop the temporary table
DROP TABLE #PercentPeopleVaccinated;



--Creating View to store data for later Visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT
    dae.continent,
    dae.location,
    dae.date,
    dae.population,
    vac.New_vaccinations,
    SUM(CAST(vac.New_vaccinations AS INT)) OVER (PARTITION BY dae.location ORDER BY dae.location, dae.date) AS RollingpeopleVaccinated,
    CASE
        WHEN dae.population = 0 THEN NULL
        ELSE (SUM(CAST(vac.New_vaccinations AS INT)) OVER (PARTITION BY dae.location ORDER BY dae.location, dae.date) * 1.0 / dae.population) * 100
    END AS VaccinationPercentage
FROM
    portfolioproject..CovidDeaths dae
JOIN
    portfolioproject..CovidVaccinations vac ON dae.location = vac.location AND dae.date = vac.date
WHERE
    dae.continent IS NOT NULL;

-- Now, to retrieve data from the view
SELECT *
FROM PercentPopulationVaccinated;
