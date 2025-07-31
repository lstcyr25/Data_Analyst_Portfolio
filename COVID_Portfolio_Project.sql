/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM CovidDeaths
WHERE continent is not null
Order BY 3,4

-- Select data that we are going to be starting with

SELECT Location, date, total_cases,new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
ORDER By 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS "DeathPercentage"
FROM CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of the population infected with Covid

SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS "PercentPopulationInfected"
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- Countries with the Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS "HighestInfectionCount", MAX((total_cases/population))*100 AS "PercentPopulationInfected"
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


-- Countries with the Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) AS "TotalDeathCount"
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc



-- LET's BREAK THINGS DOWN BY CONTINENT

-- Showing continents with highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) AS "TotalDeathCount"
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS "Total_Cases", SUM(cast(new_deaths as int)) AS "Total_Deaths",SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS "DeathPercentage"
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS "RollingPeopleVaccinated"
--, (RollingPeopleVaccinated/Population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
ORDER By 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVC (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS "RollingPeopleVaccinated"
--, (RollingPeopleVaccinated/Population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--ORDER By 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVC
ORDER BY 2,3



-- Using Temp Table to Perform Calculation on Partition By in Previous Query

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS "RollingPeopleVaccinated"
--, (RollingPeopleVaccinated/Population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--ORDER By 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated




-- Creating View to store data later for future visualization

DROP View if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS "RollingPeopleVaccinated"
--, (RollingPeopleVaccinated/Population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--ORDER By 2,3

SELECT * 
FROM PercentPopulationVaccinated
ORDER BY 2,3




