# SQL Portfolio — PostgreSQL + Docker + Pagila Sample Database

This project demonstrates how to use PostgreSQL inside a Docker container and run analytical SQL queries on the Pagila sample database.
It is designed purely to showcase SQL skills (joins, CTEs, aggregations, window functions, date functions) in a clean, reproducible environment.

The queries can be found in the queries folder.

---

## Project Structure
```
sql-sample/
├─ docker-compose.yml
├─ initdb/
│   ├─ pagila-schema.sql
│   └─ pagila-data.sql
├─ queries/
│   ├─ sample-queries-intermediate.sql
│   └─ sample-queries-advanced.sql
└─ README.md

The two SQL files inside `initdb/` run automatically the first time the database starts.
They create all tables and load the sample data.
```

---

# Getting Started

## 1. Install prerequisites

- Docker Desktop  
- Git  
- Optional: VS Code + PostgreSQL extensions  

---

## 2. Clone the repository

git clone https://github.com:alebel94/sql-sample-code.git
cd sql-sample

---

## 3. Start PostgreSQL with Docker

docker compose up -d

This will:

- Pull the `postgres:16` image  
- Create a container named **sql-portfolio-db**  
- Create a persistent volume (`db_data`)  
- Execute the initialization SQL files in `initdb/`  
- Create and populate the **Pagila** database automatically  

The first startup may take up to a minute.

---

## 4. Connect to PostgreSQL

docker exec -it sql-portfolio-db psql -U postgres -d portfolio_db

---

# Useful PostgreSQL Commands (psql)

Run these **inside** psql:

### List all tables  
\dt

### Describe a table  
\d table_name  
Example:  
\d customer

### List schemas  
\dn

### Execute normal SQL  
SELECT COUNT(*) FROM rental LIMIT 10;

These shortcuts are very helpful for exploring unfamiliar databases.

---

# About the Pagila Database

Pagila is a PostgreSQL sample database modeled after a DVD rental store.

It includes realistic business tables:

- customers  
- films  
- actors  
- categories  
- rentals  
- inventory  
- payments  
- stores  
- staff  

Great for demonstrating SQL topics such as:

- simple joins  
- multi-table joins  
- CTEs  
- GROUP BY + HAVING  
- date functions  
- window functions  
- running totals  
- ranking  

---

# Source Files for Pagila

These official files are already included in this repo:

Schema:  
https://github.com/devrimgunduz/pagila/blob/master/pagila-schema.sql

Data:  
https://github.com/devrimgunduz/pagila/blob/master/pagila-data.sql

---

# Running Queries

Portfolio SQL queries are in:

queries/

You can run a sql file directly:

docker exec -it sql-portfolio-db psql -U postgres -d portfolio_db -f /app/queries/{file_name}.sql

Or copy/paste individual queries into psql.

---

# Stopping and Resetting the Database

### Stop the database (keep data)
docker compose down

### Reset the database completely (fresh start)
docker compose down -v  
docker compose up -d

This deletes the volume and re-runs everything in `initdb/`.

---

# Purpose of This Repository

This repository is intended to:

- Demonstrate SQL proficiency to employers looking at my repos
- Provide a reproducible PostgreSQL environment  
- Showcase intermediate and advanced SQL topics  
- Allow anyone to actually explore the data
