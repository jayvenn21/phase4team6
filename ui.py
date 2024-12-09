import tkinter as tk
from tkinter import ttk, messagebox
import mysql.connector
from datetime import datetime


# Database connection parameters - change to reflect your user system
DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASSWORD = 'password'
DB_NAME = 'business_supply'

# Connect to the database - adjust if using different credentials
def get_connection():
    conn = mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME
    )
    return conn

# Stored procedures alongside relevant procedures
procedures = {
    "add_owner": [
        ("ip_username", "str"),
        ("ip_first_name", "str"),
        ("ip_last_name", "str"),
        ("ip_address", "str"),
        ("ip_birthdate", "date")
    ],
    "add_employee": [
        ("ip_username", "str"),
        ("ip_first_name", "str"),
        ("ip_last_name", "str"),
        ("ip_address", "str"),
        ("ip_birthdate", "date"),
        ("ip_taxID", "str"),
        ("ip_hired", "date"),
        ("ip_employee_experience", "int"),
        ("ip_salary", "int")
    ],
    "add_driver_role": [
        ("ip_username", "str"),
        ("ip_licenseID", "str"),
        ("ip_license_type", "str"),
        ("ip_driver_experience", "int")
    ],
    "add_worker_role": [
        ("ip_username", "str")
    ],
    "add_product": [
        ("ip_barcode", "str"),
        ("ip_name", "str"),
        ("ip_weight", "int")
    ],
    "add_van": [
        ("ip_id", "str"),
        ("ip_tag", "int"),
        ("ip_fuel", "int"),
        ("ip_capacity", "int"),
        ("ip_sales", "int"),
        ("ip_driven_by", "str")
    ],
    "add_business": [
        ("ip_long_name", "str"),
        ("ip_rating", "int"),
        ("ip_spent", "int"),
        ("ip_location", "str")
    ],
    "add_service": [
        ("ip_id", "str"),
        ("ip_long_name", "str"),
        ("ip_home_base", "str"),
        ("ip_manager", "str")
    ],
    "add_location": [
        ("ip_label", "str"),
        ("ip_x_coord", "int"),
        ("ip_y_coord", "int"),
        ("ip_space", "int")
    ],
    "start_funding": [
        ("ip_owner", "str"),
        ("ip_amount", "int"),
        ("ip_long_name", "str"),
        ("ip_fund_date", "date")
    ],
    "hire_employee": [
        ("ip_username", "str"),
        ("ip_id", "str")
    ],
    "fire_employee": [
        ("ip_username", "str"),
        ("ip_id", "str")
    ],
    "manage_service": [
        ("ip_username", "str"),
        ("ip_id", "str")
    ],
    "takeover_van": [
        ("ip_username", "str"),
        ("ip_id", "str"),
        ("ip_tag", "int")
    ],
    "load_van": [
        ("ip_id", "str"),
        ("ip_tag", "int"),
        ("ip_barcode", "str"),
        ("ip_more_packages", "int"),
        ("ip_price", "int")
    ],
    "refuel_van": [
        ("ip_id", "str"),
        ("ip_tag", "int"),
        ("ip_more_fuel", "int")
    ],
    "drive_van": [
        ("ip_id", "str"),
        ("ip_tag", "int"),
        ("ip_destination", "str")
    ],
    "purchase_product": [
        ("ip_long_name", "str"),
        ("ip_id", "str"),
        ("ip_tag", "int"),
        ("ip_barcode", "str"),
        ("ip_quantity", "int")
    ],
    "remove_product": [
        ("ip_barcode", "str")
    ],
    "remove_van": [
        ("ip_id", "str"),
        ("ip_tag", "int")
    ],
    "remove_driver_role": [
        ("ip_username", "str")
    ],
    # Views
    "display_owner_view": [],
    "display_employee_view": [],
    "display_driver_view": [],
    "display_location_view": [],
    "display_product_view": [],
    "display_service_view": []
}

