/* =====================================================================
   WORLD LAYOFFS DATA CLEANING (MySQL)
   File: cleaning.sql
   ===================================================================== */

-- IDENTIFY DUPLICATES USING ROW_NUMBER()

WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
                PARTITION BY company, location, industry, total_laid_off,
                             percentage_laid_off, `date`, stage, country,
                             funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- INSERT INTO SECOND STAGING TABLE WITH ROW_NUM COLUMN
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off,
                 percentage_laid_off, `date`, stage, country,
                 funds_raised_millions
) AS row_num
FROM layoffs_staging;

-- REMOVE DUPLICATES
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- STANDARDIZE COMPANY NAMES (trim whitespace)
UPDATE layoffs_staging2
SET company = TRIM(company);

-- STANDARDIZE INDUSTRY LABELS (e.g., "Crypto / CryptoCurrency")
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE '%Crypto%';

--  CLEAN COUNTRY NAMES (remove trailing periods)
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- CONVERT DATE STRING TO REAL DATE FORMAT
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Change column from TEXT → DATE type
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- CLEAN INDUSTRY BLANKS INTO NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- BACKFILL INDUSTRY USING SELF-JOIN (Airbnb example)
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
      ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;

-- REMOVE ROWS WHERE BOTH KEY VALUES ARE NULL
--  (These rows contain zero useful information)
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Cleaning is complete
SELECT * FROM layoffs_staging2;
