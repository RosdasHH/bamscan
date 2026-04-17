# BamScan

BamScan is a third-party companion app that integrates with the Bambuddy API to simplify the assignment of filament spools to AMS units using QR codes.

Instead of manually managing spool assignments, BamScan allows you to scan QR codes attached to physical spools and instantly map them to the correct AMS slot on your printer.

A [Bambuddy](https://github.com/maziggy/bambuddy) installation is required to use this app.

---

## 🚀 Features

- 📱 Scan filament spool QR codes with your phone
- 🧵 Assign filaments directly to AMS units
- 🧪 Manual assignment option (without QR codes)
- ⚙️ Uses Bambuddy as the backend
- 🧩 Supports MakerWorld spool insert system (QR-based workflow)

---

## 🧠 How it works

1. Configure your filaments in **Bambuddy**
2. Print spool inserts using the provided OpenSCAD model
3. Attach QR codes to your filament spools and assign it in the app
4. Use BamScan to scan a spool
5. Assign it to the correct AMS slot on your printer
6. Done — your AMS setup is now updated

---

## 🔧 Requirements

- Bambuddy setup
- Bambuddy compatible 3D printer with AMS
- Printed spool QR inserts (optional, any other unique qrcode will make it too)
