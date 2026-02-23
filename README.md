# Cost-Sensitive Decision Tree for Mortality Prediction

This repository contains MATLAB code for training, optimizing, and evaluating a
**cost-sensitive decision tree (DT)** model to predict in-hospital mortality
using routinely collected clinical biomarkers.

The code accompanies a scientific manuscript and is intended to promote
**transparency, reproducibility, and methodological clarity**.

---

## Overview

The workflow implemented in this repository includes:

- Patient-wise random partitioning into **training (70%) and test (30%)** sets
- **10-fold cross-validation** on the training set for hyperparameter tuning
- Optimization of:
  - Tree complexity (maximum number of splits)
  - Misclassification cost for nonsurvivors (false negatives)
- Model evaluation on an **independent test set**
- Assessment of:
  - Sensitivity, specificity, accuracy, balanced accuracy
  - Area under the ROC curve (AUC) with **95% confidence intervals**
  - Model calibration
  - Terminal-node composition and error rates
  - Predictor importance

---

## Repository contents

> ⚠️ **Note**  
> The dataset used in the manuscript is not publicly shared due to privacy
> restrictions. Users must provide their own dataset with the same structure to
> run the code.

---

## Requirements

- MATLAB (R2019a or later recommended)
- Statistics and Machine Learning Toolbox

---

## Data format

The input dataset (`mSOFA_DT.mat`) must contain a MATLAB table named `data` with:

- A binary outcome variable:
  - `M2D` (0 = survivor, 1 = nonsurvivor)
- Predictor variables including (but not limited to):
  - Lactate
  - Glasgow Coma Scale (GCS)
  - SaFi ratio
  - Creatinine
  - Mean arterial pressure (MAP)

The predictors used by the model are selected internally by column index and can
be modified in the script.

---

## How to run

1. Place your dataset (`.mat` file) in the working directory.
2. Ensure variable names and structure match the expected format.
3. Run in MATLAB:

```matlab
Decision_Tree_mSOFA
