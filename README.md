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

- [NAICS industry standards: Provides industry sector classifications for categorizing businesses](https://www.sba.gov/document/support-table-size-standards)

- [Data dictionary: Explains the data points in the main dataset, crucial for accurate interpretation](https://www.sba.gov/document/support-table-size-standards)


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

The initial data preparation involved key steps:

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

![367097541-149b2e71-7be2-4ddf-b65d-11d96571d210](https://github.com/user-attachments/assets/d11bc51c-782c-4be4-aa38-db52b8cf8f8a)

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

![367097546-a1fe2cd9-ce8d-48e6-9acb-2931f720ba6a](https://github.com/user-attachments/assets/ee1f6dc1-9eea-4a3d-8f36-c507f3e9c32f)

#### **2020:**
- **Number of loans:** 659,441 (68.1% of total)
- **Total approved amount:** $377,642,663,931.70 (73.2% of total)
- **Average loan size:** $572,670.89

#### **2021:**
- **Number of loans:** 309,084 (31.9% of total)
- **Total approved amount:** $137,875,513,052.15 (26.8% of total)
- **Average loan size:** $446,077.81

#### **Insights and Correlation with COVID-19:**

The Paycheck Protection Program (PPP) in 2020 and 2021 reveals significant differences in loan distribution, strongly reflecting the evolving nature of the COVID-19 pandemic and its economic impact.

**2020** was the initial phase of the pandemic, where the U.S. economy faced unprecedented shutdowns, supply chain disruptions, and widespread layoffs. As businesses struggled to survive, the PPP was rolled out as an emergency lifeline. The high number of loans (659,441) and large total approved amount ($377.6 billion) in 2020 represent the government’s immediate and aggressive response to help businesses avoid mass layoffs. The average loan size of $572,670.89 suggests that the program initially focused on businesses with higher payroll costs, possibly medium-sized companies, which were seen as more vulnerable to collapse during the pandemic's early days.

By **2021**, the situation had evolved. While the pandemic still posed a serious threat, the economy began to show signs of stabilization due to vaccine rollouts and partial reopening of businesses. This is reflected in the reduced number of loans (309,084) and the significantly lower total approved amount ($137.9 billion). Additionally, the drop in the average loan size to $446,077.81 points to a shift in the program's focus. This shift is likely due to the revised PPP guidelines in 2021, which increased the emphasis on smaller businesses, particularly those that may have been overlooked during the initial rush for loans in 2020. It also coincides with the fact that larger businesses had already received support in the earlier stages of the pandemic, reducing their need for additional funding.

This adjustment aligns with the changes in the pandemic’s trajectory, where small businesses, especially in the hardest-hit sectors like retail, hospitality, and personal services, continued to face severe financial pressure. These sectors were likely targeted more directly in 2021 as they struggled with ongoing restrictions, lower consumer demand, and fluctuating reopening protocols.

In summary, the decrease in loan volume, total approved amount, and average loan size in 2021 reflects the program’s pivot toward smaller businesses, which were still vulnerable even as larger companies began to stabilize. This shift highlights how the economic challenges of COVID-19 evolved, from a broad-based collapse in 2020 to more concentrated pockets of distress in 2021.

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

![367097550-78d76091-9871-4719-bd7b-0e386fed3283](https://github.com/user-attachments/assets/fe2e38ca-15d4-4fde-849a-845940c62f1c)

**2020:**
- **Number of originating lenders: 4,119**
  - The significant number of lenders in 2020 was a direct response to the unprecedented scale of the COVID-19 crisis. With businesses across the nation in desperate need of financial support, the SBA relied heavily on both large and small financial institutions to distribute funds quickly and efficiently. 

**2021:**
- **Number of originating lenders: 3,779** (8.3% decrease)
  - By 2021, as the pandemic’s immediate economic impact began to stabilize, the number of participating lenders slightly decreased. This decline was influenced by lower loan demand as many businesses had either stabilized or adapted to the new economic environment.


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

![2020](https://github.com/user-attachments/assets/121ed35a-b8a4-4911-a79e-8377daa11ef4)
  *2020*

![2021](https://github.com/user-attachments/assets/850c00ab-4c02-4bc8-83ce-45118c17420a)
  *2021*


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

![367097554-1eeaac05-0ade-4795-af57-2f481be3e14c](https://github.com/user-attachments/assets/32185f64-0d08-41dd-996e-59a2a9275507)

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

![367097558-0d114872-98be-4612-b155-aea5a080bfdb](https://github.com/user-attachments/assets/f464c8fc-973f-4426-a0d5-0df5d41be014)

**1. April 2020:**
   - **Number of Approved Loans:** 548,335
   - **Total Amount Approved:** $33,030,614,121.53
     
   - **Insight:** This month represents the peak of the initial PPP response, aligning with the early stages of the COVID-19 pandemic when the U.S. saw a significant surge in loan applications. The high number of loans approved reflects the urgent need to stabilize small businesses facing sudden shutdowns and economic uncertainty as the pandemic led to widespread lockdowns and business closures.

**2. May 2020:**
   - **Number of Approved Loans:** 93,962
   - **Total Amount Approved:** $39,076,592,512.30
     
   - **Insight:** Following the initial peak, May saw a reduction in the number of loans but an increase in the total amount approved. This shift indicates a transition from general support to addressing more substantial financial needs of larger businesses as the pandemic's impact persisted and the program adapted to evolving economic conditions.

**3. February 2021:**
   - **Number of Approved Loans:** 112,336
   - **Total Amount Approved:** $48,776,360,160.39
     
   - **Insight:** This peak in early 2021 reflects the ongoing economic strain as businesses continued to face challenges from extended pandemic restrictions and lockdowns. The resurgence in loan approvals indicates a renewed focus on providing critical support to businesses grappling with prolonged disruptions and slower recovery.

**4. March 2021:**
   - **Number of Approved Loans:** 66,139
   - **Total Amount Approved:** $30,314,842,914.58
     
   - **Insight:** The continued high volume of loans in March 2021 highlights the sustained impact of the pandemic on businesses. This period, just before the vaccine rollout gained momentum, illustrates the need for ongoing financial relief as businesses faced continued uncertainty and operational challenges.

**5. April 2021:**
   - **Number of Approved Loans:** 19,219
   - **Total Amount Approved:** $10,236,678,811.20
     
   - **Insight:** The significant drop in the number of loans but high total amount approved indicates a more targeted approach to financial support. By this time, as vaccination efforts were ramping up and businesses began adjusting to a new normal, the PPP focused on high-impact sectors or businesses still facing severe challenges, reflecting a shift in strategy towards more selective assistance.

### Correlation with COVID-19 Milestones:

- **April 2020:** Initial response phase with widespread business closures and economic disruption due to the rapid spread of COVID-19.
- **May 2020:** Ongoing pandemic with adaptations in the PPP to address larger financial needs amid continued lockdowns and economic strain.
- **February 2021:** Economic challenges persist with extended restrictions; loan approvals peak as businesses face prolonged impacts and slow recovery.
- **March 2021:** Continued need for financial support as businesses await vaccine distribution and adapt to evolving pandemic conditions.
- **April 2021:** Shift towards targeted support reflecting improved vaccine rollout and adjustment to new economic conditions. 

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



