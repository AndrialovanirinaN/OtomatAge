# OTOmatAGE – Estimating Fish Age from Otoliths

Welcome to **OTOmatAGE**, an interactive R Shiny application designed to help 
you discover the fascinating world of fish otoliths and learn how marine 
biologists determine the age of fish using artificial intelligence.

## 🌊 About the Project

Otoliths are small bones located in the inner ear of fish that act as natural 
biological recorders. Each year, a new layer is deposited, similar to tree rings. 
By studying these layers, scientists can estimate a fish's age and monitor population health.

This application focuses on the **European plaice** (*Pleuronectes platessa*), 
a common flatfish species. Using machine learning, **OTOmatAGE** automatically 
predicts the age of plaice from otolith images, providing an educational and 
interactive way to explore marine biology research.

## ✨ Key Features

- 🔬 **Interactive otolith viewer** – Examine high-resolution images of plaice otoliths
- 🧠 **AI-powered age estimation** – Compare your predictions with a K-Nearest Neighbors (KNN) model
- 🎯 **Educational game** – Test your skills against the AI and discover the real age
- 📚 **Scientific content** – Learn about otoliths, plaice, and why age determination matters
- 🎨 **Modern responsive design** – Built with bslib for a sleek, mobile-friendly interface

## 🛠️ Installation & Launch

### Requirements

Make sure you have **R (>= 4.x)** installed with the following packages:

```r
install.packages(c("shiny", "bslib", "shinyjs", "magick", "FNN", "DT"))
```

### Data Requirements

The application requires:
- `cleandata/model_age.RData` – Pre-trained model data and training set
- `data/img_app/` – Directory containing otolith images (TIF, PNG, JPG formats)
- `www/` – Directory with logos and partner images

### Run the App

1. Clone this repository or place all files in a single folder:

```
/OTOmatAGE
  ├── app.R
  ├── cleandata/
  │   └── model_age.RData
  ├── data/
  │   └── img_app/
  ├── data/
  │   └── basic_model.R
  │       └── [otolith images]
  └── www/
      ├── logo/
      │   ├── ifremer.png
      │   ├── ulco.png
      │   └── lisic.png
      ├── img/
      │   ├── plie.png
      │   └── otolith_plie.png
      └── partenaires/
          ├── par_off_1.png to par_off_7.png
          └── proj_1.png to proj_5.png
```

2. From R or RStudio, run:

```r
shiny::runApp("app.R")
```

## 📖 How It Works

1. **Load an otolith image** – The app randomly selects an otolith from the database
2. **Make your prediction** – Estimate the age (0-7+ years) based on what you see
3. **Compare results** – See how your estimate compares to the AI prediction and the real age
4. **Learn and repeat** – Load another otolith to continue practicing

The AI uses a **K-Nearest Neighbors (k=7)** algorithm trained on morphological features extracted from otolith images to predict fish age.

## 🔬 Why It Matters

Accurate age determination helps researchers:

- 📊 Monitor population growth and structure
- 🌡️ Understand climate impacts on marine ecosystems
- 🛡️ Protect marine resources for future generations
- 📈 Support sustainable fisheries management

## 📂 File Structure

- **app.R** – Main application file containing UI and server logic
- **cleandata/model_age.RData** – Training data and model features
- **data/img_app/** – Otolith image database
- **www/** – Static resources (logos, images)
- **README.md** – This documentation

## ⚙️ Configuration

The app includes several important configurations:

- **Maximum upload size:** 10MB (configurable via `options(shiny.maxRequestSize)`)
- **Image formats supported:** TIF, TIFF, PNG, JPG, JPEG
- **Model:** K-Nearest Neighbors with k=7
- **Age range:** 0 to 7+ years

## 🎓 Educational Use

**OTOmatAGE** is designed for:

- Educational demonstrations in marine biology
- Public outreach and science communication
- Training new age readers in fisheries research
- Interactive museum or aquarium exhibits

**Note:** This tool is for educational purposes only and should not replace expert validation in scientific studies.

## 💡 Technical Details

The application uses:

- **Image processing:** magick package for otolith image display
- **Machine learning:** FNN package for K-Nearest Neighbors prediction
- **UI framework:** bslib with Bootstrap theming
- **Reactivity:** Shiny reactive values for dynamic updates

## 👥 Partners & Credits

This project is supported by:

- **Ifremer** – Unité Halieutique Manche-Mer du Nord  
  Laboratoire Ressources Halieutiques – Pôle Sclérochronologie  
  [https://manchemerdunord.ifremer.fr/](https://manchemerdunord.ifremer.fr/)

- **ULCO** – Université du Littoral Côte d'Opale  
  Laboratoire d'Informatique Signal & Image de la Côte d'Opale (LISIC)  
  [https://www.univ-littoral.fr/](https://www.univ-littoral.fr/)  
  [https://www-lisic.univ-littoral.fr/](https://www-lisic.univ-littoral.fr/)

**Funding:**

- **CPER CornelIA (2021-2027)** – Co-construction responsable et durable d'une Intelligence Artificielle
- **IFSEA graduate school** – ANR-21-EXES-0011 (Agence Nationale de la Recherche)

## 📜 License

**MIT License**

Copyright © 2025 Nicolas Andrialovanirina, Emilie Poisson Caillault, Kélig Mahé

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED.

## ⚠️ Disclaimer

This application provides age estimations for educational purposes only. The AI predictions should not be used as the sole method for age determination in scientific research. Expert validation is always recommended for research and fisheries management applications.

## 💬 Contact

For questions, suggestions, or collaboration:

- **Email:** nicolasandrialova@gmail.com
- **GitHub:** [github.com/AndrialovanirinaN](https://github.com/AndrialovanirinaN)
