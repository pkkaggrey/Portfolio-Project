--Tables to work with
Select *
From Covid_Deaths

Select *
From Covid_Vaccinations

--Exploring Covid_Deaths Table
--Total Deaths vs Total Cases
Select Location, date, total_deaths, total_cases, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercent
From Covid_Deaths
--Where location = 'Ghana'
Where continent is not null
Order By 1,2

--Total Cases vs Population
Select Location, date, Population, total_cases, (cast(total_cases as float)/cast(Population as float))*100 as PercentPoulationInfected
From Covid_Deaths
Where location = 'Ghana'
Order By 1,2

--Countries with highest infection rate
Select Location, Population, Max(cast(total_cases as int)) as HighestInfectionCount, Max((cast(total_cases as float)/cast(Population as float)))*100 as PercentPopulationInfected
From Covid_Deaths
--Where location = 'Ghana'
Where continent is not null
Group by Location, Population
Order By PercentPopulationInfected desc

--Countries with Highest Death Count per Population
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From Covid_Deaths
--Where location = 'Ghana'
Where continent is not null
Group by Location
Order By TotalDeathCount desc

--continents with highest death count
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From Covid_Deaths
--Where location = 'Ghana'
Where continent is null
Group by location
Order By TotalDeathCount desc

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From Covid_Deaths
--Where location = 'Ghana'
Where continent is not null
Group by continent
Order By TotalDeathCount desc

--Global numbers
Select sum(new_deaths) as TotalDeaths, sum(new_cases) as TotalCases, sum(new_deaths)/sum(new_cases)*100 as DeathPercent
From Covid_Deaths
--Where location = 'Ghana'
Where continent is not null
--group by date
Order By 1,2

--Total Population vs Vaccination (With a new way to cast, CONVERT)
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(FLOAT, vac.new_vaccinations)) over (partition by dea.location Order By 
dea.location, dea.date) as CumulativePeopleVaccinated
From Covid_Deaths as dea
	Join Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--Using a CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumulativePeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(FLOAT, vac.new_vaccinations)) over (partition by dea.location Order By 
dea.location, dea.date) as CumulativePeopleVaccinated
From Covid_Deaths as dea
	Join Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (CumulativePeopleVaccinated/Population)*100
From PopvsVac


--Using a Temp Table Instead
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CumulaivePeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(FLOAT, vac.new_vaccinations)) over (partition by dea.location Order By 
dea.location, dea.date) as CumulativePeopleVaccinated
From Covid_Deaths as dea
	Join Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, CumulaivePeopleVaccinated/Population*100
From #PercentPopulationVaccinated

--Creating views for later visualization
create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(FLOAT, vac.new_vaccinations)) over (partition by dea.location Order By 
dea.location, dea.date) as CumulativePeopleVaccinated
From Covid_Deaths as dea
	Join Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated
