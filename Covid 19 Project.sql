   
-- COVID 19 Data Exploration
-- This data from 1-Jan-2020 to 3-Feb-2022

------------------------------------------------------------------------------------

-- Convert Date Column from datetime to date_only
 

Select *
From PortfolioCovidProject..CovidDeaths

Select Cast(date as Date) as date_only
From PortfolioCovidProject..CovidDeaths

ALTER TABLE PortfolioCovidProject..CovidDeaths
Add date_only Date;

Update PortfolioCovidProject..CovidDeaths
SET date_only = Cast(date as Date)

ALTER TABLE PortfolioCovidProject..CovidDeaths
Drop Column date;

-------------

Select *
From PortfolioCovidProject..CovidVaccinations

Select Cast(date as Date) as date_only
From PortfolioCovidProject..CovidVaccinations

ALTER TABLE PortfolioCovidProject..CovidVaccinations
Add date_only Date;

Update PortfolioCovidProject..CovidVaccinations
SET date_only = Cast(date as Date)

ALTER TABLE PortfolioCovidProject..CovidVaccinations
Drop Column date;

------------------------------------------------------------------------------------

-- Total Cases, Total Deaths VS Population 


Select location, date_only, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioCovidProject..CovidDeaths
where continent is not null
--Where location like 'Egypt'
Order By 1, 2

------------------------------------------------------------------------------------

-- Total Cases VS Population
-- shows what percentage of population got covid


Select location, date_only, population, total_cases, (total_cases/population)*100 as pop_percentage_infected
From PortfolioCovidProject..CovidDeaths
--Where location like '%Saudi%'
Order By 1, 2 

------------------------------------------------------------------------------------

-- Looking at Countries with Highest Infection Rate compared to Population


Select location, population, MAX(total_cases) as highest_infection_count, MAX(total_cases/population)*100 as high_pop_prcnt_infected
From PortfolioCovidProject..CovidDeaths
--Where location like 'Egypt'
Group By location, population
Order By high_pop_prcnt_infected Desc

------------------------------------------------------------------------------------

-- showing Countries with Highest Death count per Population
-- We using not null for determine only countries wihout the continents like world and all those other things


Select location, MAX(CAST(total_deaths as int)) as highest_death_count
From PortfolioCovidProject..CovidDeaths
--Where location like 'Egypt'
Where continent is not null                                                            
Group By location
Order By highest_death_count Desc

------------------------------------------------------------------------------------

-- Total Deaths by Continent


Select continent, MAX(CAST(total_deaths as int)) as highest_death_count
From PortfolioCovidProject..CovidDeaths
--Where location like 'Egypt'
Where continent is not null                                                            
Group By continent
Order By highest_death_count Desc

------------------------------------------------------------------------------------

-- Numbers for The Entire World


Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as deaths_percentage
From PortfolioCovidProject..CovidDeaths
--Where location like 'Egypt'
Where continent is not null 
--Group By date_only
Order By 1, 2

------------------------------------------------------------------------------------

-- Total Population vs Vaccinations
-- Shows Count of Vaccinations that has recieved at least one Covid Vaccine


Select death.continent, death.location, death.date_only, death.population, vac.new_vaccinations
	,SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition By death.location Order By death.location, death.date_only) As CountofVaccinations
From PortfolioCovidProject..CovidDeaths death
Join PortfolioCovidProject..CovidVaccinations vac 
	ON death.location = vac.location 
	AND death.date_only = vac.date_only 
Where death.continent is not null
--And death.location = 'Egypt'
Order By 2,3

---------

-- CTE 
-- (Total Percentage of Vaccinations per Country)


WITH vac_dvd_pop (continent, location, population, New_Vaccinations, CountofVac)
as

(
Select death.continent, death.location, death.population, vac.new_vaccinations
	   ,SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition By death.location Order By death.location, death.date_only) As CountofVac
From PortfolioCovidProject..CovidDeaths death
Join PortfolioCovidProject..CovidVaccinations vac 
	ON death.location = vac.location 
	AND death.date_only = vac.date_only 
Where death.continent is not null
--And death.location = 'Egypt'
)

Select Distinct location, population, New_Vaccinations, CountofVac,  
	   (CountofVac/population)*100 as PercentofVacEachCountry
From vac_dvd_pop
Order by 1

------------------------------------------------------------------------------------

-- Another Way by Creating a Table to Caculation the previous Query


--Drop Table if exists PercentPopVaccinated
Create Table PercentPopulVaccinated (
	continent nvarchar(255),
	location nvarchar(255),
	date_only date,
	population numeric,
	new_vaccinations numeric,
	CountofVac numeric
)

Insert Into PercentPopulVaccinated

Select death.continent, death.location, death.population
	   ,SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition By death.location Order By death.location, death.date_only) As CountofVac
From PortfolioCovidProject..CovidDeaths death
Join PortfolioCovidProject..CovidVaccinations vac 
	ON death.location = vac.location 
	AND death.date_only = vac.date_only 
--Where death.continent is not null
--And death.location = 'Egypt'

Select location, population, CountofVac, 
	   (CountofVac/population)*100 as PercentofVacEachCountry
From PercentPopulVaccinated
Order by 1

------------------------------------------------------------------------------------


-- Perproportion of recipients of the vaccine per Country


Select d.location, d.population, total_vaccinations, people_fully_vaccinated,
         SUM(Cast(people_fully_vaccinated as bigint))/SUM(Cast(population as bigint)) As prop_recipient_vac
From PortfolioCovidProject..CovidDeaths d 
Join PortfolioCovidProject..CovidVaccinations vac
	ON vac.location = d.location
	AND vac.date_only = d.date_only
Where d.continent is not null
Group by d.location, population, total_vaccinations, people_fully_vaccinated
Order by 1


------------------------------------------------------------------------------------

-- Total Vaccination


Select death.continent, death.location, death.date_only, death.population
, MAX(vac.total_vaccinations) as AllVaccination

From PortfolioCovidProject..CovidDeaths death
Join PortfolioCovidProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date_only = vac.date_only
where death.continent is not null 
group by death.continent, death.location, death.date_only, death.population
order by 1,2,3

------------------------------------------------------------------------------------

-- Total Deaths Count for each Continent


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioCovidProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Lower middle income', 'Low income', 'Upper middle income')
Group by location
order by TotalDeathCount desc

------------------------------------------------------------------------------------

