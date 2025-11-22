/* ======================================================================
   SQL SKILLS SHOWCASE — WORLD LAYOFFS DATASET
   File: sql_skills_showcase.sql
   ====================================================================== */

--  Classify layoffs into severity buckets
SELECT 
    company,
    total_laid_off,
    CASE 
        WHEN total_laid_off >= 5000 THEN 'Severe'
        WHEN total_laid_off BETWEEN 1000 AND 4999 THEN 'High'
        WHEN total_laid_off BETWEEN 100 AND 999 THEN 'Moderate'
        ELSE 'Low'
    END AS severity
FROM layoffs_staging2;

--  indow function → Rank companies by total layoffs
SELECT 
    company,
    SUM(total_laid_off) AS total_laid_off,
    RANK() OVER (ORDER BY SUM(total_laid_off) DESC) AS layoff_rank
FROM layoffs_staging2
GROUP BY company
ORDER BY total_laid_off DESC;

-- Subquery → Industries with above-average layoffs
SELECT industry, total_laid_off
FROM layoffs_staging2
WHERE total_laid_off > (
    SELECT AVG(total_laid_off)
    FROM layoffs_staging2
);

--  CTE — Month-over-month change
WITH monthly AS (
    SELECT 
        DATE_FORMAT(`date`, '%Y-%m') AS month,
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY month
)
SELECT 
    month,
    total_laid_off,
    LAG(total_laid_off) OVER (ORDER BY month) AS prev_month,
    (total_laid_off - LAG(total_laid_off) OVER (ORDER BY month)) AS change_mom
FROM monthly;

-- Grouping — Layoffs by stage
SELECT 
    stage,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_laid_off DESC;
