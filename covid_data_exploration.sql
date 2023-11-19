/*
Covid Data Exploration
Skills Used: Joins, CTE's, Aggregate Functions
*/


SELECT *
FROM covid_db.dbo.covid_deaths
ORDER BY location
	, date;

SELECT *
FROM covid_db.dbo.covid_vaccinations
ORDER BY location
	, date;


-- Population Infection Rate in UK by Date
SELECT location
	, date
	, total_cases
	, population
	, ROUND((total_cases / population) * 100, 2) AS infection_rate
FROM covid_db.dbo.covid_deaths
WHERE continent IS NOT NULL
	AND location = 'United Kingdom'
ORDER BY location
	, date;


-- Infected Death Rate in UK by Date
SELECT location
	, date
	, total_cases
	, total_deaths
	, ROUND((total_deaths / total_cases) * 100, 2) AS death_rate
FROM covid_db.dbo.covid_deaths
WHERE continent IS NOT NULL
	AND location = 'United Kingdom'
ORDER BY location
	, date;


-- Countries With Highest Infection Rate
SELECT location
	, population
	, MAX(total_cases) AS infected_count
	, ROUND(MAX((total_cases / population) * 100), 2) AS infection_rate
FROM covid_db.dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
	, population
ORDER BY infection_rate DESC;


-- Countries With Highest Death Rate by Cases Using CTE
WITH country_death_rates (location, total_deaths, total_cases) AS
(
SELECT location
	, MAX(total_deaths)
	, MAX(total_cases)
FROM covid_db.dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
)
SELECT *
	, (total_deaths / total_cases) * 100 AS death_rate
FROM country_death_rates
ORDER BY death_rate DESC;


-- Continents With Highest Death Count 
SELECT continent
	, MAX(total_deaths) AS total_deaths
FROM covid_db.dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deaths DESC;


-- Global Death Rate of Infected
SELECT SUM(new_cases) AS global_cases
	, SUM(new_deaths) AS global_deaths
	, ROUND((SUM(new_deaths) / SUM(new_cases) * 100), 2) AS death_rate
FROM covid_db.dbo.covid_deaths
WHERE continent IS NOT NULL;


-- Joining Both Tables
SELECT *
FROM covid_db.dbo.covid_deaths cd
JOIN covid_db.dbo.covid_vaccinations cv
	ON cd.location = cv.location
		AND cd.date = cv.date


-- Global Population Vaccination Count Using CTE
WITH population_vaccinations (continent, location, date, population, new_vaccinations, vaccinations_count) AS
(
SELECT cd.continent
	, cd.location
	, cd.date
	, population
	, cv.new_vaccinations
	, SUM(cv.new_vaccinations) OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS vaccinations_count -- What to do if the table did not already have a total_vaccinations column
FROM covid_db.dbo.covid_deaths cd
JOIN covid_db.dbo.covid_vaccinations cv
	ON cd.location = cv.location
		AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *
	, (vaccinations_count / population) * 100 AS vaccinations_percentage
FROM population_vaccinations
ORDER BY location
	, date;
