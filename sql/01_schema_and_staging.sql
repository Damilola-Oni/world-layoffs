/* ======================================================================
   WORLD LAYOFFS SQL PROJECT
   File: schema_and_staging.sql
   Purpose: Create raw structure + staging tables for cleaning
   ====================================================================== */

-- Create a clean staging table to work from
CREATE TABLE IF NOT EXISTS layoffs_staging LIKE layoffs;

-- Copy raw dataset into staging table
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- Create a second staging table with schema adjustments for cleaning
CREATE TABLE IF NOT EXISTS layoffs_staging2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT,
    percentage_laid_off TEXT,
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT,
    row_num INT
);
