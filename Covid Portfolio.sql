Select *
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4
Select *
From PortfolioProject..CovidVaccinations$
order by 3,4
--Select Data that we are going to be using
Select Location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- looking as Total Cases vs total Deaths
--shows likelihood of dying if you contract covid in your country
Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
where continent is not null
order by 1,2
--Looking at Total Cases vs Population
--shows what percentage of population got Covid
Select Location,date,Population,total_cases,total_deaths,(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
Where location like '%states%'
where continent is not null
order by 1,2

--Countires with highest infection rate compared to Population

Select Location,Population, Max(total_cases) as HighestInfectionCount,Max(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
where continent is not null
Group by Location,Population
order by PercentagePopulationInfected desc

--highest countries with highest death count per population

Select Location, Max(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by Location
order by TotalDeathCount desc
 
 --Let's break it down by continent
 
--Showing continent with the highest death count per population
Select continent, Max(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc

-- cast= convert(int,new_deaths)
--Global numbers

Select Sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum (cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100 
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location =vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3



--Using CTE-Common Table Expression
With PopvsVac(Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum (cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100 
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location =vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100 
from PopvsVac

--Temp Table

Drop Table if exists #PercentPopulatonVaccinated

Create Table #PercentPopulatonVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
new_vaccinations  numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulatonVaccinated
Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum (cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100 
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location =vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population)*100 as percentpopvac
from #PercentPopulatonVaccinated


--creating View to store data forlater visualization

Create View PercentPopulatonVaccin as
Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum (cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100 
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location =vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3