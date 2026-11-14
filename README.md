# ServiceConnect

**Local Service Booking Platform**  
A responsive web app for finding local service professionals, requesting appointments, and managing work from booking through review.

> ServiceConnect includes customer, provider, and administrator workflows. Run locally with SQLite for a quick start, or configure MySQL for a shared deployment. Providers need administrator approval before listing bookable services.

## What is included

### Customer experience
- Create an account and manage basic profile details.
- Search available services by name, category, and city.
- View service details, provider information, experience, and ratings.
- Request a future appointment with an address and problem description.
- Track booking history, cancel eligible bookings, and review completed work.

### Service provider workflow
- Register a provider account and submit a business profile for approval.
- After approval, create, update, and deactivate service listings.
- Set weekly availability by day and time.
- Review booking requests, accept or reject them, and update accepted work through In Progress and Completed.
- View customer reviews and the provider's average rating.

### Administrator workflow
- Review customer, provider, booking, and category totals on the dashboard.
- Approve providers and activate or deactivate provider accounts.
- View users and change account active status.
- Create and deactivate service categories.
- View all bookings and remove reviews when needed.
- View booking status analytics in the dashboard.

### Booking workflow
- A customer requests a service, date, time, and address.
- The backend checks the provider, service, date, availability, and overlapping appointments.
- The backend calculates duration and price from the service record.
- The provider accepts or rejects the request. Accepted bookings can move to In Progress and then Completed.
- The customer can review completed work. Each booking can have one review.
- Pending and accepted bookings can be cancelled by the customer.
- Booking history keeps the service name, agreed price, and address if the account or service is later deactivated.

## Security checklist before public deployment

- Replace the example `JWT_SECRET` and admin password in `backend/.env` with private, strong values.
- Configure the production database URL and exact frontend origin in `CORS_ORIGINS`.
- Serve the application over HTTPS and set `COOKIE_SECURE=true`.
- Keep `.env` out of Git. Never publish database credentials or production secrets.
- Admin accounts are initialized from the backend environment; public registration cannot create admin accounts.
- Role and resource ownership are checked by the API. Prices and customer/provider IDs are derived or validated on the backend.
- Use a managed database with backups for shared use. SQLite is intended for local development, not a multi-instance production deployment.
- Before a larger production launch, add schema migrations, rate limiting, audit logging, account recovery, monitoring, and CSRF defenses for cross-site cookie deployments.

## Architecture

```mermaid
flowchart LR
  Customer[Customer browser] --> Web[Static ServiceConnect pages]
  Provider[Provider browser] --> Web
  Admin[Admin browser] --> Web
  Web --> API[FastAPI REST API]
  API --> Auth[JWT session and role checks]
  API --> ORM[SQLAlchemy models and booking rules]
  ORM --> DB[(SQLite local or MySQL)]
```

The browser uses shared JavaScript helpers to call the API under `/api`. The API owns authentication, authorization, input validation, service price calculation, booking checks, and review rules. SQLAlchemy creates missing tables during API startup and seeds the initial service categories. A MySQL Workbench schema is included in `backend/schema.sql`.

## 1. Run locally in VS Code

Install Python 3.10 or newer. You do not need MySQL for the local SQLite setup.

1. Extract the project ZIP and open the extracted project folder in VS Code (**File → Open Folder…**).
2. Open **Terminal → New Terminal** and run:

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
Copy-Item .env.example .env
```

Use `python -m pip` if Windows blocks the `pip.exe` launcher. If PowerShell blocks virtual environment activation, run `Set-ExecutionPolicy -Scope Process Bypass` in that terminal and activate again.

3. Open `backend/.env` in VS Code and set the local database and private credentials:

```dotenv
DATABASE_URL=sqlite:///./serviceconnect.db
JWT_SECRET=replace-with-a-long-random-secret
JWT_EXPIRE_MINUTES=60
CORS_ORIGINS=http://localhost:5500,http://127.0.0.1:5500
COOKIE_SECURE=false
COOKIE_SAMESITE=lax
ADMIN_EMAIL=admin@serviceconnect.local
ADMIN_PASSWORD=replace-with-a-strong-password
```

Generate a random JWT secret from PowerShell with:

```powershell
python -c "import secrets; print(secrets.token_urlsafe(48))"
```

4. Start the API in the first terminal, still in `backend`:

```powershell
python -m uvicorn app.main:app --reload
```

The API is at `http://127.0.0.1:8000`. API documentation is at `http://127.0.0.1:8000/docs`. The first start creates tables, six service categories, and the configured admin account if it does not already exist.

5. Open **Terminal → New Terminal** for a second terminal. From the project root (the folder containing `frontend`), run:

```powershell
python -m http.server 5500 --directory frontend
```

6. Open `http://127.0.0.1:5500` in a browser. Keep both terminals running. Do not open the HTML files using `file://`.

### First walkthrough

