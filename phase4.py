import tkinter as tk
from tkinter import ttk, messagebox
import mysql.connector

class BusinessSupplySystem:
    def __init__(self, root):
        self.root = root
        self.root.title("Business Supply System")
        self.connect_to_database()
        self.create_main_menu()

    def connect_to_database(self):
        try:
            self.conn = mysql.connector.connect(
                host="localhost",
                user="anyuser",
                password="password!1",
                database="business_supply"
            )
            self.cursor = self.conn.cursor()
        except mysql.connector.Error as err:
            messagebox.showerror("Database Connection Error", f"Error: {err}")

    def create_main_menu(self):
        menu_frame = ttk.Frame(self.root)
        menu_frame.pack(padx=10, pady=10)

        ttk.Button(menu_frame, text="Add Owner", command=self.show_add_owner).pack(pady=5)
        ttk.Button(menu_frame, text="Add Employee", command=self.show_add_employee).pack(pady=5)
        ttk.Button(menu_frame, text="Add Driver Role", command=self.show_add_driver_role).pack(pady=5)
        ttk.Button(menu_frame, text="Add Worker Role", command=self.show_add_worker_role).pack(pady=5)
        ttk.Button(menu_frame, text="Add Product", command=self.show_add_product).pack(pady=5)
        ttk.Button(menu_frame, text="Add Van", command=self.show_add_van).pack(pady=5)
        ttk.Button(menu_frame, text="Add Business", command=self.show_add_business).pack(pady=5)
        ttk.Button(menu_frame, text="Add Service", command=self.show_add_service).pack(pady=5)
        ttk.Button(menu_frame, text="Add Location", command=self.show_add_location).pack(pady=5)
        ttk.Button(menu_frame, text="Start Funding", command=self.show_start_funding).pack(pady=5)
        ttk.Button(menu_frame, text="Hire Employee", command=self.show_hire_employee).pack(pady=5)
        ttk.Button(menu_frame, text="Fire Employee", command=self.show_fire_employee).pack(pady=5)
        ttk.Button(menu_frame, text="Manage Service", command=self.show_manage_service).pack(pady=5)

    def show_add_owner(self):
        # Implement UI for adding owner
        pass

    def show_add_employee(self):
        # Implement UI for adding employee
        pass

    def show_add_driver_role(self):
        # Implement UI for adding driver role
        pass

    def show_add_worker_role(self):
        # Implement UI for adding worker role
        pass

    def show_add_product(self):
        # Implement UI for adding product
        pass

    def show_add_van(self):
        # Implement UI for adding van
        pass

    def show_add_business(self):
        # Implement UI for adding business
        pass

    def show_add_service(self):
        # Implement UI for adding service
        pass

    def show_add_location(self):
        # Implement UI for adding location
        pass

    def show_start_funding(self):
        # Implement UI for starting funding
        pass

    def show_hire_employee(self):
        # Implement UI for hiring employee
        pass

    def show_fire_employee(self):
        # Implement UI for firing employee
        pass

    def show_manage_service(self):
        # Implement UI for managing service
        pass

    def add_owner(self, username, first_name, last_name, address, birthdate):
        try:
            self.cursor.callproc('add_owner', (username, first_name, last_name, address, birthdate))
            self.conn.commit()
            messagebox.showinfo("Success", "Owner added successfully")
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"An error occurred: {err}")

    def add_employee(self, username, first_name, last_name, address, birthdate, taxID, hired, employee_experience, salary):
        try:
            self.cursor.callproc('add_employee', (username, first_name, last_name, address, birthdate, taxID, hired, employee_experience, salary))
            self.conn.commit()
            messagebox.showinfo("Success", "Employee added successfully")
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"An error occurred: {err}")

    def add_driver_role(self, username, licenseID, license_type, driver_experience):
        try:
            self.cursor.callproc('add_driver_role', (username, licenseID, license_type, driver_experience))
            self.conn.commit()
            messagebox.showinfo("Success", "Driver role added successfully")
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"An error occurred: {err}")

    def add_worker_role(self, username):
        try:
            self.cursor.callproc('add_worker_role', (username,))
            self.conn.commit()
            messagebox.showinfo("Success", "Worker role added successfully")
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"An error occurred: {err}")

    def add_product(self, barcode, name, weight):
        try:
            self.cursor.callproc('add_product', (barcode, name, weight))
            self.conn.commit()
            messagebox.showinfo("Success", "Product added successfully")
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"An error occurred: {err}")

    def add_van(self, id, tag, fuel, capacity, sales, driven_by):
        try:
            self.cursor.callproc('add_van', (id, tag, fuel, capacity, sales, driven_by))
            self.conn.commit()
            messagebox.showinfo("Success", "Van added successfully")
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"An error occurred: {err}")

    def add_business(self, long_name, rating, spent, location):
        try:
            self.cursor.callproc('add_business', (long_name, rating, spent, location))
            self.conn.commit()
            messagebox.showinfo("Success", "Business added successfully")
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"An error occurred: {err}")

    def add_service(self, id, long_name, home_base, manager):
        try:
            self.cursor.callproc('add_service', (id, long_name, home_base, manager))
            self.conn.commit()
            messagebox.showinfo("Success", "Service added successfully")
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"An error occurred: {err}")

    def add_location(self, label, x_coord, y_coord, space):
        try:
            self.cursor.callproc('add_location', (label, x_coord, y_coord, space))
            self.conn.commit()
            messagebox.showinfo("Success", "Location added successfully")
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"An error occurred: {err}")

    def start_funding(self, owner, amount, long_name, fund_date):
        try:
            self.cursor.callproc('start_funding', (owner, amount, long_name, fund_date))
            self.conn.commit()
            messagebox.showinfo("Success", "Funding started successfully")
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"An error occurred: {err}")

    def hire_employee(self, username, id):
        try:
            self.cursor.callproc('hire_employee', (username, id))
            self.conn.commit()
            messagebox.showinfo("Success", "Employee hired successfully")
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"An error occurred: {err}")

    def fire_employee(self, username, id):
        try:
            self.cursor.callproc('fire_employee', (username, id))
            self.conn.commit()
            messagebox.showinfo("Success", "Employee fired successfully")
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"An error occurred: {err}")

    def manage_service(self, username, id):
        try:
            self.cursor.callproc('manage_service', (username, id))
            self.conn.commit()
            messagebox.showinfo("Success", "Service manager updated successfully")
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"An error occurred: {err}")

if __name__ == "__main__":
    root = tk.Tk()
    app = BusinessSupplySystem(root)
    root.mainloop()