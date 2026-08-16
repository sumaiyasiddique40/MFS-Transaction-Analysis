CREATE TABLE transaction_types (
    type_id TEXT PRIMARY KEY,
    transaction_type TEXT NOT NULL
);

--Customer tables
CREATE TABLE customers (
    customer_id TEXT PRIMARY KEY,
    name TEXT,
    gender TEXT,
    age INTEGER,
    city TEXT,
    registration_date DATE
);

--Agent table
CREATE TABLE agents (
    agent_id TEXT PRIMARY KEY,
    agent_name TEXT,
    city TEXT,
    region TEXT,
    join_date DATE
);

--Accounts table
CREATE TABLE accounts (
    account_id TEXT PRIMARY KEY,
    customer_id TEXT NOT NULL,
    account_type TEXT,
    status TEXT,
    opening_date DATE,

    CONSTRAINT fk_accounts_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);
--Transaction table
CREATE TABLE transactions (
    transaction_id TEXT PRIMARY KEY,

    customer_id TEXT NOT NULL,

    agent_id TEXT NOT NULL,

    type_id TEXT NOT NULL,

    amount NUMERIC(12,2),

    transaction_date DATE,

    transaction_time TIME,

    status TEXT,

    channel TEXT,

    fee NUMERIC(12,2),

    transaction_month TEXT,

    transaction_year INTEGER,

    transaction_month_num INTEGER,

    net_amount NUMERIC(12,2),

    CONSTRAINT fk_transactions_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT fk_transactions_agent
        FOREIGN KEY (agent_id)
        REFERENCES agents(agent_id),

    CONSTRAINT fk_transactions_type
        FOREIGN KEY (type_id)
        REFERENCES transaction_types(type_id)
);

--Relationshp test
SELECT
    t.transaction_id,
    c.name AS customer_name,
    a.agent_name,
    tt.transaction_type,
    t.amount,
    t.status
FROM transactions t
JOIN customers c
    ON t.customer_id = c.customer_id
JOIN agents a
    ON t.agent_id = a.agent_id
JOIN transaction_types tt
    ON t.type_id = tt.type_id
LIMIT 20;

--Total transaction
SELECT
    COUNT(*) AS total_transactions
FROM transactions;

--Successful Transaction Value
SELECT
    SUM(amount) AS total_transaction_value
FROM transactions
WHERE status = 'Success';

--Transaction Type
SELECT
    tt.transaction_type,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(t.amount) AS total_amount
FROM transactions t
JOIN transaction_types tt
    ON t.type_id = tt.type_id
WHERE t.status = 'Success'
GROUP BY tt.transaction_type
ORDER BY total_amount DESC;

--Customer Analysis
SELECT
    c.customer_id,
    c.name,
    c.city,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(t.amount) AS total_transaction_value
FROM customers c
JOIN transactions t
    ON c.customer_id = t.customer_id
WHERE t.status = 'Success'
GROUP BY
    c.customer_id,
    c.name,
    c.city
ORDER BY total_transaction_value DESC;

--Agent Performance
SELECT
    a.agent_id,
    a.agent_name,
    a.city,
    a.region,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(t.amount) AS total_transaction_value
FROM agents a
JOIN transactions t
    ON a.agent_id = t.agent_id
WHERE t.status = 'Success'
GROUP BY
    a.agent_id,
    a.agent_name,
    a.city,
    a.region
ORDER BY total_transaction_value DESC;

--Monthly Transaction
SELECT
    DATE_TRUNC('month', transaction_date) AS month,
    COUNT(*) AS transactions,
    SUM(amount) AS transaction_value
FROM transactions
WHERE status = 'Success'
GROUP BY month
ORDER BY month;

--Failed Transaction Rate
SELECT
    COUNT(*) FILTER (
        WHERE status = 'Failed'
    ) * 100.0 / COUNT(*) AS failure_rate
FROM transactions;

--Top 10 Customers
SELECT
    c.customer_id,
    c.name,
    SUM(t.amount) AS total_value
FROM customers c
JOIN transactions t
    ON c.customer_id = t.customer_id
WHERE t.status = 'Success'
GROUP BY c.customer_id, c.name
ORDER BY total_value DESC
LIMIT 10;


