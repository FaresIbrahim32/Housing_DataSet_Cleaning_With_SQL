--expoloration of data columns and order by country and date
SELECT country,date,total_cases,new_cases,total_deaths,population
FROM covid_deaths
ORDER BY 1,2;

--looking at total cases vs total deaths 
SELECT 
    country,
    date,
    total_cases,
    total_deaths, 
    ROUND((total_deaths::NUMERIC / total_cases) * 100, 3) AS death_percentage
FROM covid_deaths
WHERE total_cases > 0 and country like '%States%';

--looking at total cases vs population
SELECT 
    country,
    date,
	population,
    total_cases,
    total_deaths, 
    ROUND((total_cases::NUMERIC / population) * 100, 3) AS infection_percentage
FROM covid_deaths
WHERE total_cases > 0 and country like '%Egypt%'
ORDER BY infection_percentage DESC;

--looking at max infection rate recorded
SELECT 
    country,
    date,
	population,
    total_cases,
    total_deaths, 
    ROUND((total_cases::NUMERIC / population) * 100, 3) AS infection_percentage
FROM covid_deaths
WHERE total_cases > 0 and country like '%Egypt%'
ORDER BY infection_percentage DESC
LIMIT 1;

--looking at countires with highest infection rate vs population
SELECT 
    country,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    ROUND(MAX((total_cases::NUMERIC / population)) * 100, 3) AS infection_percentage
FROM covid_deaths
WHERE total_cases > 0
GROUP BY country, population
ORDER BY infection_percentage DESC;

--showng countries with highest death count per population 
SELECT 
    country,
    population,
    MAX(total_deaths) AS HighestDeathCount,
    ROUND(MAX((total_deaths::NUMERIC / population)) * 100, 3) AS death_percentage
FROM covid_deaths
WHERE total_deaths IS NOT NULL and population IS NOT NULL
GROUP BY country, population
ORDER BY death_percentage DESC;

--BREAK THINgs down by continent 
SELECT 
    v.continent,
    MAX(d.total_deaths) AS HighestDeathCount
FROM covid_deaths d
JOIN covid_vaccinations v 
    ON d.country = v.country 
    AND d.date = v.date
WHERE d.total_deaths IS NOT NULL 
  AND v.continent IS NOT NULL
GROUP BY v.continent
ORDER BY HighestDeathCount DESC;

--Global Numbers
SELECT 
    v.continent,SUM(d.new_deaths) new_total_deaths,SUM(new_cases) new_total_cases,SUM((new_deaths::NUMERIC))/SUM(new_Cases)*100 as DeathPercentage
FROM covid_deaths d
JOIN covid_vaccinations v 
    ON d.country = v.country 
    AND d.date = v.date
WHERE d.total_deaths IS NOT NULL 
  AND v.continent IS NOT NULL
GROUP BY v.continent
order by 1,2;

--VACCINATION vs POPULATION vaccinated per day
SELECT v.continent,v.country,v.date,d.population,v.new_vaccinations, SUM(v.new_vaccinations) OVER (Partition by v.country ORDER BY v.country , v.date) as RollingPeopleVaccinated---(RollingPeopleVaccinated)/(d.population)*100
FROM covid_deaths d
JOIN  covid_vaccinations v
ON d.country  = v.country
AND d.date = v.date
WHERE new_vaccinations IS NOT NULL and continent IS NOT NULL;

--USE CTE 
WITH PopvsVac (continent,country,date,new_vaccinations,population,RollingPeopleVaccinated)
as
(
SELECT v.continent,
        v.country,
        v.date,
        v.new_vaccinations,
        d.population,
        SUM(v.new_vaccinations) OVER (
            PARTITION BY v.country 
            ORDER BY v.date
        ) AS RollingPeopleVaccinated
FROM covid_deaths d
JOIN  covid_vaccinations v
ON d.country  = v.country
AND d.date = v.date
WHERE v.new_vaccinations IS NOT NULL and v.continent IS NOT NULL
)
SELECT *,(RollingPeopleVaccinated) / 100 as VaccinationPercentagePerDay
FROM PopvsVac;


-- Drop if exists (uncomment if needed)
--DROP TABLE IF EXISTS PercentPopulationVaccinated;

-- Create temp table
CREATE TEMP TABLE PercentPopulationVaccinated AS
SELECT
    v.continent,
    v.country AS location,
    v.date,
    d.population,
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (
        PARTITION BY v.country
        ORDER BY v.date
    ) AS RollingPeopleVaccinated
FROM covid_deaths d
JOIN covid_vaccinations v
    ON d.country = v.country
   AND d.date = v.date
WHERE v.new_vaccinations IS NOT NULL
  AND v.continent IS NOT NULL
  AND d.population IS NOT NULL
  AND d.population > 0;

-- Calculate percentage
SELECT
    *,
    (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated;

SELECT * FROM PercentPopulationVaccinated LIMIT 5;


Create View PercentPopulationVaccinated as
SELECT v.continent,
        v.country,
        v.date,
        v.new_vaccinations,
        d.population,
        SUM(v.new_vaccinations) OVER (
            PARTITION BY v.country 
            ORDER BY v.date
        ) AS RollingPeopleVaccinated
FROM covid_deaths d
JOIN  covid_vaccinations v
ON d.country  = v.country
AND d.date = v.date
WHERE v.new_vaccinations IS NOT NULL and v.continent IS NOT NULL and v.continent is not null 











