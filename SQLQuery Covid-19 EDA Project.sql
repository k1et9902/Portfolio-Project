/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/




SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4 ;


--SELECT *
--FROM covidvaccinations
--ORDER BY 3,4

-- Select data that i am going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases VS Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'Vietnam'
ORDER BY 1,2


-- Looking at Total Cases VS Population
-- Show what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectedPercentage
FROM CovidDeaths
--WHERE location = 'Vietnam'
ORDER BY 1,2


-- Looking at country that has the highest Infected rate

SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS InfectedPercentage
FROM CovidDeaths
GROUP BY location, population
ORDER BY InfectedPercentage DESC


-- Showing country with highest death compared to population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathsCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathsCount DESC


-- BREAK DOWN BY CONTINENT
-- Showing continent with the highest death count

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBER

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Total Popolation VS Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
-- (RollingVaccinated/population)*100
FROM CovidDeaths dea
LEFT JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE to calculated RollingVaccinated/Population

WITH VacVSPop (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
-- (RollingVaccinated/population)*100
FROM CovidDeaths dea
LEFT JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingVaccinated/population)*100 AS VaccinatedPercentage
FROM VacVSPop


-- Using temp table to calculated RollingVaccinated/Population

DROP TABLE IF EXISTS #VacVSPop
CREATE TABLE #VacVSPop
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinated numeric
)

INSERT INTO #VacVSPop
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
-- (RollingVaccinated/population)*100
FROM CovidDeaths dea
LEFT JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingVaccinated/population)*100 AS VaccinatedPercentage
FROM #VacVSPop


-- Creating view to store for later visualizations

CREATE VIEW VaccinatedPercentage AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
-- (RollingVaccinated/population)*100
FROM CovidDeaths dea
LEFT JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3












