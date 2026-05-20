@echo off
echo Installing Mobile Backend Dependencies...
echo.

pip install -r requirements.txt

echo.
echo Installation complete!
echo.
echo To run the server:
echo   python run.py
echo.
echo Or:
echo   uvicorn main:app --reload
echo.
pause
