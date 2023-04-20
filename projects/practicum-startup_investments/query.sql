--1
SELECT
  COUNT(*)
FROM
  company
WHERE status = 'closed'

--2
SELECT
  funding_total
FROM
  company
WHERE
  category_code IN ('news')
  AND country_code IN ('USA')
ORDER BY
  funding_total DESC;
  
--3
SELECT
  SUM(price_amount)
--  EXTRACT(YEAR FROM updated_at::date)
FROM
  acquisition
WHERE
  term_code = 'cash'
  AND EXTRACT(YEAR FROM acquired_at::date) BETWEEN 2011 AND 2013
  
--4
SELECT
  first_name,
  last_name,
  twitter_username
FROM
  people
WHERE
  twitter_username LIKE 'Silver%'
  
--5
SELECT
  *
FROM
  people
WHERE
  twitter_username LIKE ('%money%')
  AND last_name LIKE ('K%')
  
--6
SELECT
  country_code,
  SUM(funding_total)
FROM
  company
GROUP BY
  country_code
ORDER BY
  sum DESC
  
--7
SELECT
  funded_at,
  MIN(raised_amount),
  MAX(raised_amount)
FROM
  funding_round
GROUP BY
  funded_at
HAVING
  MIN(raised_amount) != 0
  AND MIN(raised_amount) != MAX(raised_amount)
  
--8
SELECT
  *,
  CASE
    WHEN invested_companies >= 100 THEN 'high_activity'
    WHEN invested_companies >= 20 AND invested_companies < 100 THEN 'middle_activity'
    WHEN invested_companies < 20 THEN 'low_activity'
  END
FROM
  fund
  
--9
SELECT 
  CASE
    WHEN invested_companies >= 100 THEN 'high_activity'
    WHEN invested_companies >= 20 THEN 'middle_activity'
    ELSE 'low_activity'
  END AS activity, 
  ROUND(AVG(investment_rounds)) AS avg_rounds
FROM 
  fund 
GROUP BY 
  activity 
ORDER BY 
  avg_rounds;
  
--10
SELECT
  country_code,
  MIN(invested_companies),
  MAX(invested_companies),
  AVG(invested_companies)
FROM fund
WHERE EXTRACT(YEAR FROM(founded_at::date)) BETWEEN 2010 AND 2012
GROUP BY
  country_code
HAVING
  MIN(invested_companies) != 0
ORDER BY
  AVG(invested_companies) DESC,
  country_code
LIMIT
  10;
  
--11
SELECT
  ppl.first_name,
  ppl.last_name,
  edu.instituition
FROM
  people AS ppl
  LEFT JOIN company AS com ON ppl.id=com.id
  LEFT JOIN education AS edu ON ppl.id=edu.person_id
--WHERE edu.instituition IS NOT NULL;

--12
SELECT
  com.name AS name,
  COUNT(DISTINCT edu.instituition) AS inst
FROM
  company AS com
  INNER JOIN people AS ppl ON com.id=ppl.company_id
  INNER JOIN education AS edu ON ppl.id=edu.person_id
GROUP BY
  name
ORDER BY
  inst DESC
LIMIT
  5;
  
--13
SELECT
  DISTINCT com.name
FROM
  company AS com
WHERE
  status='closed'
  AND id IN (SELECT
               company_id
             FROM
               funding_round
             WHERE
               is_first_round=is_last_round
               AND is_first_round=1
            );

--14
SELECT
  DISTINCT ppl.id
FROM
  people AS ppl
WHERE ppl.company_id IN (SELECT
                           com.id
                         FROM
                           company AS com
                         WHERE
                           status='closed'
                           AND id IN (SELECT
                                        company_id
                                      FROM
                                        funding_round
                                      WHERE
                                        is_first_round=is_last_round
                                        AND is_first_round=1
                                     )
                        );

--15
SELECT 
  DISTINCT edu.instituition,
  ppl.id
FROM 
  education AS edu
  INNER JOIN people AS ppl ON edu.person_id=ppl.id
WHERE 
  edu.person_id IN(
    SELECT 
      DISTINCT ppl.id 
    FROM 
      people AS ppl 
    WHERE 
      ppl.company_id IN (
        SELECT 
          com.id 
        FROM 
          company AS com 
        WHERE 
          status = 'closed' 
          AND id IN (
            SELECT 
              company_id 
            FROM 
              funding_round 
            WHERE 
              is_first_round = is_last_round 
              AND is_first_round = 1
          )
      )
  );

--16
SELECT 
--  DISTINCT edu.instituition AS instituition,
  ppl.id AS people_id,
  COUNT(edu.instituition)
FROM 
  education AS edu
  INNER JOIN people AS ppl ON edu.person_id=ppl.id
WHERE 
  edu.person_id IN(
    SELECT 
      DISTINCT ppl.id 
    FROM 
      people AS ppl 
    WHERE 
      ppl.company_id IN (
        SELECT 
          com.id 
        FROM 
          company AS com 
        WHERE 
          status = 'closed' 
          AND id IN (
            SELECT 
              company_id 
            FROM 
              funding_round 
            WHERE 
              is_first_round = is_last_round 
              AND is_first_round = 1
          )
      )
  )
GROUP BY
--  instituition,
  people_id

