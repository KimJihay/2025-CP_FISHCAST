# How to Run Backend Locally & Connect from Mobile

Since the Render free tier has memory limitations for loading heavy models, running the backend locally is a better option for project showcases. Follow these steps to connect your Flutter app (running on a physical phone) to your computer's local backend.

## 1. Network Requirements
*   **Crucial:** Your Computer and your Phone **MUST** be connected to the **same Wi-Fi network**.
*   If you are using mobile data on your phone, this will **not** work.

## 2. Find Your Computer's Local IP Address

You need the IP address assigned to your computer by your router.

### Windows
1. Open Command Prompt (`cmd` or PowerShell).
2. Type `ipconfig` and press Enter.
3. Look for **IPv4 Address** under your Wi-Fi adapter (e.g., `Wireless LAN adapter Wi-Fi`).
   *   It usually looks like `192.168.1.5` or `192.168.0.10`.

### macOS / Linux
1. Open Terminal.
2. Type `ifconfig | grep "inet " | grep -v 127.0.0.1` (or just `ip a` on Linux).
3. Look for the IP address associated with `en0` or `wlan0`.
   *   It usually looks like `192.168.1.x`.

## 3. Update Flutter Configuration

I have centralized the API URL configuration. You only need to change it in one place.

1.  Open the file: `lib/core/utils/constants.dart`
2.  Locate `kBaseUrl`.
3.  Replace the Render URL with your local IP address and port (usually `5000` or `8000`).

```dart
// lib/core/utils/constants.dart

// ❌ OLD (Render):
// const kBaseUrl = 'https://fishcast-backend-coq5.onrender.com';

// ✅ NEW (Local):
// Replace 192.168.1.5 with YOUR specific IP found in Step 2.
// Ensure the port (5000) matches what your backend runs on.
const kBaseUrl = 'http://192.168.1.5:5000'; 
```

**Note:** If you are using the **Android Emulator** on your PC instead of a real phone, use:
```dart
const kBaseUrl = 'http://10.0.2.2:5000';
```

## 4. Run the Backend Server (Crucial Step)

By default, many servers (like Flask or Django) run on `localhost` (127.0.0.1). This prevents external devices (like your phone) from connecting. You must force the server to listen on **all network interfaces** (`0.0.0.0`).

### If using Flask (Python)
Run your server with the `--host` flag:
```bash
flask run --host=0.0.0.0 --port=5000
```
*Or if running a Python script directly:*
```python
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### If using FastAPI / Uvicorn
```bash
uvicorn main:app --host 0.0.0.0 --port 5000
```

### If using Django
```bash
python manage.py runserver 0.0.0.0:8000
```
*(Note: If using Django, update `kBaseUrl` port to 8000).*

## 5. Troubleshooting Connection Issues

If the app hangs or throws a connection error:

1.  **Firewall:** Windows Firewall often blocks incoming connections to Python.
    *   **Quick Fix:** Temporarily turn off "Private Network" firewall to test.
    *   **Better Fix:** Allow the specific port (5000) through the firewall settings (Inbound Rules).
2.  **HTTPS vs HTTP:** Local servers usually run on `http://`, not `https://`. Ensure your `kBaseUrl` starts with `http://`.
3.  **Correct IP:** IP addresses can change if you restart your router. Double-check `ipconfig` if it stops working the next day.
