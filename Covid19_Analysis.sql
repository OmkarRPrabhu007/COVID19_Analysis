Select * from "CovidDeaths" ; 
Select * from "CovidVaccinations" ; 

-- Datewise Likelihood dying due to Covid : TotalCases VS Total Deaths in India 
Select iso_code , total_cases , total_deaths from "CovidDeaths" where iso_code = 'IND' ; 
Select Max(total_cases) from "CovidDeaths" as Total_Cases_In_India ; 
Select Max(total_deaths) from "CovidDeaths" as Total_Deaths_In_India ; 
Select Max(total_cases)/Max(total_deaths) from "CovidDeaths" as Total_Cases_VS_Toof entire tal_Deaths ; 

-- Total % of deaths out of entire population in India 
Select iso_code , total_cases , total_deaths from "CovidDeaths" ; 
Select sum(total_deaths) from "CovidDeaths" ; 
Select sum(total_deaths ) from "CovidDeaths" where iso_code = 'IND' ;  
Select sum(total_deaths) * 100.0 / (Select sum(total_deaths) from "CovidDeaths")
from "CovidDeaths"
where iso_code = 'IND';

-- Top 100 Countries with the highest death as a % of population 
Select iso_code , total_deaths , population from "CovidDeaths" ;
With DeathPercentage as(  
	Select iso_code , sum(total_deaths) * 100.0 / (Select max(cast (population as numeric)) from "CovidDeaths") as death_percentage
	From "CovidDeaths"
	Group by iso_code
)
Select iso_code , death_percentage from DeathPercentage
where death_percentage is not null 
order by death_percentage desc
limit 100; 

-- Total % +ve cases in India 
Select max(total_cases)*100.0/avg(cast(population as bigint)) from "CovidDeaths" where location like '%India%'

-- Total % +ve cases in the world  
With DeathPercentage as (
    Select 
        iso_code, 
        max(total_cases) as Max_Country_Total_Cases, 
        Avg(cast(population as bigint)) as Avg_Country_Population from "CovidDeaths" Group by iso_code
)
Select sum(Max_Country_Total_Cases) * 100.0 / sum(Avg_Country_Population) as Percentage from DeathPercentage;

-- Continent wise +ve Cases 
Select continent , max(total_cases) as continentwise_Total_Cases from "CovidDeaths" group by continent ; 

-- Continent wise deaths  
Select continent , sum(total_deaths) as Continentwise_deaths from "CovidDeaths" group by continent ; 

-- Daily New Cases VS Hospitalisations VS ICU Patients - in India
Select location , date , new_cases , hosp_patients , icu_patients from "CovidDeaths" where iso_code = 'IND';

-- Countrywise age > 65 
Select CD.date, CD.location, CV.aged_65_older 
From "CovidDeaths" CD 
Join "CovidVaccinations" CV 
on CD.iso_code = CV.iso_code and CD.date = CV.date;

-- Countrywise total vaccinated peoples 
Select CD.location as Country, max(CV.people_vaccinated) as Vaccinated  
From "CovidDeaths" as CD 
Join "CovidVaccinations" as CV 
on CD.iso_code = CV.iso_code and CD.date = CV.date
where CD.continent is not null 
group by Country
order by Vaccinated desc;
 

-- Covid Deaths Data Analysis 
-- 1. Trend Analysis : What is the trend of total cases and total deaths over time in each continent? 

Select  
    date,
    continent,
    total_cases , 
    total_deaths
From 
    "CovidDeaths"
Where
    continent is not null
Order by 
    continent , date asc;

-- 2. Mortality Rate Calculation: What is the average mortality rate (total deaths/total cases) for each country and how has it changed over time?
Select date , location , (total_deaths*100.0/total_cases) as Mortality_rate 
From "CovidDeaths"
Order by location , date asc ; 

-- 3. Death Rate per Million: Which countries have the highest and lowest death rates per million population?
Select location , (sum(total_deaths)*1000000.0)/(max(cast(population as numeric))) as Death_rate_per_miilion 
From "CovidDeaths"  
where total_deaths is not null 
Group By location
Order By Death_rate_per_miilion desc ; 

-- 4. Correlation with ICU Patients: How does the number of ICU patients correlate with the number of deaths in different countries?
Select location , sum(icu_patients)  , sum(total_deaths) 
From "CovidDeaths" 
Group By location 
Order By location desc; 

-- 5. Hospitalization Impact: Analyze the impact of hospitalizations on death rates in different continents.
