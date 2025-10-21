# 🐟 OTOmatAGE – AI-Powered Fish Age Estimation from Otoliths

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)
[![R](https://img.shields.io/badge/R-%3E%3D4.0-blue.svg)](https://www.r-project.org/)
[![Shiny](https://img.shields.io/badge/Shiny-App-brightgreen.svg)](https://shiny.rstudio.com/)

Welcome to **OTOmatAGE**, an interactive R Shiny application designed to help you discover the fascinating world of fish otoliths and learn how marine biologists determine the age of fish using artificial intelligence.

---

## 🌊 About the Project

**Otoliths** are small calcified structures located in the inner ear of fish that act as natural biological recorders. Each year, a new growth layer is deposited, similar to tree rings. By studying these annual rings, scientists can estimate a fish's age and monitor population health.

This application focuses on the **European plaice** (*Pleuronectes platessa*), a common flatfish species in the North Sea and English Channel. Using machine learning, **OTOmatAGE** automatically predicts the age of plaice from otolith images, providing an educational and interactive way to explore marine biology research.

---

## ✨ Key Features

- **🔬 Interactive Otolith Viewer**: Examine high-resolution images of plaice otoliths
- **🧠 AI-Powered Age Estimation**: K-Nearest Neighbors (KNN) model trained on morphological features
- **🎯 Educational Game Mode**: Test your skills against the AI and discover the real age
- **📊 Comparison Dashboard**: See how your predictions compare with AI results
- **📚 Scientific Content**: Learn about otoliths, plaice biology, and age determination importance
- **🎨 Modern Responsive Design**: Built with bslib for a sleek, mobile-friendly interface

---

## 🛠️ Installation & Setup

### Prerequisites

Ensure you have **R (≥ 4.0)** installed on your system. You can download it from [CRAN](https://cran.r-project.org/).

### Required R Packages

Install the necessary packages by running:

```r
install.packages(c(
  "shiny", 
  "bslib", 
  "shinyjs", 
  "magick", 
  "FNN", 
  "DT"
))
```

### Data Requirements

The application requires the following data structure:

- `cleandata/model_age.RData` — Pre-trained model data and training set
- `data/img_app/` — Directory containing otolith images (TIF, PNG, JPG formats)
- `www/` — Directory with logos and partner images

### Clone the Repository

```bash
git clone https://github.com/AndrialovanirinaN/OTOmatAGE.git
cd OTOmatAGE
```

### Project Structure

```
OTOmatAGE/
│
├── app.R                    # Main application file
│
├── cleandata/
│   └── model_age.RData      # Pre-trained model and training data
│
├── data/
│   └── img_app/             # Otolith image database
│       └── [otolith images] # TIF, PNG, JPG formats
│
└── www/
    ├── logo/                # Partner logos
    │   ├── ifremer.png
    │   ├── ulco.png
    │   └── lisic.png
    ├── img/                 # Educational images
    │   ├── plie.png
    │   └── otolith_plie.png
    └── partenaires/         # Partner and project images
        ├── par_off_1.png to par_off_7.png
        └── proj_1.png to proj_5.png
```

### Run the Application

Launch the app from R or RStudio:

```r
shiny::runApp("app.R")
```

The application will open in your default web browser.

---

## 🎮 How to Use

1. **📸 Load an Otolith Image**: The app randomly selects an otolith from the database
2. **🤔 Make Your Prediction**: Estimate the age (0-7+ years) based on the visible growth rings
3. **🤖 Get AI Prediction**: Let the machine learning model analyze the otolith
4. **📊 Compare Results**: See how your estimate compares to the AI prediction and the real age
5. **🔄 Practice More**: Load another otolith to continue learning and improving

### Understanding the Results

- **Your Prediction**: Your visual estimate based on ring counting
- **AI Prediction**: K-Nearest Neighbors model prediction (k=7)
- **True Age**: The actual age determined by expert readers
- **Accuracy Score**: How close your prediction was to reality

---

## 🤖 Machine Learning Model

The application uses a **K-Nearest Neighbors (k=7)** algorithm trained on morphological features extracted from otolith images.

### Model Details

- **Algorithm**: K-Nearest Neighbors (KNN)
- **K Value**: 7 neighbors
- **Features**: Morphological characteristics from otolith images
- **Age Range**: 0 to 7+ years
- **Training Data**: Expert-validated age readings from plaice otoliths

### Configuration

- **Maximum Upload Size**: 10MB (configurable via `options(shiny.maxRequestSize)`)
- **Supported Image Formats**: TIF, TIFF, PNG, JPG, JPEG
- **Image Processing**: magick package for display and manipulation
- **Prediction Engine**: FNN package for KNN implementation

---

## 🔬 Why Fish Age Matters

Accurate age determination helps researchers:

- **📊 Monitor Population Dynamics**: Track growth rates and population structure
- **🌡️ Assess Climate Impacts**: Understand how environmental changes affect marine ecosystems
- **🎣 Support Sustainable Fisheries**: Inform management decisions and quotas
- **🛡️ Protect Marine Resources**: Ensure long-term sustainability for future generations
- **📈 Predict Stock Recruitment**: Model future population trends

---

## 🎓 Educational Use Cases

**OTOmatAGE** is designed for:

- 🏫 **Educational Demonstrations**: Marine biology and ecology courses
- 🌍 **Public Outreach**: Science communication and citizen engagement
- 🔬 **Training Programs**: Preparing new age readers in fisheries research
- 🏛️ **Interactive Exhibits**: Museum and aquarium installations
- 👨‍🎓 **Student Projects**: Hands-on learning about marine science and AI

> **⚠️ Important Note**: This tool is for educational purposes only and should not replace expert validation in scientific studies or fisheries management decisions.

---

## 💡 Technical Implementation

The application leverages:

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Image Processing** | magick package | High-quality otolith image display |
| **Machine Learning** | FNN package | K-Nearest Neighbors prediction |
| **UI Framework** | bslib | Modern Bootstrap theming |
| **Reactivity** | Shiny reactive values | Dynamic user interaction |
| **Data Tables** | DT package | Interactive result displays |

---

## 👥 Partners & Credits

This project is a collaborative effort supported by:

### Research Institutions

**ULCO** – Université du Littoral Côte d'Opale  
Laboratoire d'Informatique Signal & Image de la Côte d'Opale (LISIC)  
🔗 [https://www.univ-littoral.fr/](https://www.univ-littoral.fr/)  
🔗 [https://www-lisic.univ-littoral.fr/](https://www-lisic.univ-littoral.fr/)

**Ifremer** – Institut Français de Recherche pour l'Exploitation de la Mer  
Unité Halieutique Manche-Mer du Nord  
Laboratoire Ressources Halieutiques – Pôle Sclérochronologie  
🔗 [https://manchemerdunord.ifremer.fr/](https://manchemerdunord.ifremer.fr/)

### Funding

This project is funded by:

- **CPER CornelIA (2021-2027)**: Co-construction responsable et durable d'une Intelligence Artificielle
- **IFSEA Graduate School**: ANR-21-EXES-0011 (Agence Nationale de la Recherche)

---

## 📄 License

This project is released under the **MIT License**.

```
MIT License

Copyright © 2025 Nicolas Andrialovanirina, Emilie Poisson Caillault, Kélig Mahé

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## ⚠️ Disclaimer

This application provides age estimations for **educational purposes only**. The AI predictions should not be used as the sole method for age determination in scientific research. 

**Expert validation is always recommended for:**
- Scientific publications
- Fisheries stock assessments
- Management decisions
- Regulatory compliance

The model's accuracy depends on image quality and similarity to the training dataset.

---

## 📬 Contact & Contributions

**Project Team:**
- Nicolas Andrialovanirina
- Emilie Poisson Caillault
- Kélig Mahé

### Get in Touch

- 📧 Email: [nicolasandrialova@gmail.com](mailto:nicolasandrialova@gmail.com)
- 🐙 GitHub: [@AndrialovanirinaN](https://github.com/AndrialovanirinaN)