1. Register a customer account.
2. Register a second account as a provider.
3. Sign in with the admin email and password from `.env`, then approve the provider in **Providers**.
4. Sign in as the provider, set availability, and add a service.
5. Sign in as the customer, find the service, and request a future appointment.
6. As the provider, accept the booking, move it to In Progress, then Completed.
7. As the customer, submit a review for the completed booking.

## 2. Use MySQL with Workbench

SQLite is the quick-start database. To use MySQL instead:

1. Start MySQL Server and connect using MySQL Workbench.
2. Open `backend/schema.sql` in Workbench and execute it to create `serviceconnect_db` and its tables.
3. Create an application database user and grant it access to `serviceconnect_db`.
4. Update `DATABASE_URL` in `backend/.env`. Example:

```dotenv
DATABASE_URL=mysql+pymysql://serviceconnect:your-password@localhost:3306/serviceconnect_db
```

5. Restart the backend. Keep MySQL credentials out of source control. If a password contains URL-reserved characters, encode those characters in the database URL.

## 3. Run tests

With the virtual environment active, open a terminal in `backend` and run:

```powershell
python -m pytest tests -q
```

The tests cover health and category endpoints, registration and login, role authorization, provider approval, service creation, availability routes, past-date rejection, server-calculated booking price/duration, overlapping booking rejection, cancellation, status transitions, and review uniqueness.

## 4. Use the Postman collection

Import `postman/ServiceConnect.postman_collection.json` into Postman. Set the `baseUrl` collection variable if the API is not at `http://127.0.0.1:8000`. After login, copy `access_token` into the `token` variable for protected requests.

## 5. Deploy

### Backend

Deploy the `backend` directory as a Python web service. Example commands:

- Build: `pip install -r requirements.txt`
- Start: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

Set production environment variables for `DATABASE_URL`, `JWT_SECRET`, `JWT_EXPIRE_MINUTES`, `CORS_ORIGINS`, `COOKIE_SECURE`, `COOKIE_SAMESITE`, `ADMIN_EMAIL`, and `ADMIN_PASSWORD`. Use a managed MySQL database and HTTPS.

### Frontend

Publish the contents of `frontend/` to a static host. Before deployment, change the default API URL in `frontend/js/api.js` from `http://127.0.0.1:8000/api` to the deployed API URL ending in `/api`. Add the frontend's exact origin to `CORS_ORIGINS`.

For a cross-site frontend and API using cookies, set `COOKIE_SAMESITE=none` and `COOKIE_SECURE=true` over HTTPS. The current frontend also sends the short-lived session token in an Authorization header.

## Data and production notes

- Service categories are seeded on backend startup.
- Provider availability uses weekdays numbered Monday `0` through Sunday `6`.
- When a provider has configured availability, a requested appointment must fit within one of the enabled time ranges. Configure provider hours before taking bookings.
- MySQL booking creation locks the provider row while checking for overlapping active bookings. The API checks overlaps again when a provider accepts a request.
- No payment processing, email notifications, image uploads, complaints, or password reset flows are included.
- SQLAlchemy `create_all` initializes tables on startup. Alembic migrations are not included.
- TestClient tests were run with SQLite. A live MySQL server and browser automation have not been tested as part of this project.

## Project layout

```text
servicemanager/
├── README.md
├── backend/
│   ├── .env.example
│   ├── requirements.txt
│   ├── schema.sql
│   ├── app/
│   │   ├── main.py              # Models, schemas, API routes, and business rules
│   │   └── __main__.py
│   └── tests/test_api.py
├── frontend/
│   ├── index.html
│   ├── login.html
│   ├── register.html
│   ├── services.html
│   ├── service-details.html
│   ├── customer/
│   ├── provider/
│   ├── admin/
│   ├── css/style.css
│   └── js/                      # API, auth, booking, and dashboard helpers
└── postman/ServiceConnect.postman_collection.json
```

## Useful commands

Run these from the `backend` directory with the virtual environment activated:

```powershell
python -m uvicorn app.main:app --reload  # Start API with auto-reload
python -m pytest tests -q                # Run backend tests
```

Run the static frontend server from the project root:

```powershell
python -m http.server 5500 --directory frontend
```

## Troubleshooting

- **`pip.exe` is blocked:** use `python -m pip install -r requirements.txt` from `backend`.
- **`python` is not recognized:** install Python 3.10 or later, enable the Python PATH option in its installer, then reopen VS Code.
- **PowerShell blocks activation:** run `Set-ExecutionPolicy -Scope Process Bypass`, then activate `.venv` again.
- **Frontend cannot reach API:** confirm the backend terminal is still running at port 8000 and that the frontend is opened at port 5500.
- **CORS error:** ensure the frontend URL is listed in `CORS_ORIGINS`, then restart the backend.
- **Database connection error:** confirm `DATABASE_URL` points to SQLite for the local setup, or that MySQL is running and its database/user credentials are correct.
- **Provider cannot add a service:** sign in as an administrator and approve the provider first.
- **No services show up:** confirm a provider is approved and has at least one active service.

## License

No license has been selected. Add a `LICENSE` file before publishing or redistributing the project as open source.
