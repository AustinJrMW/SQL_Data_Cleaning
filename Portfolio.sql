SELECT *
FROM Portfolio_Project..CovidDeaths

-- COVID DEATHS

SELECT *
FROM Portfolio_Project..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM Portfolio_Project..CovidVaccinations
--order by 3,4

-- Selecting Data to be used

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2


-- Identifying the Total cases against Total deaths
-- Clarifies how possiblle it is to die if you contract covid in different countries

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

-- Malawi COVID Death Percentage
-- Clarifies how possiblle it is to die if you contract covid in Malawi

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From Portfolio_Project..CovidDeaths
where location like '%malawi%' and continent is not null
order by 1,2

-- Identifying Total cases against the population
-- Shows the percentage of population that contracted covid

Select location, date, total_cases, population, (total_cases/population)*100 as Contraction_Percentage
From Portfolio_Project..CovidDeaths
where location like '%malawi%' and continent is not null
order by 1,2

-- Identifying Infection Rates across Countries

Select location, population, MAX(total_cases) as Highest_Infection_Count, (MAX(total_cases)/population)*100 as Infection_Percentage
From Portfolio_Project..CovidDeaths
where continent is not null
Group by population, location
order by Infection_Percentage desc;

-- Identifying Death Count against population
Select location, MAX(cast(total_deaths as int)) as Highest_Death_Count
From Portfolio_Project..CovidDeaths
where continent is not null
Group by location
order by Highest_Death_Count desc;

-- Identifying Death Count across continents

Select location, MAX(cast(total_deaths as int)) as Highest_Death_Count
From Portfolio_Project..CovidDeaths
where continent is null
Group by location
order by Highest_Death_Count desc;


-- Breaking down COVID Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From Portfolio_Project..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- World Death Percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From Portfolio_Project..CovidDeaths
where continent is not null
-- Group by date
order by 1,2

-- COVID VACCINATIONS

Select *
From Portfolio_Project..CovidVaccinations

-- Combined COVID Data

Select *
From Portfolio_Project..CovidVaccinations vac
Join Portfolio_Project..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date

-- Identifying Percentage of the population vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition  by dea.location order by dea.location, dea.Date) as Rolling_People_Vaccinated
From Portfolio_Project..CovidVaccinations vac
Join Portfolio_Project..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Creating a CTE for Rolling_People Vaccinated

With PopvsVac (Continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition  by dea.location order by dea.location, dea.Date) as Rolling_People_Vaccinated
From Portfolio_Project..CovidVaccinations vac
Join Portfolio_Project..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (Rolling_People_Vaccinated/population)*100
From PopvsVac

-- Alternative: Creating Temp Table for Rolling_People_Vaccinated

DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition  by dea.location order by dea.location, dea.Date) as Rolling_People_Vaccinated
From Portfolio_Project..CovidVaccinations vac
Join Portfolio_Project..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (Rolling_People_Vaccinated/population)*100
From #PercentagePopulationVaccinated

-- Creating View to store data for later use

USE PortfolioProject
GO
Create View PercentSmokersVaccinated as 
Select dea.continent, dea.location, dea.date, (vac.female_smokers+vac.male_smokers) as smoker_population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition  by dea.location order by dea.location, dea.Date) as Rolling_Smokers_Vaccinated
From Portfolio_Project..CovidVaccinations vac
Join Portfolio_Project..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

-- Creating view for Rolling_People_Vaccinated

USE PortfolioProject
GO
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition  by dea.location order by dea.location, dea.Date) as Rolling_People_Vaccinated
From Portfolio_Project..CovidVaccinations vac
Join Portfolio_Project..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null