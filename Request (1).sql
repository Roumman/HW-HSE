CREATE TABLE transactions_v2 (
  transaction_id INT,
  user_id INT,
  amount DECIMAL(10,2),
  currency VARCHAR(3),
  transaction_date TIMESTAMP,
  is_fraud INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

LOAD DATA INPATH 's3a://storages/transactions_v2.csv' INTO TABLE transactions_v2;


CREATE TABLE logs_v2 (
  log_id INT,
  transaction_id INT,
  category STRING,
  comment STRING,
  log_timestamp TIMESTAMP
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ';'
STORED AS TEXTFILE;

LOAD DATA INPATH 's3a://storages/logs_v2.txt' INTO TABLE logs_v2;

drop table logs_v2;
drop table transactions_v2;

SELECT currency, SUM(amount) AS total_amount
FROM transactions_v2
WHERE currency IN ('USD', 'EUR', 'RUB')
GROUP BY currency;

SELECT is_fraud,
       COUNT(*) AS transaction_count,
       SUM(amount) AS total_amount,
       AVG(amount) AS avg_amount
FROM transactions_v2
GROUP BY is_fraud;

SELECT TO_DATE(transaction_date) AS transaction_day,
       COUNT(*) AS transaction_count,
       SUM(amount) AS total_amount,
       AVG(amount) AS avg_amount
FROM transactions_v2
GROUP BY TO_DATE(transaction_date);

SELECT t.transaction_id,
       COUNT(l.log_id) AS logs_count,
       MAX(l.category) AS frequent_category
FROM transactions_v2 t
LEFT JOIN logs_v2 l ON t.transaction_id = l.transaction_id
GROUP BY t.transaction_id;
