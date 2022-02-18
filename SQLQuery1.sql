Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4
	


--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


--Looking at Total Cases vs Total Deaths
--Show likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of the population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as Percent_Population_Infected
From PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2

Select Location, date, total_cases, population, (total_cases/population)*100 as  Percent_Population_Infected
From PortfolioProject..CovidDeaths
Where location like '%Taiwan%' and continent is not null


-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as Highest_Infection_Count, population, Max((total_cases/population))*100 as  Percent_Population_Infected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, population 
Order by Percent_Population_Infected DESC

-- Showing Countries with the Higest Death Count Per Population

Select Location, Max(cast(total_deaths as int)) as Total_Deaths_Count
From PortfolioProject..CovidDeaths
Where continent is not null --(To avoid the countries which are continent)
Group by Location
Order by Total_Deaths_Count DESC


-- Let's Break Things Down by Continent


--Showing continents with the highest death count per population
Select continent, Max(cast(total_deaths as int)) as Total_Deaths_Count
From PortfolioProject..CovidDeaths
Where continent is not null --(To avoid the countries which are continent)
Group by continent
Order by Total_Deaths_Count DESC


--(The numbers below is more accurate, let's make queries to let the upper one more accurate)
--(eq. the upper one didn't include Canada in North America, and there're lots more not included in continent) 
--Select location, Max(cast(total_deaths as int)) as Total_Deaths_Count
--From PortfolioProject..CovidDeaths
--Where continent is null --(To avoid the countries which are continent)
--Group by location
--Order by Total_Deaths_Count DESC

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths,SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths,SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2


--Join 2 datasets


Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Adding up Numbers at the end of new_vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as float)) OVER(Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100(to use this, use CTE to do this (below))

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3



---USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as float)) OVER(Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, ((RollingPeopleVaccinated/population)*100)
From PopvsVac


-- TEMP TABLE
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as float)) OVER(Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, ((RollingPeopleVaccinated/population)*100)
From #PercentPopulationVaccinated



--Drop Table if exists
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as float)) OVER(Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, ((RollingPeopleVaccinated/population)*100)
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as float)) OVER(Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated