function Decision_Tree_mSOFA
%--------------------------------------------------------------------------
% Decision_Tree_mSOFA
%
% This script trains and evaluates a cost-sensitive decision tree model
% for mortality prediction using selected biomarkers. Hyperparameters are
% optimized via 10-fold cross-validation on the training set. Final model
% performance is assessed on an independent test set.
%
% Requirements:
%   - MATLAB Statistics and Machine Learning Toolbox
%   - Input dataset: mSOFA_DT.mat
%
% Output:
%   - Optimized decision tree model
%   - Test-set performance metrics
%   - AUC with 95% confidence intervals
%   - Terminal-node statistics
%
% Author: Erik Alonso González
% Organization: University of the Basque Country (UPV/EHU)
% Date: 23/02/2026
%--------------------------------------------------------------------------

%% Load data
load mSOFA_DT.mat

Y = data.M2D;                % Binary outcome (0 = survivor, 1 = nonsurvivor)
X = data;                    % Predictor table

%% Train / test split (70% / 30%), patient-wise
rng(13);                     % Fix random seed for reproducibility
hpartition = cvpartition(Y,'Holdout',0.30);

pos_train = hpartition.training;
pos_test  = hpartition.test;

%% Predictor selection (columns of 'data')
sel_var = [5 7 9 11 13];

%% Hyperparameter tuning via 10-fold CV on training set
sem = 43;
rng(sem);

k = 10;
c = cvpartition(Y(pos_train),'KFold',k);

Xtrain_all = X(pos_train,sel_var);
Ytrain_all = Y(pos_train);

% Hyperparameter grids
aCost = 14:2:22;             % Misclassification cost for false negatives
aMNS  = 5:12;                % Maximum number of splits

CV_error = zeros(length(aCost),length(aMNS),k);

for fold = 1:k

    idx_tr = c.training(fold);
    idx_te = c.test(fold);

    Xtr = Xtrain_all(idx_tr,:);
    Xte = Xtrain_all(idx_te,:);
    Ytr = Ytrain_all(idx_tr);
    Yte = Ytrain_all(idx_te);

    for iCost = 1:length(aCost)
        for iMNS = 1:length(aMNS)

            costMatrix = [0 1; aCost(iCost) 0];

            treeCV = fitctree(Xtr,Ytr, ...
                'Cost',costMatrix, ...
                'MaxNumSplits',aMNS(iMNS));

            ypredCV = predict(treeCV,Xte);

            [SE,SP,~,BAC] = compute_metrics(ypredCV,Yte);

            CV_error(iCost,iMNS,fold) = 1 - BAC;  % Balanced error
        end
    end
end

%% Select optimal hyperparameters
BER_mean = mean(CV_error,3);
[minBER,idx] = min(BER_mean(:));
[row,col] = ind2sub(size(BER_mean),idx);

optCost = [0 1; aCost(row) 0];
optMNS  = aMNS(col);

%% Train final decision tree on full training set
optDT = fitctree(X(pos_train,sel_var),Y(pos_train), ...
    'Cost',optCost, ...
    'MaxNumSplits',optMNS);

% Visualize tree
view(optDT,'Mode','graph')

%% Evaluate performance on independent test set
[ypred,score,node] = predict(optDT,X(pos_test,sel_var));

[SE,SP,ACC,BAC] = compute_performance_metrics(ypred,Y(pos_test));

fprintf('\n%%%%%%%%%%%%% TRAIN / TEST RESULTS %%%%%%%%%%%%%\n');
fprintf('Random seed: %d\n', sem);
fprintf('Cross-validated BAC (training): %.2f %%\n',100*(1-minBER));
fprintf('Optimal FN cost: %.1f\n', aCost(row));
fprintf('Optimal max. num. splits: %d\n', optMNS);
fprintf('Test SE: %.2f %%\n',100*SE);
fprintf('Test SP: %.2f %%\n',100*SP);
fprintf('Test BAC: %.2f %%\n',100*BAC);
fprintf('Test ACC: %.2f %%\n',100*ACC);

%% AUC and 95% CI (test set)
[~,~,~,mainAUC] = perfcurve(Y(pos_test),double(ypred),1);

% Manual bootstrap
bootAUC = bootstrp(1000,@computeAUC,[Y(pos_test) double(ypred)]);
bootCI  = prctile(bootAUC,[2.5 97.5]);

%% Terminal node analysis (test set)
isLeaf   = optDT.IsBranchNode == 0;
leafNodes = find(isLeaf);

N = numel(node);
percentPerLeaf = zeros(numel(leafNodes),1);
errorPerLeaf   = zeros(numel(leafNodes),1);

yTrue = Y(pos_test);

for i = 1:numel(leafNodes)
    idx = (node == leafNodes(i));
    percentPerLeaf(i) = sum(idx)/N * 100;
    errorPerLeaf(i)   = mean(ypred(idx) ~= yTrue(idx));
end

%% Figure: BAC as function of hyperparameters
[Xg,Yg] = meshgrid(aCost,aMNS);
figure;
surf(Xg,Yg,100*(1-BER_mean)')
xlabel('False-negative cost');
ylabel('Max. number of splits');
zlabel('Balanced accuracy (%)');
colorbar;

%% Figure: Predictor importance
imp = predictorImportance(optDT);
[impSorted,idxSort] = sort(imp,'ascend');

varNames = X.Properties.VariableNames(sel_var);
varNames{2} = 'MAP';
varNames{3} = 'Creatinine';
varNames{5} = 'Lactate';

figure;
barh(impSorted/max(impSorted));
set(gca,'YTick',1:length(impSorted),'YTickLabel',varNames(idxSort));
xlabel('Normalized importance');
set(gca,'TickLabelInterpreter','none');

end

%% ------------------------------------------------------------------------
% Auxiliary function: compute AUC for bootstrap
function AUC = computeAUC(sample)
    [~,~,~,AUC] = perfcurve(sample(:,1),sample(:,2),1);
end
