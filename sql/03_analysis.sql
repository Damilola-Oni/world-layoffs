/* ======================================================================
   WORLD LAYOFFS — ANALYSIS (MySQL)
   File: analysis.sql
   ====================================================================== */

--  Total layoffs by year
SELECT 
    YEAR(`date`) AS year,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY year;

--  Total layoffs by industry
SELECT 
    industry,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_laid_off DESC;

-- Total layoffs by country
SELECT 
    country,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY total_laid_off DESC;

--  Top 10 companies with the largest layoffs
SELECT 
    company,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 10;

-- Average percentage laid off by industry
SELECT 
    industry,
    AVG(CAST(percentage_laid_off AS DECIMAL(10,2))) AS avg_percentage
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL
GROUP BY industry
ORDER BY avg_percentage DESC;

-- Funding raised vs layoff severity
SELECT 
    company,
    funds_raised_millions,
    total_laid_off
FROM layoffs_staging2
WHERE funds_raised_millions IS NOT NULL
ORDER BY funds_raised_millions DESC;

--  Layoffs trend (rolling 3-month window)
SELECT 
    DATE_FORMAT(`date`, '%Y-%m') AS month,
    SUM(total_laid_off) AS layoffs_month,
    SUM(SUM(total_laid_off)) OVER (
        ORDER BY DATE_FORMAT(`date`, '%Y-%m')
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_3m_layoffs
FROM layoffs_staging2
GROUP BY month
ORDER BY month;
