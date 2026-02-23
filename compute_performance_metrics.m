%% ------------------------------------------------------------------------
% compute_metrics
%
% Computes standard classification performance metrics for a binary outcome.
%
% INPUTS:
%   Ypred : vector of predicted class labels (0 = negative, 1 = positive)
%   Y     : vector of true class labels      (0 = negative, 1 = positive)
%
% OUTPUTS:
%   SE  : Sensitivity (true positive rate)
%   SP  : Specificity (true negative rate)
%   ACC : Accuracy
%   BAC : Balanced accuracy
%
% Notes:
%   - Metrics are computed using logical indexing.
%   - If a denominator is zero, the corresponding metric is returned as NaN.
%
% -------------------------------------------------------------------------
function [SE,SP,ACC,BAC] = compute_performance_metrics(Ypred,Y)

% Ensure logical vectors
Ypred = logical(Ypred);
Y     = logical(Y);

% Confusion matrix components
TP = sum(Ypred & Y);
TN = sum(~Ypred & ~Y);
FP = sum(Ypred & ~Y);
FN = sum(~Ypred & Y);

% Sensitivity (Recall, True Positive Rate)
SE = TP / (TP + FN);

% Specificity (True Negative Rate)
SP = TN / (TN + FP);

% Accuracy
ACC = (TP + TN) / (TP + TN + FP + FN);

% Balanced Accuracy
BAC = (SE + SP) / 2;

% Handle divisions by zero explicitly
metrics = [SE SP ACC BAC];
metrics(~isfinite(metrics)) = NaN;
[SE,SP,ACC,BAC] = deal(metrics(1),metrics(2),metrics(3), ...
                               metrics(4));

end