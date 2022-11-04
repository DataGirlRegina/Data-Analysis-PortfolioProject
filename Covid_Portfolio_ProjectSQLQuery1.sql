Select *
From
	PortfolioProject.dbo.CovidDeaths
Where 
	continent is not null 


--Select *
--From
--	PortfolioProject.dbo.CovidVaccinations


-- Select the data that will be used.

Select
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
From
	PortfolioProject.dbo.CovidDeaths
Where 
	continent is not null 


-- Looking at Total Cases vs Total Deaths.
-- Shows the likelihood of dying if you contract covid in your country.

Select
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS Death_Percentage
From
	PortfolioProject.dbo.CovidDeaths
Where 
	location like '%Kenya%'
and continent is not null 




-- Looking at Total cases vs Population.
-- Shows what percentage of the population contracted Covid.

Select
	location,
	date,
	total_cases,
	population,
	(total_cases/population)*100 AS Percentage_of_Population_Infected
From
	PortfolioProject.dbo.CovidDeaths
--Where 
--	location like '%Kenya%'



-- Countries with Highest Infection Rate compared to Population

Select
	Location, 
	Population, 
	MAX(total_cases) as Highest_Infection_Count,  
	Max((total_cases/population))*100 AS Percentage_Population_Infected
From 
	PortfolioProject.dbo.CovidDeaths
--Where 
--	location like '%Kenya%'
Group by
	Location, 
	Population
order by 
	Percentage_Population_Infected desc



-- Countries with Highest Death Count per Population

Select 
	location, 
	MAX(cast(Total_deaths as int)) AS Total_Death_Count
From 
	PortfolioProject.dbo.CovidDeaths
--Where 
--	location like '%Kenya%'
Where 
	continent is not null 
Group by 
	Location
order by 
	Total_Death_Count desc




-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select 
	continent, 
	MAX(cast(Total_deaths as int)) as Total_Death_Count
From PortfolioProject.dbo.CovidDeaths
--Where 
--	location like '%Kenya%'
Where 
	continent is not null 
Group by 
	continent
order by
	Total_Death_Count desc




-- Global numbers

Select 
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
From 
	PortfolioProject.dbo.CovidDeaths
--Where 
--	location like '%Kenya%'
where 
	continent is not null 
--Group By date




-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select *
From 
	PortfolioProject.dbo.CovidDeaths dea
Join
	PortfolioProject.dbo.CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	

Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From 
	PortfolioProject.dbo.CovidDeaths dea
Join 
	PortfolioProject.dbo.CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
where 
	dea.continent is not null 
order by
	2,3




-- Using CTE to perform Calculation on Partition By in previous query

With populationVSvaccination (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
Select 
	dea.continent,
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From 
	PortfolioProject.dbo.CovidDeaths dea
Join 
	PortfolioProject.dbo.CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
where 
	dea.continent is not null 
	--order by 2,3
)
Select 
	*, 
	(Rolling_People_Vaccinated/Population)*100
From 
	populationVSvaccination




-- Using Temp Table to perform Calculation on Partition By in previous query

IF OBJECT_ID('PortfolioProject.dbo.#PercentagePopulationVaccinated') IS NOT NULL
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
    SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location) as Rolling_People_Vaccinated
--, (RollingPeopleVaccinated/population)*100
From 
	PortfolioProject.dbo.CovidDeaths dea
Join 
	PortfolioProject.dbo.CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
--where 
	--dea.continent is not null 
--order by 
	--2,3
Select
	*,
	(Rolling_People_Vaccinated/Population)*100
From 
	#PercentagePopulationVaccinated


USE PortfolioProject

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated 
AS
Select
	dea.continent,	
	dea.location, 
	dea.date, 
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location) as Rolling_People_Vaccinated
--, (RollingPeopleVaccinated/population)*100
From 
	PortfolioProject..CovidDeaths dea
Join 
	PortfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
where 
	dea.continent is not null 
	