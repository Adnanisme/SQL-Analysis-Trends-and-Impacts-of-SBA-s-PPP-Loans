  /*****QUESTION 1 summary of all approved PPP Loans**/

   -- This query calculates summary statistics for approved loans from the 'public_data' table.
-- It retrieves the total number of approved loans, the sum of initial approval amounts, 
-- and the average size of the approved loans from the entire dataset.

SELECT 
  COUNT(LoanNumber) AS Number_Of_Approved,  
  SUM(InitialApprovalAmount) AS Approved_Amount,  
  AVG(InitialApprovalAmount) AS Average_Loan_Size  
FROM 
  [PortfolioDB].[dbo].[dbo.public_data]  
 
 
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
  YEAR(DateApproved)

-- This query retrieves loan summary statistics for the years 2020 and 2021 from the 'public_data' table.
-- This query retrieves and calculates the distinct count of the originating lenders
-- The query is divided into two parts using UNION, with each part summarizing data for a specific year (2020 and 2021).

SELECT 
  COUNT (DISTINCT OriginatingLender) OriginatingLender, 
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
  COUNT (DISTINCT OriginatingLender) OriginatingLender, 
  YEAR(DateApproved) AS year_approved, 
  COUNT(LoanNumber) AS Number_of_Approved_Loans, 
  SUM(InitialApprovalAmount) AS Approved_Amount, 
  AVG(InitialApprovalAmount) AS Average_Loan_Size 
FROM 
  [PortfolioDB].[dbo].[dbo.public_data] 
WHERE 
  YEAR(DateApproved) = 2021 
GROUP BY 
  YEAR(DateApproved)


  /**QUESTION 2, Top 10 originating lenders by loan count, total amount and average in 2020 and 2021**/
  -- This query retrieves the top 10 lenders with the highest total approved loan amounts for the years 2020 and 2021.
-- It provides the lender's name, the number of approved loans, the total approved amount, and the average loan size.
-- The results are grouped by lender and ordered in descending order based on the total approved amount for each year.


SELECT 
  TOP 10 OriginatingLender, 
  COUNT(LoanNumber) AS Number_of_Approved_Loans, 
  SUM(InitialApprovalAmount) AS Approved_Amount, 
  AVG(InitialApprovalAmount) AS Average_Loan_Size 
FROM 
  [PortfolioDB].[dbo].[dbo.public_data] 
WHERE 
  YEAR(DateApproved) = 2021 
GROUP BY 
  OriginatingLender 
ORDER BY 
  3 DESC;

SELECT 
  TOP 10 OriginatingLender, 
  COUNT(LoanNumber) AS Number_of_Approved_Loans, 
  SUM(InitialApprovalAmount) AS Approved_Amount, 
  AVG(InitialApprovalAmount) AS Average_Loan_Size 
FROM 
  [PortfolioDB].[dbo].[dbo.public_data] 
WHERE 
  YEAR(DateApproved) = 2020 
GROUP BY 
  OriginatingLender 
ORDER BY 
  3 DESC;


 /**QUESTION 3, Top 15 Industries That Receievd The PPP Loans in 2020 and 2021**/
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


  ----QUESTION 4 How Much of the PPP Loans of 2021 and 2020 have been fully forgiven
-- This query retrieves loan statistics for 2020, 2021, and a combined total for both years
-- Retrieve loan statistics for the year 2020
SELECT 
  '2020' AS Year_Approved, 
  COUNT(LoanNumber) AS Number_Of_Approved_Loans, 
  SUM(CurrentApprovalAmount) AS Current_Approved_Amount, 
  AVG(CurrentApprovalAmount) AS Current_Average_Loan_Size, 
  SUM(ForgivenessAmount) AS Amount_Forgiven, 
  
  SUM(ForgivenessAmount) / SUM(CurrentApprovalAmount) * 100 AS Percent_Forgiven 
FROM 
  [PortfolioDB].[dbo].[dbo.public_data] 
WHERE 
  YEAR(DateApproved) = 2020 
UNION ALL 
  
SELECT 
  '2021' AS Year_Approved, 
  COUNT(LoanNumber) AS Number_Of_Approved_Loans, 
  SUM(CurrentApprovalAmount) AS Current_Approved_Amount, 
  AVG(CurrentApprovalAmount) AS Current_Average_Loan_Size, 
  SUM(ForgivenessAmount) AS Amount_Forgiven, 
  
  SUM(ForgivenessAmount) / SUM(CurrentApprovalAmount) * 100 AS Percent_Forgiven 
FROM 
  [PortfolioDB].[dbo].[dbo.public_data] 
WHERE 
  YEAR(DateApproved) = 2021 
UNION ALL 
  
SELECT 
  'Total (2020 & 2021)' AS Year_Approved, 
  COUNT(LoanNumber) AS Number_Of_Approved_Loans, 
  SUM(CurrentApprovalAmount) AS Current_Approved_Amount, 
  AVG(CurrentApprovalAmount) AS Current_Average_Loan_Size, 
  SUM(ForgivenessAmount) AS Amount_Forgiven, 
  -- Calculate the percentage of forgiven amount for both years combined
  SUM(ForgivenessAmount) / SUM(CurrentApprovalAmount) * 100 AS Percent_Forgiven 
FROM 
  [PortfolioDB].[dbo].[dbo.public_data] 
WHERE 
  YEAR(DateApproved) IN (2020, 2021) -- Sort the results in descending order of Year_Approved
ORDER BY 
  Year_Approved DESC;



  ---QUESTION 5 : Top 10 Month with the highest PPP loans approved

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
