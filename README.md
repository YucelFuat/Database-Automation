PostgreSQL Database Automation Script
=====================================

Introduction
------------

This repository contains a **Bash script** that automates the creation of a PostgreSQL database, users, and tables. It also inserts sample book data, defines a function to add books, and grants appropriate permissions to different users.

This project was developed to demonstrate database automation using Bash and PostgreSQL.

Features
--------

*   Automates PostgreSQL **database** and **user** creation.
    
*   Creates a **books** table and populates it with **sample data**.
    
*   Defines a **function** to add new books dynamically.
    
*   Implements **role-based access control** with admin\_user and view\_user.
    
*   Uses a **.env file** for secure credential management.
    
*   Supports **multiple executions** without conflicts.
    
*   Ensures database integrity with proper **dependency management**.
    

Project Structure
-----------------
```
Database-Automation/  
│── setup_db.sh       # Main Bash script for database automation
│── .env              # Stores database credentials (ignored by Git)  
│── .gitignore        # Prevents sensitive files from being committed  
│── README.md         # Documentation (this file)`
```
Prerequisites
-------------

Before running this script, ensure you have the following installed:

*   **Ubuntu (Linux-based OS)**
    
*   **PostgreSQL 12+**
    
*   **Bash (default shell in Linux)**
    
*   **Git (for version control & repository management)**
    

Installation & Setup
--------------------

### Step 1: Clone the Repository
```
git clone https://github.com/YucelFuat/Database-Automation.git  
cd database-automation
```

### Step 2: Install PostgreSQL (If Not Installed)
`sudo apt update  sudo apt install postgresql postgresql-contrib -y`

### Step 3: Configure PostgreSQL

Ensure the PostgreSQL service is running:
`sudo systemctl start postgresql  sudo systemctl enable postgresql`

### Step 4: Create a .env File

The .env file is used to store sensitive database credentials securely.
`nano .env`

Add the following lines (modify values as needed):
`DB_NAME=books_db  DB_USER_ADMIN=admin_user  DB_USER_VIEW=view_user  DB_PASSWORD_ADMIN=SecureAdminPass123  DB_PASSWORD_VIEW=SecureViewPass123`

Save and exit (CTRL + X, then Y, then Enter).

### Step 5: Run the Script

Give execution permissions:
`chmod +x setup_db.sh`

Then execute:
`./setup_db.sh`

Security Considerations
-----------------------

### Using .env File for Credentials

*   The .env file is included in .gitignore, so it **won’t be pushed to GitHub**.
    
*   Always store credentials securely and avoid hardcoding them inside scripts.
    

### Using Secure Passwords

*   Replace default passwords in .env with strong passwords before production use.
    

How the Script Works
--------------------

1.  **Checks if the database exists** before creating it.
    
2.  **Creates a books table** to store book information.
    
3.  **Inserts five sample books** into the table.
    
4.  **Drops existing users** before recreating them (to avoid conflicts).
    
5.  **Grants full privileges to admin\_user** and **read-only access to view\_user**.
    
6.  **Creates a book\_list view** for easier data access.
    
7.  **Defines the add\_book function**, allowing new books to be added programmatically.
    

Testing the Setup
-----------------

### 1\. Check All Books in the Table
`sudo -u postgres psql -d books_db -c "SELECT * FROM books;"`

### 2\. Test the book\_list View
`sudo -u postgres psql -d books_db -c "SELECT * FROM book_list;"`

### 3\. Test the add\_book Function
`sudo -u postgres psql -d books_db -c "SELECT add_book('The Pragmatic Programmer', 'Your Journey To Mastery', 'Andrew Hunt', 'Addison-Wesley');"`

Role-Based Access Control
-------------------------

### Admin User (admin\_user)

*   Can **insert, update, delete**, and manage the database.
    

### View-Only User (view\_user)

*   Can **only read data** from the book\_list view.
    
*   Prevented from modifying records.
    

To test view-only access:
`sudo -u postgres psql -d books_db -U view_user -c "SELECT * FROM book_list;"`

Troubleshooting
---------------

### Error: Database Already Exists
`sudo -u postgres psql -c "DROP DATABASE books_db;"  ./setup_db.sh`

### Error: Permission Denied

`sudo -u postgres psql -d books_db -c "GRANT ALL ON ALL TABLES IN SCHEMA public TO admin_user;"  sudo -u postgres psql -d books_db -c "GRANT SELECT ON book_list TO view_user;"`

Contributing
------------

Feel free to open issues or pull requests if you'd like to improve this script.

Author
------

**Yücel Fuat IPEK**
