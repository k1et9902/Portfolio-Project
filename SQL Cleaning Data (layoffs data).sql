-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022






SELECT * 
FROM layoffs;



-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens
CREATE TABLE layoffs_sample
LIKE layoffs;

INSERT layoffs_sample
SELECT * FROM layoffs;


-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways


-- 1. REMOVE DUPLICATES

#Check for duplicates

SELECT *
FROM layoffs_sample;

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_sample;



SELECT *
FROM (SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_sample) duplicate
WHERE row_num > 1;

SELECT *
FROM layoffs_sample
WHERE company = "Oda";

WITH duplicate_CTE AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_sample
)

SELECT *
FROM duplicate_CTE
WHERE row_num > 1;

CREATE TABLE `layoffs_sample2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_sample2;


INSERT INTO	layoffs_sample2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_sample;

SELECT *
FROM layoffs_sample2
WHERE row_num > 1;

DELETE FROM layoffs_sample2
WHERE row_num >= 2;

-- 2.STANDARDIZING DATA

UPDATE layoffs_sample2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_sample2
ORDER BY 1;

SELECT *
FROM layoffs_sample2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_sample2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry 
FROM layoffs_sample2;

UPDATE layoffs_sample2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`
FROM layoffs_sample2;
UPDATE layoffs_sample2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
ALTER TABLE layoffs_sample2
MODIFY COLUMN `date` DATE;



-- 3. HANDLE NULL or BLANK 

SELECT *
FROM layoffs_sample2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_sample2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_sample2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_sample2
WHERE company = 'Airbnb';

SELECT *
FROM layoffs_sample2 t1
JOIN layoffs_sample2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_sample2 t1
JOIN layoffs_sample2 t2
	ON t1.company = t2.company
SET  t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_sample2;



-- 4. remove any columns and rows we need to

SELECT *
FROM layoffs_sample2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_sample2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_sample2
DROP COLUMN row_num;










