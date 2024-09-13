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
