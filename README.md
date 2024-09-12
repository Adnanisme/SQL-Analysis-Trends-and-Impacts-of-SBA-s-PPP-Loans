# PPP Loan Insights: SQL Analysis of SBA COVID-19 Relief

<p align="center">
  <img src="https://github.com/user-attachments/assets/6a7ef087-78b1-474a-8bcf-441be17bd320" alt="PPP Loan Insights">
</p>


## Introduction

This report delves into a thorough analysis of the U.S. Small Business Administration's (SBA) Paycheck Protection Program (PPP) loans data. The PPP was a pivotal element of the COVID-19 relief efforts, aimed at supporting small businesses in retaining their employees amidst the economic upheaval caused by the pandemic. Through this analysis, we uncover detailed insights into the allocation and effects of these loans, examining how they varied across industries, lenders, time periods, and geographic regions. The findings presented here offer a nuanced understanding of the program’s reach and effectiveness, shedding light on its role in stabilizing the small business sector during a time of crisis.

**Project Author:** [Jibrin Tijjani Isiaka](https://github.com/Adnanisme)

## Objectives

- Summarize and analyze the overall PPP loan approvals and amounts
- Identify and compare top originating lenders and their loan distributions across years
- Analyze the distribution of loans across different industries and their year-over-year changes
- Compare loan approvals and amounts between 2020 and 2021, examining the shifting patterns
- Examine the loan forgiveness rates and their implications
- Investigate monthly loan approval trends and their correlation with pandemic milestones

## Skills Utilized

- SQL
- Data Cleaning
- Data Transformation
- Data Analysis


## Dataset

The dataset used for this analysis comes from the U.S. Small Business Administration and includes the following main components:

- [SBA public data: Contains detailed information about each PPP loan, including 53 columns of data points](https://data.sba.gov/dataset/ppp-foia)

![367008287-78095eb2-5ded-489d-946a-4a47e44b8ed5](https://github.com/user-attachments/assets/c6fef490-836a-4826-8b30-830876d5b6a2)
![367008296-bfd884a6-fecb-45b0-959d-84dfea5405bf](https://github.com/user-attachments/assets/d27891b7-940d-4f1b-96c6-a21af7ba5bbc)
![367008269-1ea933a5-c4b4-4202-9299-7da814669f26](https://github.com/user-attachments/assets/7cb37a38-3812-46e8-bc96-5fc720aed96b)
![367008262-eb6392b7-092d-4951-b30d-7ce2cf27cb2b](https://github.com/user-attachments/assets/41f322f0-b864-43a9-958e-a4554b6cc0cf)
![367008243-a64f6351-f8cb-43a9-a7c5-ebcd1c54e6d3](https://github.com/user-attachments/assets/192e65c3-0559-418b-a4cc-9703142403a8)

- [NAICS industry standards: Provides industry sector classifications for categorizing businesses](https://www.sba.gov/document/support-table-size-standards)

![367008220-008ff57e-59fd-48c0-aa73-615b7ea11d02](https://github.com/user-attachments/assets/fcb73a97-2031-4fa6-826e-c37c49615f56)

- [Data dictionary: Explains the data points in the main dataset, crucial for accurate interpretation](https://www.sba.gov/document/support-table-size-standards)

![367008474-4f86f5ad-e264-46f1-a98c-4ab1c2a8d9bc](https://github.com/user-attachments/assets/17821182-4407-4941-94d3-8e090a3b60bb)
![367008466-555d0f52-4069-401d-8fe4-a87d75dab634](https://github.com/user-attachments/assets/e5d29508-fe8b-4be7-b8c8-f49056154f4d)

Key data points include:

- Loan number
- Date approved
- SBA office code
- Processing method
- Borrower name and address
- Loan status
- Term
- Initial approved amount and current amount
- Servicing lender
- Originating lender
- NAICS code
- Business type
- Race/ethnicity of borrower
- Gender of borrower
- Veteran status
- Forgiveness amount


## Data Import

The data was imported into SQL Server Management Studio (SSMS) using the SSMS Import Wizard. This tool facilitated the efficient transfer of data from various sources into the SQL Server database, ensuring that all necessary data points were correctly loaded and organized for analysis.


## Data Preparation

The initial data preparation involved several crucial steps:

- Thorough inspection of the data dictionary to understand the 53 columns in the main dataset
- Creation of three different tables to organize the data effectively:
  1. Main PPP loan data
  2. NAICS industry standards
  3. Data Dictionary
    

## Data Cleaning

In the data preparation phase, a key task was cleaning and organizing the NAICS industry standards table to ensure uniformity and accuracy. Here’s how I approached the process:

1. **Table Creation**: I created a new table to organize the NAICS industry standards more effectively. This included:
   - Extracting relevant columns from the existing data, focusing on industry descriptions and codes.
   - Implementing a structured format for easier analysis and reference.

2. **Data Cleaning and Standardization**:
   - **Code Extraction**: I standardized the industry codes by extracting and cleaning lookup codes from the industry description field. This involved identifying and separating codes embedded within the description text.
   - **Description Refinement**: I cleaned the sector descriptions by trimming unnecessary characters and ensuring consistency across similar sectors. This was done by isolating and standardizing sector names for better uniformity.


#### SQL Query

The following SQL script demonstrates the process of creating and cleaning the `sba_naics_codes_descriptions` table from the `Size_Standards` dataset. This involves extracting and processing NAICS industry descriptions to derive useful columns for analysis.

```sql
-- This query creates a new table 'sba_naics_codes_descriptions' by selecting and processing data from the 'Size_Standards' table.
-- It extracts and processes NAICS industry descriptions to derive two new columns: 'LookupCodes' and 'Sector'.
-- The 'LookupCodes' column is derived from a substring of 'NAICS_Industry_Description' if it contains '–', otherwise it is set to an empty string.
-- The 'Sector' column is derived by extracting and trimming the part of 'NAICS_Industry_Description' following '–' if present, otherwise it is set to an empty string.
-- The resulting rows are filtered to exclude those with empty 'LookupCodes'.

SELECT *
INTO sba_naics_codes_descriptions
FROM (
    SELECT 
        [NAICS_Industry_Description],
        CASE 
            WHEN [NAICS_Industry_Description] LIKE '%–%' THEN SUBSTRING([NAICS_Industry_Description], 8, 2)
            ELSE ''
        END AS LookupCodes,
        CASE 
            WHEN CHARINDEX('–', [NAICS_Industry_Description]) > 0 THEN 
                LTRIM(
                    SUBSTRING(
                        [NAICS_Industry_Description],
                        CHARINDEX('–', [NAICS_Industry_Description]) + 1,
                        LEN([NAICS_Industry_Description]) - CHARINDEX('–', [NAICS_Industry_Description])
                    )
                )
            ELSE ''
        END AS Sector
    FROM 
        [PortfolioDB].[dbo].[Size_Standards]
    WHERE 
        [NAICS_Codes] IS NULL 
        OR [NAICS_Codes] = ''
) AS main
WHERE 
    LookupCodes != '';


-- View records in 'sba_naics_codes_descriptions' ordered by 'LookupCodes',
-- insert new data into the table, and update 'Sector' values for a specific 'LookupCodes'.

SELECT *
FROM sba_naics_codes_descriptions
ORDER BY LookupCodes;

INSERT INTO [dbo].[sba_naics_codes_descriptions]
VALUES
    ('Sector 31 – 33 – Manufacturing', 32, 'Manufacturing'),
    ('Sector 31 – 33 – Manufacturing', 33, 'Manufacturing'),
    ('Sector 44 – 45 – Retail Trade', 45, 'Retail Trade'),
    ('Sector 48 – 49 – Transportation and Warehousing', 49, 'Transportation and Warehousing');

UPDATE sba_naics_codes_descriptions
SET Sector = 'Manufacturing'
WHERE LookupCodes = 31;
```
![367008481-3fa7ffd1-0881-42e2-baf3-f30d7250f7d7](https://github.com/user-attachments/assets/6e75be43-6a02-4dd1-a095-44b783545c95)

*After Cleaning*


## Data Analysis

### Overall PPP Loan Summary

- Total number of approved loans: **968,525**
- Total approved amount: **$515,518,176,983.85**
- Average loan size: **$532,271.42**

**Insights:**
- The massive scale of the PPP initiative is highlighted by the substantial number of loans and total amount approved.
- The average loan size indicates that many loans served medium-sized businesses, aligning with the program’s objectives.

#### SQL Query

```sql
-- This query calculates summary statistics for approved loans from the 'public_data' table.
-- It retrieves the total number of approved loans, the sum of initial approval amounts, 
-- and the average size of the approved loans from the entire dataset.

SELECT 
  COUNT(LoanNumber) AS Number_Of_Approved,  
  SUM(InitialApprovalAmount) AS Approved_Amount,  
  AVG(InitialApprovalAmount) AS Average_Loan_Size  
FROM 
  [PortfolioDB].[dbo].[dbo.public_data];
```

### Detailed Comparison of 2020 vs 2021 Loans

**2020:**
- Number of loans: **659,441** (68.1% of total)
- Total approved amount: **$377,642,663,931.70** (73.2% of total)
- Average loan size: **$572,670.89**

**2021:**
- Number of loans: **309,084** (31.9% of total)
- Total approved amount: **$137,875,513,052.15** (26.8% of total)
- Average loan size: **$446,077.81**

**Insights:**
- While 2021 saw fewer loans, the total dollar amount was considerably lower than in 2020.
- The average loan size in 2021 was lower, indicating a shift towards smaller loans. This likely reflects changes in program rules or increased targeting of smaller businesses.

#### SQL Query

```sql
-- This query retrieves summary statistics for approved loans for the years 2020 and 2021.
-- It calculates the number of approved loans, total approved amount, and average loan size for each year.
-- The results for each year are combined using the UNION operator.
SELECT 
  YEAR(DateApproved) AS year_approved,  
  COUNT(LoanNumber) AS Number_of_Approved_Loans,  
  SUM(InitialApprovalAmount) AS Approved_Amount,  
  AVG(InitialApprovalAmount) AS Average_Loan_Size  
FROM 
  [PortfolioDB].[dbo].[dbo.public_data]  
WHERE 
  YEAR(DateApproved) = 2020  
GROUP BY 
  YEAR(DateApproved)  
UNION 
SELECT 
  YEAR(DateApproved) AS year_approved,  
  COUNT(LoanNumber) AS Number_of_Approved_Loans,  
  SUM(InitialApprovalAmount) AS Approved_Amount,  
  AVG(InitialApprovalAmount) AS Average_Loan_Size 
FROM 
  [PortfolioDB].[dbo].[dbo.public_data]  
WHERE 
  YEAR(DateApproved) = 2021  
GROUP BY 
  YEAR(DateApproved);
```

### Top Originating Lenders Analysis

**2020:**
- Number of originating lenders: **4,119**

**2021:**
- Number of originating lenders: **3,779**

**Insights:**
- The number of originating lenders decreased by 8.3% from 2020 to 2021.
- Major lenders continued to play a significant role, with some dynamics shifting between the years.

#### SQL Query

```sql
-- This query retrieves and calculates the distinct count of the originating lenders
-- for the years 2020 and 2021. The query is divided into two parts using UNION,
-- with each part summarizing data for a specific year.

SELECT 
  COUNT(DISTINCT OriginatingLender) AS OriginatingLender, 
  YEAR(DateApproved) AS year_approved, 
  COUNT(LoanNumber) AS Number_of_Approved_Loans, 
  SUM(InitialApprovalAmount) AS Approved_Amount, 
  AVG(InitialApprovalAmount) AS Average_Loan_Size 
FROM 
  [PortfolioDB].[dbo].[dbo.public_data] 
WHERE 
  YEAR(DateApproved) = 2020 
GROUP BY 
  YEAR(DateApproved) 
UNION 
SELECT 
  COUNT(DISTINCT OriginatingLender) AS OriginatingLender, 
  YEAR(DateApproved) AS year_approved, 
  COUNT(LoanNumber) AS Number_of_Approved_Loans, 
  SUM(InitialApprovalAmount) AS Approved_Amount, 
  AVG(InitialApprovalAmount) AS Average_Loan_Size 
FROM 
  [PortfolioDB].[dbo].[dbo.public_data] 
WHERE 
  YEAR(DateApproved) = 2021 
GROUP BY 
  YEAR(DateApproved);

```
### Detailed Industry Analysis of PPP Loans

#### 1. Shift in Industry Distribution:

- **In 2020**, the top sectors by `Percentage_By_Amount` were:
  1. Construction (16.70%)
  2. Health Care and Social Assistance (16.47%)
  3. Professional, Scientific and Technical Services (16.05%)

- **In 2021**, this changed significantly:
  1. Accommodation and Food Services (22.43%)
  2. Construction (17.15%)
  3. Manufacturing (13.86%)

#### 2. Accommodation and Food Services:
- **In 2020**, this sector was 5th, with 9.45% of the loan amount.
- **In 2021**, it jumped to 1st place with 22.43%, more than doubling its share.
- The number of loans increased from 58,599 in 2020 to 66,161 in 2021.
- This dramatic increase reflects the prolonged impact of the pandemic on restaurants, hotels, and other hospitality businesses.

#### 3. Healthcare and Social Assistance:
- **In 2020**, this sector was 2nd with 16.47% of the loan amount.
- **In 2021**, it dropped to 4th place with 12.38%.
- The number of loans decreased from 83,717 in 2020 to 33,822 in 2021.
- This shift likely reflects the urgent needs in the healthcare sector during the initial pandemic response in 2020, with less acute need in 2021.

#### 4. Construction:
- Remained relatively stable, moving from 1st place in 2020 (16.70%) to 2nd place in 2021 (17.15%).
- However, the number of loans decreased significantly from 85,883 in 2020 to 42,693 in 2021.

#### 5. Manufacturing:
- Moved up from 4th place in 2020 (15.53%) to 3rd place in 2021 (13.86%).
- The number of loans decreased from 68,712 in 2020 to 32,347 in 2021.

#### 6. Professional, Scientific and Technical Services:
- Dropped from 3rd place in 2020 (16.05%) to 5th place in 2021 (11.85%).
- The number of loans decreased from 83,632 in 2020 to 32,389 in 2021.

These shifts reflect the changing economic landscape as the pandemic progressed:
- Initial widespread impact across sectors in 2020.
- More targeted support to heavily impacted industries like hospitality in 2021.
- Reduction in overall number of loans in 2021, possibly due to businesses adapting or, unfortunately, closing.
- The continued high ranking of Construction suggests ongoing economic activity in this sector despite the pandemic.

This analysis demonstrates how the PPP loan distribution adapted to the evolving economic needs during different phases of the pandemic, with some sectors requiring more sustained support than others.

#### SQL Query

```sql
-- CTE for top 15 sectors by approved loans for the year 2020

WITH cte AS (
  SELECT 
    TOP 15 d.Sector, -- Selecting top 15 sectors
    COUNT(LoanNumber) AS Number_of_Approved_Loans, -- Counting approved loans
    SUM(InitialApprovalAmount) AS Approved_Amount, -- Summing the approved amounts
    AVG(InitialApprovalAmount) AS Average_Loan_Size -- Calculating average loan size
  FROM 
    [PortfolioDB].[dbo].[dbo.public_data] p -- Using public data from PortfolioDB
    INNER JOIN [dbo].[sba_naics_codes_descriptions] d ON LEFT(p.NAICSCode, 2) = d.LookupCodes -- Joining with NAICS codes
  WHERE 
    YEAR(DateApproved) = 2020 -- Filtering for loans approved in 2020
  GROUP BY 
    d.Sector -- Grouping by sector
) 
-- Final output for 2020
SELECT 
  Sector, -- Displaying sector
  Number_of_Approved_Loans, -- Displaying the number of approved loans
  Approved_Amount, -- Displaying the sum of approved amounts
  Average_Loan_Size, -- Displaying the average loan size
  Approved_Amount / SUM(Approved_Amount) OVER() * 100 AS Percentage_By_Amount -- Calculating the percentage by approved amount
FROM 
  cte 
ORDER BY 
  Approved_Amount DESC; -- Ordering by approved amount in descending order

-- CTE for top 15 sectors by approved loans for the year 2021

WITH cte AS (
  SELECT 
    TOP 15 d.Sector, -- Selecting top 15 sectors
    COUNT(LoanNumber) AS Number_of_Approved_Loans, -- Counting approved loans
    SUM(InitialApprovalAmount) AS Approved_Amount, -- Summing the approved amounts
    AVG(InitialApprovalAmount) AS Average_Loan_Size -- Calculating average loan size
  FROM 
    [PortfolioDB].[dbo].[dbo.public_data] p -- Using public data from PortfolioDB
    INNER JOIN [dbo].[sba_naics_codes_descriptions] d ON LEFT(p.NAICSCode, 2) = d.LookupCodes -- Joining with NAICS codes
  WHERE 
    YEAR(DateApproved) = 2021 -- Filtering for loans approved in 2021
  GROUP BY 
    d.Sector -- Grouping by sector
) 
-- Final output for 2021
SELECT 
  Sector, -- Displaying sector
  Number_of_Approved_Loans, -- Displaying the number of approved loans
  Approved_Amount, -- Displaying the sum of approved amounts
  Average_Loan_Size, -- Displaying the average loan size
  Approved_Amount / SUM(Approved_Amount) OVER() * 100 AS Percentage_By_Amount -- Calculating the percentage by approved amount
FROM 
  cte 
ORDER BY 
  Approved_Amount DESC; -- Ordering by approved amount in descending order

```
### Comprehensive Loan Forgiveness Analysis

#### **2020:**
- **Number of Approved Loans:** 659,441
- **Current Approved Amount:** $376,029,395,273.64
- **Amount Forgiven:** $364,735,549,763.52
- **Percentage Forgiven:** 96.997%

#### **2021:**
- **Number of Approved Loans:** 309,084
- **Current Approved Amount:** $137,888,842,910.41
- **Amount Forgiven:** $134,096,937,948.43
- **Percentage Forgiven:** 97.250%

#### **Overall (2020 and 2021 combined):**
- **Total Number of Approved Loans:** 968,525
- **Total Approved Amount:** $513,918,238,184.05
- **Total Amount Forgiven:** $498,832,487,711.94
- **Overall Percentage Forgiven:** 97.065%

#### **Insights:**
- **High Forgiveness Rates:** Both years show high forgiveness rates, with 2021 at 97.25% and 2020 at 96.99%.
- **Overall Success:** The overall forgiveness rate of 97.07% highlights the program's effectiveness in meeting loan forgiveness criteria.
- **Consistent Forgiveness Rates:** The consistent high forgiveness rates across both years suggest effective compliance with loan criteria, such as maintaining employee headcount and eligible expenses.

#### SQL Query

```sql
-- This query retrieves loan statistics for the years 2020, 2021, and a combined total for both years.

-- Retrieve loan statistics for the year 2020
SELECT 
  '2020' AS Year_Approved,  -- Label for the year 2020
  COUNT(LoanNumber) AS Number_Of_Approved_Loans,  -- Total number of loans approved in 2020
  SUM(CurrentApprovalAmount) AS Current_Approved_Amount,  -- Sum of the approved loan amounts for 2020
  AVG(CurrentApprovalAmount) AS Current_Average_Loan_Size,  -- Average size of loans approved in 2020
  SUM(ForgivenessAmount) AS Amount_Forgiven,  -- Total amount forgiven for loans approved in 2020
  SUM(ForgivenessAmount) / SUM(CurrentApprovalAmount) * 100 AS Percent_Forgiven  -- Percentage of loans forgiven in 2020
FROM 
  [PortfolioDB].[dbo].[dbo.public_data] 
WHERE 
  YEAR(DateApproved) = 2020  -- Filter to retrieve data for the year 2020

UNION ALL 

-- Retrieve loan statistics for the year 2021
SELECT 
  '2021' AS Year_Approved,  -- Label for the year 2021
  COUNT(LoanNumber) AS Number_Of_Approved_Loans,  -- Total number of loans approved in 2021
  SUM(CurrentApprovalAmount) AS Current_Approved_Amount,  -- Sum of the approved loan amounts for 2021
  AVG(CurrentApprovalAmount) AS Current_Average_Loan_Size,  -- Average size of loans approved in 2021
  SUM(ForgivenessAmount) AS Amount_Forgiven,  -- Total amount forgiven for loans approved in 2021
  SUM(ForgivenessAmount) / SUM(CurrentApprovalAmount) * 100 AS Percent_Forgiven  -- Percentage of loans forgiven in 2021
FROM 
  [PortfolioDB].[dbo].[dbo.public_data] 
WHERE 
  YEAR(DateApproved) = 2021  -- Filter to retrieve data for the year 2021

UNION ALL 

-- Retrieve loan statistics for both years combined (2020 & 2021)
SELECT 
  'Total (2020 & 2021)' AS Year_Approved,  -- Label for the combined years 2020 and 2021
  COUNT(LoanNumber) AS Number_Of_Approved_Loans,  -- Total number of loans approved across both years
  SUM(CurrentApprovalAmount) AS Current_Approved_Amount,  -- Sum of the approved loan amounts across both years
  AVG(CurrentApprovalAmount) AS Current_Average_Loan_Size,  -- Average size of loans approved across both years
  SUM(ForgivenessAmount) AS Amount_Forgiven,  -- Total amount forgiven for loans approved across both years
  SUM(ForgivenessAmount) / SUM(CurrentApprovalAmount) * 100 AS Percent_Forgiven  -- Percentage of loans forgiven across both years
FROM 
  [PortfolioDB].[dbo].[dbo.public_data];

```
### Detailed Monthly Loan Approval Trends

| **Month** | **Year** | **Number of Approved Loans** | **Total Amount Approved ($)** | **Average Loan Size ($)** |
|-----------|----------|-----------------------------|-------------------------------|---------------------------|
| April     | 2020     | 548,335                     | 33,030,614,121.53             | 60,238.19                 |
| February  | 2021     | 112,336                     | 48,776,360,160.39             | 434,200.61                |
| January   | 2021     | 105,154                     | 45,099,149,125.56             | 428,886.67                |
| May       | 2020     | 93,962                      | 39,076,592,512.30             | 415,876.55                |
| March     | 2021     | 66,139                      | 30,314,842,914.58             | 458,350.49                |
| April     | 2021     | 19,219                      | 10,236,678,811.20             | 532,633.27                |
| June      | 2020     | 11,289                      | 5,052,506,050.89              | 447,560.11                |
| May       | 2021     | 5,837                       | 3,171,049,652.98              | 543,267.03                |
| July      | 2020     | 3,813                       | 1,808,689,222.88              | 474,348.08                |
| August    | 2020     | 2,038                       | 1,391,799,644.80              | 682,924.26                |

### Key Insights:
1. **April 2020** saw the highest number of loan approvals (548,335), but the average loan size was much smaller ($60,238.19) compared to later months.
2. **February 2021** and **January 2021** had the highest total amounts approved, with average loan sizes of $434,200.61 and $428,886.67 respectively, suggesting larger loan sizes but fewer approvals.
3. **August 2020** had the highest average loan size ($682,924.26), but only 2,038 loans were approved that month.
4. The loan approval trends show a significant drop in the number of approved loans from April 2020 to later months, while the **average loan size** increased as time progressed, especially into 2021.
5. **May 2021** had the highest average loan size ($543,267.03), showing a trend of approving fewer but larger loans in that period.

#### SQL Query
```sql
SELECT TOP 10
  MONTH(DateApproved) AS Month_Approved, -- Extract and display the month of loan approval
  YEAR(DateApproved) AS Year_Approved,   -- Extract and display the year of loan approval
  COUNT(LoanNumber) AS Number_of_Approved, -- Count the number of approved loans in each year-month period
  SUM(InitialApprovalAmount) AS Total_Amount_Approved, -- Sum of the approved loan amounts in each period
  AVG(InitialApprovalAmount) AS Average_Loan_Size -- Calculate the average loan size for each period
FROM 
  [PortfolioDB].[dbo].[dbo.public_data] 
GROUP BY 
  YEAR(DateApproved),  -- Group data by year of approval
  MONTH(DateApproved)  -- Group data by month of approval
ORDER BY 
  4 DESC -- Order the results by the total amount approved in descending order (showing the highest first)
```

## Conclusion:

This project provided a detailed analysis of the U.S. Small Business Administration's (SBA) Paycheck Protection Program (PPP) loans, focusing on key trends, distribution, and the program's overall impact. By leveraging the SBA's public data, I was able to extract meaningful insights into how the program supported small businesses during the COVID-19 pandemic. The analysis revealed several key findings:

- **Extensive Reach**: The PPP approved over $515 billion across 968,525 loans, reflecting its vast influence in stabilizing businesses.
- **Shift in Loan Size**: There was a notable shift from larger loans in 2020 to smaller loans in 2021, suggesting a broader focus on smaller businesses in the second phase of the program.
- **Industry-Specific Impacts**: Healthcare saw greater relief in 2020, while Accommodation and Food Services had increased needs in 2021, indicating varied pandemic effects across sectors.
- **Loan Forgiveness**: High forgiveness rates showcased the program’s success in meeting its intended purpose of providing immediate financial relief.

This project demonstrates my ability to work with large datasets, clean and transform raw data, and derive valuable insights that can inform decision-making. The analysis involved working with industry classification standards, time-series trends, and lender dynamics, showcasing a comprehensive approach to financial data analysis. It reflects my proficiency in handling complex data, drawing actionable conclusions, and using data to tell a compelling story, making this a valuable addition to my portfolio.



