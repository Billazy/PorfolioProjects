

Select * 
From PortfolioProject..CovidDeaths
Where continent is not Null
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccination
--Order By 3,4

-- Select Data that we're going to be using

Select Location, date,total_cases, new_cases,total_deaths,population
From CovidDeaths
Where continent is not Null
Order By 1,2


/**********************************************************************************************/

--Comment trouver le type de DataBase
exec sp_help 'dbo.CovidDeaths';

--Changement du type de donnee
ALTER TABLE dbo.CovidDeaths
Alter Column total_cases float

ALTER TABLE dbo.CovidDeaths
Alter Column total_deaths float

/***********************************************************************************************/


-- Looking at Total Cases VS Total Deaths
--Show Likelihood of dying if you contract covid in your country
Select Location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From CovidDeaths
--Filtre par Pays
Where location Like '%State%'
And continent is not Null
Order By 1,2


--Looking at total cases Vs Population
--Shows What percentage of pop got covid
Select Location, date,population, total_cases,(total_cases/population)*100 As GotPercentageInfected
From CovidDeaths
--Filtre par Pays
--Where location Like '%State%'
Order By 1,2


--Looking at Countries with Highest Infection Rate Compared to Population
Select Location,population,MAX(total_cases) As HighestInfect,Max((total_cases/population))*100 As PercentageOfPopInfected
From CovidDeaths
/*Column 'CovidDeaths.location' is invalid in the select list because it is not contained 
in either an aggregate function or the GROUP BY clause. */
Group By Location, population
--Order By 1,2
Order by PercentageOfPopInfected desc


-- Shwoing Countries  with Highest Death Count Per Population

Select Location, Max(Cast(total_deaths As int)) As TotalDeathCount
From CovidDeaths
Where continent is not Null
Group by Location
Order By TotalDeathCount desc

--exec sp_help 'CovidDeaths'  ; Cast Permet la modification  locale

-- Let Break Things Down By Continent


--Showing continent with the highest death count per population 

Select continent, Max(Cast(total_deaths As int)) As TotalDeathCount
From CovidDeaths
Where continent is not Null
Group by continent
Order By TotalDeathCount desc


-- By Location
Select location, Max(Cast(total_deaths As int)) As TotalDeathCount
From CovidDeaths
Where continent is Null
Group by location
Order By TotalDeathCount desc


-- Global Numbers

Select date,Sum(new_cases) As Total_Cases,Sum(new_deaths)As Total_Deaths,Sum(new_deaths)/nullif(Sum(new_cases),0)*100 As DeathPercentage
From CovidDeaths
--Filtre par Pays
--Where location Like '%State%' And continent is not Null
where continent is not null
Group by date
Order By 1,2

--Total Cases : 774758253
Select Sum(new_cases) As Total_Cases,Sum(new_deaths)As Total_Deaths,Sum(new_deaths)/nullif(Sum(new_cases),0)*100 As DeathPercentage
From CovidDeaths
--Filtre par Pays
--Where location Like '%State%' And continent is not Null
where continent is not null
Order By 1,2

/******************************  CovidVaccinantion     ********************************************************************************/

-- Looking at Total population vs total vaccination 
Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location Order by dea.location, 
dea.date) As RollingPeopleVaccinated
from Covid_Vaccinations vac
Join CovidDeaths dea
On dea.location = vac.location
and dea.date= vac.date
where dea.continent is not NULL
Order by 2,3


-- Use CTE
With PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location Order by dea.location, 
dea.date) As RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from Covid_Vaccinations vac
Join CovidDeaths dea
On dea.location = vac.location
and dea.date= vac.date
where dea.continent is not NULL
--Order by 2,3
)

Select* ,(RollingPeopleVaccinated/population)*100
From PopvsVac



-- Temp Table

DROP TABLE if exists PercentagePopVaccinated
Create table #PercentagePopVaccinated
( 
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopVaccinated
Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location Order by dea.location, 
dea.date) As RollingPeopleVaccinated
from Covid_Vaccinations vac
Join CovidDeaths dea
On dea.location = vac.location
and dea.date= vac.date
where dea.continent is not NULL
--Order by 2,3
Select* ,(RollingPeopleVaccinated/population)*100
From #PercentagePopVaccinated


--Createing View to store data for later visualizations

Create View PercentagePopVaccinated As
Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location Order by dea.location, 
dea.date) As RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from Covid_Vaccinations vac
Join CovidDeaths dea
On dea.location = vac.location
and dea.date= vac.date
where dea.continent is not NULL

Select*
From  PercentagePopVaccinated