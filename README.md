#Cost-Sensitive Decision Tree for Mortality Prediction

This repository contains MATLAB code for training, optimizing, and evaluating a cost-sensitive decision tree (DT) model to predict in-hospital mortality using routinely collected clinical biomarkers.

The code accompanies a scientific manuscript and is intended to promote transparency, reproducibility, and methodological clarity.

Overview

The workflow implemented in this repository includes:

Patient-wise random partitioning into training (70%) and test (30%) sets

10-fold cross-validation on the training set for hyperparameter tuning

Optimization of:

Tree complexity (maximum number of splits)

Misclassification cost for nonsurvivors (false negatives)

Model evaluation on an independent test set

Assessment of:

Sensitivity, specificity, accuracy, balanced accuracy

Area under the ROC curve (AUC) with 95% confidence intervals

Model calibration

Terminal-node composition and error rates

Predictor importance

Repository contents
.
├── Decision_Tree_mSOFA.m        % Main script
├── compute_metrics.m            % Auxiliary function (classification metrics)
├── mSOFA_DT.mat                 % Input dataset (not publicly distributed)
└── README.md

⚠️ Note
The dataset used in the manuscript is not publicly shared due to privacy restrictions.
Users must provide their own dataset with the same structure to run the code.

Requirements

MATLAB (R2019a or later recommended)

Statistics and Machine Learning Toolbox

Data format

The input dataset (mSOFA_DT.mat) must contain a MATLAB table named data with:

A binary outcome variable:

M2D (0 = survivor, 1 = nonsurvivor)

Predictor variables including (but not limited to):

Lactate

Glasgow Coma Scale (GCS)

SaFi ratio

Creatinine

Mean arterial pressure (MAP)

The predictors used by the model are selected internally by column index and can be modified in the script.

How to run

Place your dataset (.mat file) in the working directory.

Ensure variable names and structure match the expected format.

Run in MATLAB:

Decision_Tree_mSOFA

The script will:

Train and optimize the decision tree

Display the final tree

Print test-set performance metrics

Generate figures for:

Hyperparameter performance

Predictor importance

Methodological notes

Cross-validation folds and train/test splits are patient-wise and quasi-stratified, preserving ≥90% of the original survivor/nonsurvivor proportions.

Balanced accuracy is used as the optimization criterion to account for class imbalance.

AUC confidence intervals are estimated using 1000 bootstrap resamples.

Decision trees are trained using MATLAB’s fitctree function with cost-sensitive learning.

Reproducibility

All random processes use fixed random seeds to ensure reproducible results.

Citation

If you use this code, please cite the corresponding manuscript:

[Author names]. Cost-sensitive decision tree modeling for mortality prediction using clinical biomarkers. [Journal name], [Year].

License

This code is provided for academic and research use.
You may reuse and adapt it with appropriate citation.

(If you wish, you can add a formal license such as MIT or BSD.)

Contact

For questions or clarifications related to the code or methodology, please contact:

[Your Name]
[Your Institution]
[Your Email]
