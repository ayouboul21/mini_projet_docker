# Student List - Dockerized Application

## 📌 Project Overview
This mini project aims to **containerize a Python Flask API** and a **PHP-based frontend** using **Docker**. The backend serves student data from a JSON file, while the frontend displays this data via an API request. The application is deployed using **Docker Compose**, with an optional **private Docker registry** for storing built images.

---

## 🛠️ Configuration Files Explanation

### **1️⃣ Dockerfile (Backend API Configuration)**
**Location:** `./Dockerfile`

This file defines how the **Flask-based API** should be built as a Docker image.

#### **📌 Key Components**:
- **`FROM python:3.8-buster`** → Uses the Python 3.8 image as the base.
- **`LABEL maintainer="Your Name <your.email@example.com>"`** → Specifies the maintainer.
- **`WORKDIR /`** → Sets the working directory inside the container.
- **`COPY student_age.py requirements.txt /`** → Copies source files into the container.
- **`RUN pip3 install -r /requirements.txt`** → Installs necessary Python dependencies.
- **`VOLUME /data`** → Creates a persistent volume for the student data JSON file.
- **`EXPOSE 5000`** → Exposes port **5000** for API access.
- **`CMD ["python3", "./student_age.py"]`** → Starts the Flask server when the container runs.

**💡 Its Purpose:** Creates a **Docker image** for the backend API.

---

### **2️⃣ docker-compose.yml (Multi-Container Deployment)**
**Location:** `./docker-compose.yml`

This file defines and runs both the **backend (API)** and **frontend (PHP Website)** containers.

#### **📌 Key Components**:
```yaml
version: "3.8"
services:
  api:
    image: student_api  # Uses the API image built from Dockerfile
    ports:
      - "5000:5000"
    volumes:
      - ./student_age.json:/data/student_age.json
    networks:
      - student_network
  
  website:
    image: php:apache
    ports:
      - "8080:80"
    volumes:
      - ./website:/var/www/html
    depends_on:
      - api
    networks:
      - student_network

networks:
  student_network:
    driver: bridge
```

**💡 Purposes:**
- **Runs the API container (`api`)** and exposes it on port **5000**.
- **Runs the frontend container (`website`)** and exposes it on port **8080**.
- **Links both services** via a **Docker network** (`student_network`).
- **Ensures API starts before frontend** using `depends_on`.

---

### **3️⃣ docker-compose-registry.yml (Private Docker Registry)**
**Location:** `./docker-compose-registry.yml`

This file sets up a **private Docker registry** to store and manage images.

#### **📌 Key Components**:
```yaml
version: "3.8"
services:
  registry:
    image: registry:2
    ports:
      - "5001:5000"
  
  registry-ui:
    image: joxit/docker-registry-ui
    environment:
      - REGISTRY_TITLE=Student Registry
      - REGISTRY_URL=http://registry:5000
    ports:
      - "5002:80"
    depends_on:
      - registry
```

**💡 Purpose:**
- **Sets up a local registry** (`registry`) to store images.
- **Provides a web UI** (`registry-ui`) for managing images at **http://localhost:5002**.

---

### **4️⃣ student_age.json (Data Storage)**
**Location:** `./student_age.json`

This file contains **example student data** in JSON format.

#### **📌 Content**:
```json
{
    "Ahmed": "20",
    "Meryem": "23",
    "Amine": "20",
    "Hiba": "21",
    "Sara": "23",
    "Omar": "20"
}

```

- **Is mounted inside the container** (`/data/student_age.json`).

---

### **5️⃣ student_age.py (Backend API Logic)**
**Location:** `./student_age.py`

This Python script runs the **Flask API** that serves student data.

#### **📌 Key Components**:
```python
#!flask/bin/python
from flask import Flask, jsonify
from flask import abort
from flask import make_response
from flask import request
from flask import url_for
from flask_httpauth import HTTPBasicAuth
from flask import g, session, redirect, url_for
from flask_simpleldap import LDAP
import json
import os

auth = HTTPBasicAuth()
app = Flask(__name__)
app.debug = True

@auth.get_password
def get_password(username):
    if username == 'root':
        return 'root'
    return None

@auth.error_handler
def unauthorized():
    return make_response(jsonify({'error': 'Unauthorized access'}), 401)

# Charger les données au démarrage (avec gestion du fichier et conversion des âges)
try:
    student_age_file_path = os.environ.get('student_age_file_path', '/data/student_age.json')
except NameError:
    student_age_file_path  = '/data/student_age.json'

student_age_file = open(student_age_file_path, "r")
student_age = json.load(student_age_file)

@app.route('/supmit/api/v1.0/get_student_ages', methods=['GET'])
@auth.login_required
def get_student_ages():
    return jsonify({'student_ages': student_age })

@app.route('/supmit/api/v1.0/get_student_ages/<student_name>', methods=['GET'])
@auth.login_required
def get_student_age(student_name):
    if student_name not in student_age :
        abort(404)
    if student_name in student_age :
      age = student_age[student_name]
      del student_age[student_name]
      with open(student_age_file_path, 'w') as student_age_file:
        json.dump(student_age, student_age_file, indent=4, ensure_ascii=False)
    return age 
@app.errorhandler(404)
def not_found(error):
    return make_response(jsonify({'error': 'Not found'}), 404)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
```

**💡 Purpose:**
- **Reads student data** from `student_age.json`.
- **Serves the data** as a JSON response.
- **Runs on port 5000** inside the container.

---

### **6️⃣ index.php (Frontend UI for Student List)**
**Location:** `./website/index.php`

This PHP file fetches student data from the API and displays it.

**💡 Purpose:**
- **Parses JSON response** into an array.
- **Displays the student list** on the webpage.

---

## 🚀 **How to Run the Project**
### **1️⃣ Build and Run the API (Manually)**
```powershell
docker build -t student_api .
docker run -d --name student_api_container -p 5000:5000 -v ${PWD}\student_age.json:/data/student_age.json student_api
```

### **2️⃣ Run the Whole Application with `docker-compose`**
```powershell
docker-compose up -d
```
Access the frontend at: [http://localhost:8080](http://localhost:8080) (After setting up the application on your machine)

### **3️⃣ Settting Up a Private Docker Registry**
```powershell
docker-compose -f docker-compose-registry.yml up -d
```
Check the UI at: [http://localhost:5002](http://localhost:5002) (After setting up the registry on your machine)



