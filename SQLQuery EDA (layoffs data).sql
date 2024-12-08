-- Sql Project - Exploratory Data Analysis


-- explore the data and find trends or patterns or anything interesting like outliers
SELECT *
FROM layoffs_sample2;


SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_sample2
WHERE  percentage_laid_off IS NOT NULL;


SELECT *
FROM layoffs_sample2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


SELECT company, SUM(total_laid_off)	
FROM layoffs_sample2
GROUP BY company
ORDER BY 2 DESC;


SELECT MIN(`date`), MAX(`date`)
FROM layoffs_sample2;


SELECT industry, SUM(total_laid_off)	
FROM layoffs_sample2
GROUP BY industry
ORDER BY 2 DESC;
 
 
SELECT country, SUM(total_laid_off)	
FROM layoffs_sample2
GROUP BY country
ORDER BY 2 DESC;


SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_sample2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;


SELECT stage, SUM(total_laid_off)
FROM layoffs_sample2
GROUP BY stage
ORDER BY 2 DESC;


SELECT DATE_FORMAT(`date`, '%Y-%m') AS Year_and_month, SUM(total_laid_off)
FROM layoffs_sample2
WHERE DATE_FORMAT(`date`, '%Y-%m') IS NOT NULL
GROUP BY Year_and_month
ORDER BY 1 ASC;


WITH Rolling_Total AS
(SELECT DATE_FORMAT(`date`, '%Y-%m') AS Year_and_month, SUM(total_laid_off) AS total_off
FROM layoffs_sample2
WHERE DATE_FORMAT(`date`, '%Y-%m') IS NOT NULL
GROUP BY Year_and_month
ORDER BY 1 ASC
)
SELECT Year_and_month, total_off, SUM(total_off) OVER(ORDER BY Year_and_month) AS rolling_total_off
FROM Rolling_Total;

SELECT company, YEAR(`date`), SUM(total_laid_off)	
FROM layoffs_sample2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)	
FROM layoffs_sample2
GROUP BY company, YEAR(`date`)
),
Company_Year_Rank AS
(
SELECT *,
 DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;




















