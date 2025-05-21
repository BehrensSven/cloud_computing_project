# Cloud Computing Projekt

Dieses Repository enthält zwei Hauptkomponenten:

- **`frontend/`** – ein statisches Vue.js-Frontend-Projekt  
- **`project/`** – ein Terraform-Projekt zur Bereitstellung der Cloud-Infrastruktur

Das Backend befindet sich in einem separaten Repository und wird beim Erstellen der EC2-Instanzen automatisch von Git geklont:  
🔗 [unternehmenswebseite-backend](https://github.com/BehrensSven/unternehmenswebseite-backend)

---

## 🚀 Einrichtung

**1. Wechsle in das `project/`-Verzeichnis:**

```bash
cd project
```
**2. Kopiere die `.env.example`-Datei und entferne die  `.example`-Endung:**

```bash
cp .env.example .env
```
**3. Füge in der `.env` deine AWS-Zugangsdaten ein:**

```bash
AWS_ACCESS_KEY_ID=dein_access_key
AWS_SECRET_ACCESS_KEY=dein_secret_key
```
**4. Kopiere `terraform.tfvars.example` und entferne `.example`:**

```bash
cp terraform.tfvars.example terraform.tfvars
```
**5. Setze ein sicheres Passwort für die Datenbank in `terraform.tfvars.`**

**6. Starte die Bereitstellung mit Terraform:**

```bash
terraform apply
```
