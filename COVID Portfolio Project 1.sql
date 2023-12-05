--SELECT DATA TO USE

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
ORDER BY 1,2

--TOTAL COVID CASES VS DEATHS
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_ratio
FROM dbo.CovidDeaths
ORDER BY 1,2 Desc

--TOTAL COVID CASES VS DEATHS IN PERU LAST DATE

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_ratio
FROM dbo.CovidDeaths
WHERE Location like 'Peru'
ORDER BY 2 Desc

--TOTAL COVID CASES VS POPULATION

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS Infection_ratio
FROM dbo.CovidDeaths
WHERE Location like 'Peru'
ORDER BY 1,2 desc

--COUNTRIES WITH HIGHEST INFECTION RATIO 

SELECT Location, population, MAX(total_cases) as HighestInfection_intime, (MAX(total_cases)/population)*100 AS Infection_ratio
FROM dbo.CovidDeaths
GROUP BY Location, population
ORDER BY Infection_ratio DESC

--COUNTRIES WITH HIGHEST TOTAL DEATH

SELECT Location, population, MAX(cast(total_deaths as int)) as Deaths, (MAX(cast(total_deaths as int))/population)*100 AS Death_Ratio
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location, population
ORDER BY Deaths DESC

--CONTINENTS WITH HIGHEST TOTAL DEATH

SELECT Location, population, MAX(cast(total_deaths as int)) as Deaths, (MAX(cast(total_deaths as int))/population)*100 AS Death_Ratio
FROM dbo.CovidDeaths
WHERE continent is null
GROUP BY Location, population
ORDER BY Deaths DESC

--DAY TO DAY CHANGES

SELECT date, SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths as int)) AS Total_death, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS Death_Ratio
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--TOTAL POPULATION VS VACCINATION

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
FROM dbo.CovidDeaths dea JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--AGGREGATED VACCINATION

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int))
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Aggregated_Vaccination
FROM dbo.CovidDeaths dea JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null AND dea.location like 'Canada'
ORDER BY 2,3

--TOTAL PEOPLE VACCINATED - CTE

With PopvsVac (continent, location, date, population, new_vaccinations, Aggregated_Vaccination) AS
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int))
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Aggregated_Vaccination
FROM dbo.CovidDeaths dea JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null AND dea.location like 'Canada'
)
Select *, (Aggregated_Vaccination/Population)*100 AS Vaccination_Ratio
From PopvsVac
