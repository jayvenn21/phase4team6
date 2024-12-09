# Business Supply Database Application

## 1. Instructions to Set Up Your App

1. **Install MySQL**:  

2. **Initialize the Database**:  
   - In a terminal, run:
     ```bash
     mysql -u root -p < 4database.sql
     mysql -u root -p business_supply < phase4_team6.sql
     ```

    This creates and populates the `business_supply` database with all tables, sample data, stored procedures, and views.

## 2. Instructions to Run Your App

1. **Run the UI Script**:  
   In the same directory as `ui.py`:
   ```bash
   python ui.py

2. **Using the Application**:
    - A GUI window will appear.
    - Use the dropdown menu to select the desired stored procedure or view.
    - If the selected option is a procedure, fill in the required input fields for the parameters.
    - Click the “Run Procedure/View” button.

3. **Resetting the Database**:

   1. **Make the Script Executable** (if not already):
      ```bash
      chmod +x reinitialize_database.sh
      ```
      
   2. **Run the Script**:
      ```bash
      ./reinitialize_database.sh
      ```


## 3. Brief Explanation of Technologies Used

- **MySQL**:  
  Used as the relational database to store all data (users, employees, businesses, products, vans, etc.). MySQL also hosts the stored procedures and views, encapsulating the application’s logic.

- **Python**:  
  This front-end allows you to interact with the stored procedures and views without manually writing SQL queries, making the application more accessible.

## 4. Explanation of How Work Was Distributed Among Team Members (UI Only)

- **Pranav**:  
  Set up the initial `ui.py` structure and database connection logic.

- **Jayanth**:  
  Integrated procedure calls and parameter handling into `ui.py`.

- **Sai**:  
  Improved the user interface layout and message display in `ui.py`.

- **Aneesh**:  
  Tested `ui.py` thoroughly and helped refine the overall user experience.