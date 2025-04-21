CREATE TABLE db.orders (
  order_id UInt64,
  user_id UInt64,
  order_date DateTime,
  total_amount Decimal(10,2),
  payment_status String
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(order_date)
ORDER BY (order_date, order_id);

CREATE TABLE db.order_items (
  order_item_id UInt64,
  order_id UInt64,
  product_name String,
  product_price Decimal(10,2),
  quantity UInt64
)
ENGINE = MergeTree()
ORDER BY order_id;

INSERT INTO db.orders
SELECT *
FROM s3(
  'https://storage.yandexcloud.net/storages/orders.csv',
  'CSV',
  'order_id UInt64, user_id UInt64, order_date DateTime, total_amount Decimal(10,2), payment_status String'
);

INSERT INTO db.order_items
SELECT *
FROM s3(
  'https://storage.yandexcloud.net/storages/order_items.txt',
  'CSV',
  'order_item_id UInt64, order_id UInt64, product_name String, product_price Decimal(10,2), quantity UInt64'
)
SETTINGS format_csv_delimiter = ';', input_format_csv_skip_first_lines = 1;

SELECT payment_status,
       COUNT(*) AS orders_count,
       SUM(total_amount) AS total_sum,
       AVG(total_amount) AS avg_order_amount
FROM db.orders
GROUP BY payment_status;

SELECT COUNT(order_item_id) AS total_items,
       SUM(product_price * quantity) AS overall_total,
       AVG(product_price) AS overall_avg_price
FROM db.order_items;

SELECT order_date,
       COUNT(*) AS orders_per_day,
       SUM(total_amount) AS daily_total
FROM db.orders
GROUP BY order_date
ORDER BY order_date;

SELECT user_id,
       COUNT(*) AS orders_count,
       SUM(total_amount) AS total_spent
FROM db.orders
GROUP BY user_id
ORDER BY total_spent DESC
LIMIT 10;
