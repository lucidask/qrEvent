# QR Event App

QR Event App is a mobile application built using **Flutter** that allows users to:
- Create events with unique QR codes.
- Manage events with customizable ticket styles.
- Track the usage and sharing status of QR codes.
- Scan and validate QR codes in real-time.

## 🚀 Features

- **Event Management**: Create, edit, and delete events.
- **QR Code Generation**: Generate unique QR codes per event.
- **Customizable Tickets**: Choose between ticket styles: Classic, Centered, Minimal, Perforated.
- **Individual Ticket Customization**: Adjust colors, labels, images for Perforated tickets.
- **QR Code Validation**: Scan codes to validate their status (used/shared/expired).
- **Offline Support**: Full functionality without internet connection.
- **Hive Local Database**: Store events, QR codes, and customizations locally.
- **PDF Export**: Export QR codes and tickets as PDFs for printing.

## 🧱 Tech Stack

| Technology      | Purpose                             |
|-----------------|-------------------------------------|
| **Flutter**     | Mobile app development framework    |
| **Dart**        | Programming language for Flutter    |
| **Hive**        | Local NoSQL storage for offline data|
| **Provider**    | State management                   |
| **uuid**        | Unique ID generation for QR codes   |
| **qr_flutter**  | QR code generation                 |
| **google_mlkit_barcode_scanning** | QR code scanning |

## 📦 Project Structure