--17
WITH edu_people AS (SELECT 
  ppl.id AS people_id,
  COUNT(edu.instituition) AS edu_count
FROM 
  education AS edu
  INNER JOIN people AS ppl ON edu.person_id=ppl.id
WHERE 
  edu.person_id IN(
    SELECT 
      DISTINCT ppl.id 
    FROM 
      people AS ppl 
    WHERE 
      ppl.company_id IN (
        SELECT 
          com.id 
        FROM 
          company AS com 
        WHERE 
          status = 'closed' 
          AND id IN (
            SELECT 
              company_id 
            FROM 
              funding_round 
            WHERE 
              is_first_round = is_last_round 
              AND is_first_round = 1
          )
      )
  )
GROUP BY
  people_id)

SELECT
  AVG(edu_count)
FROM
  edu_people
  
--18
WITH edu_people AS (SELECT 
  ppl.id AS people_id,
  COUNT(edu.instituition) AS edu_count
FROM 
  education AS edu
  INNER JOIN people AS ppl ON edu.person_id=ppl.id
WHERE 
  edu.person_id IN(
    SELECT 
      DISTINCT ppl.id 
    FROM 
      people AS ppl 
    WHERE 
      ppl.company_id IN (
        SELECT 
          com.id 
        FROM 
          company AS com 
        WHERE 
          com.name = 'Facebook'
          AND id IN (
            SELECT 
              company_id 
            FROM 
              funding_round 

          )
      )
  )
GROUP BY
  people_id)

SELECT
  AVG(edu_count)
FROM
  edu_people
  
--19
SELECT
  fun.name AS name_of_fund,
  com.name AS name_of_company,
  fun_rnd.raised_amount AS amount
FROM
  investment AS inv
  INNER JOIN company AS com ON inv.company_id=com.id
  INNER JOIN fund AS fun ON inv.fund_id=fun.id
  INNER JOIN funding_round AS fun_rnd ON inv.funding_round_id=fun_rnd.id
WHERE
  com.milestones > 6
  AND EXTRACT(YEAR FROM inv.created_at::date) BETWEEN 2012 AND 2013;
  
--20
SELECT
  company_buyer.name AS company_buyer,
  acquisition.price_amount,
  company_seller.name AS company_seller,
  company_seller.funding_total,
  ROUND(acquisition.price_amount / company_seller.funding_total)
FROM
  acquisition
  LEFT JOIN company AS company_buyer ON acquisition.acquiring_company_id=company_buyer.id
  LEFT JOIN company AS company_seller ON acquisition.acquired_company_id=company_seller.id
WHERE
  acquisition.price_amount != 0
  AND company_seller.funding_total != 0
ORDER BY
  acquisition.price_amount DESC,
  company_seller.name
LIMIT
  10;
  
--21
SELECT
  c.name,
  EXTRACT(MONTH FROM f.funded_at::date)
FROM
  company AS c
  LEFT JOIN funding_round AS f ON c.id=f.company_id
WHERE
  c.category_code = 'social'
  AND EXTRACT(YEAR FROM f.funded_at::date) BETWEEN 2010 AND 2013
  AND f.raised_amount != 0

--22
WITH fund_temp AS (
  SELECT 
    COUNT(DISTINCT f.id) AS fund_name_count, 
    EXTRACT(MONTH FROM funded_at) AS month 
  FROM 
    fund AS f 
    INNER JOIN investment AS i ON f.id = i.fund_id 
    INNER JOIN funding_round AS fr ON i.funding_round_id = fr.id 
  WHERE 
    f.country_code = 'USA' 
    AND EXTRACT(YEAR FROM fr.funded_at) BETWEEN 2010 AND 2013 
  GROUP BY 
    month
), 
acquisition_temp AS (
  SELECT 
    COUNT(acquired_company_id) AS company_count, 
    SUM(price_amount) AS total_sum, 
    EXTRACT(MONTH FROM acquired_at) AS month 
  FROM 
    acquisition 
  WHERE 
    EXTRACT(YEAR FROM acquired_at) BETWEEN 2010 AND 2013 
  GROUP BY 
    month
) 
SELECT 
  fund_temp.month, 
  fund_temp.fund_name_count, 
  acquisition_temp.company_count, 
  acquisition_temp.total_sum 
FROM 
  fund_temp 
  FULL JOIN acquisition_temp ON fund_temp.month = acquisition_temp.month 
ORDER BY 
  fund_temp.month;
  
--23
WITH
y_2011 AS (
SELECT country_code,
       AVG(funding_total) AS avg_2011
FROM company
WHERE EXTRACT(YEAR FROM founded_at::DATE) = 2011
GROUP BY country_code),
y_2012 AS (
SELECT country_code,
       AVG(funding_total) AS avg_2012
FROM company
WHERE EXTRACT(YEAR FROM founded_at::DATE) = 2012
GROUP BY country_code),
y_2013 AS (
SELECT country_code,
       AVG(funding_total) AS avg_2013
FROM company
WHERE EXTRACT(YEAR FROM founded_at::DATE) = 2013
GROUP BY country_code)

SELECT
  y_2011.country_code,
  y_2011.avg_2011,
  y_2012.avg_2012,
  y_2013.avg_2013
FROM
  y_2011
  INNER JOIN y_2012 ON y_2011.country_code=y_2012.country_code
  INNER JOIN y_2013 ON y_2012.country_code=y_2013.country_code
ORDER BY
  y_2011.avg_2011 DESC;