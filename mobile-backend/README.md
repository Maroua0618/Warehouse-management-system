# MobAI WMS - Mobile Backend

This directory contains the mobile backend APIs for the warehouse management system.

## Structure

```
mobile-backend/
├── employee/          # Employee mobile backend
│   ├── app/          # FastAPI application
│   ├── main.py       # Entry point
│   ├── run.py        # Server runner
│   └── ...
└── supervisor/       # Supervisor mobile backend (coming soon)
```

## Getting Started

### Employee Backend

Navigate to the employee folder and follow the instructions:

```bash
cd employee
pip install -r requirements.txt
python run.py
```

The employee API will be available at: http://localhost:8000

See [employee/README.md](employee/README.md) for detailed documentation.

### Supervisor Backend

Coming soon...

## Development

Each backend (employee/supervisor) runs independently with its own:
- Dependencies (requirements.txt)
- Configuration (.env)
- API documentation
- Port configuration

This separation allows for independent development and deployment of each interface.