class ProcedureRunnerApp:
    def __init__(self, master):
        self.master = master
        master.title("Stored Procedure Runner")
        
        self.proc_label = tk.Label(master, text="Select Procedure/View:")
        self.proc_label.grid(row=0, column=0, padx=5, pady=5, sticky='e')
        
        self.proc_var = tk.StringVar()
        self.proc_combo = ttk.Combobox(master, textvariable=self.proc_var, values=list(procedures.keys()), state='readonly')
        self.proc_combo.grid(row=0, column=1, padx=5, pady=5, sticky='w')
        self.proc_combo.bind("<<ComboboxSelected>>", self.on_proc_selected)
        
        self.params_frame = tk.Frame(master)
        self.params_frame.grid(row=1, column=0, columnspan=2, padx=5, pady=5, sticky='w')
        
        self.run_button = tk.Button(master, text="Run Procedure/View", command=self.run_procedure)
        self.run_button.grid(row=2, column=0, columnspan=2, padx=5, pady=5)
        
        self.param_entries = []
    
    def on_proc_selected(self, event):
        for widget in self.params_frame.winfo_children():
            widget.destroy()
        self.param_entries = []
        
        proc_name = self.proc_var.get()
        params = procedures[proc_name]
        
        if len(params) == 0:
            label = tk.Label(self.params_frame, text="(No parameters required)")
            label.pack(anchor='w')
        else:
            for p in params:
                pname, ptype = p
                frm = tk.Frame(self.params_frame)
                frm.pack(anchor='w', pady=2)
                lbl = tk.Label(frm, text=f"{pname} ({ptype}):")
                lbl.pack(side='left')
                entry = tk.Entry(frm, width=50)
                entry.pack(side='left')
                self.param_entries.append((pname, ptype, entry))
    
    def run_procedure(self):
        proc_name = self.proc_var.get()
        if not proc_name:
            messagebox.showerror("Error", "Please select a procedure or view first.")
            return
        
        params = procedures[proc_name]
        
        if len(params) == 0:
            self.run_view(proc_name)
            return
        
        call_args = []
        for (pname, ptype, entry) in self.param_entries:
            val = entry.get().strip()
            if val == "":
                messagebox.showerror("Error", f"Parameter {pname} is required.")
                return
            if ptype == "int":
                try:
                    val = int(val)
                except:
                    messagebox.showerror("Error", f"Parameter {pname} must be an integer.")
                    return
            elif ptype == "date":
                try:
                    datetime.strptime(val, "%Y-%m-%d")
                except:
                    messagebox.showerror("Error", f"Parameter {pname} must be in format YYYY-MM-DD.")
                    return
            call_args.append(val)
        
        try:
            conn = get_connection()
            cursor = conn.cursor()
            placeholders = ", ".join(["%s"] * len(call_args))
            query = f"CALL {proc_name}({placeholders})"
            cursor.execute(query, tuple(call_args))
            conn.commit()
            
            messagebox.showinfo("Success", f"Procedure {proc_name} executed successfully.")
            
        except mysql.connector.Error as err:
            messagebox.showerror("Database Error", str(err))
        finally:
            cursor.close()
            conn.close()
    
    def run_view(self, view_name):
        try:
            conn = get_connection()
            cursor = conn.cursor()
            cursor.execute(f"SELECT * FROM {view_name}")
            rows = cursor.fetchall()
            columns = [desc[0] for desc in cursor.description]
            
            view_window = tk.Toplevel(self.master)
            view_window.title(view_name)
            
            tree = ttk.Treeview(view_window, columns=columns, show='headings')
            for col in columns:
                tree.heading(col, text=col)
                tree.column(col, width=100)
            for r in rows:
                tree.insert("", tk.END, values=r)
            tree.pack(fill='both', expand=True)
            
        except mysql.connector.Error as err:
            messagebox.showerror("Database Error", str(err))
        finally:
            cursor.close()
            conn.close()


if __name__ == "__main__":
    root = tk.Tk()
    app = ProcedureRunnerApp(root)
    root.mainloop()