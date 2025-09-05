function out = fn_fitOptoModel(stimCat, optoBins,  lickBinary,forms,names,selFlag)
%COMPARECHOICEGLMS  Fit several GLMs for lick choice and compare by BIC.
%
% Inputs (trial × 1 or trial × 3):
%   stimCat    : stimulus coded as +1 (target/rewarded if lick) and -1 (foil)
%   optoBins   : [optoStim, optoChoice, optoFull] binary regressors
%                Stim-only trials: [1 0 0]
%                Choice-only trials: [0 1 0]
%                Full-trial trials: [1 1 1] (captures stim, choice, + extra variance)
%   lickBinary : response vector, 1 = lick, 0 = no-lick
%
% Output struct 'out' contains:
%   .models(i).name, .BIC, .logL, .df, .model (fitglm object), .formula
%   .BICvec, .names, .bestIdx, and the ΔBIC bar plot handle in .fig

% ---------- basic input hygiene ----------
assert(isvector(stimCat) && isvector(lickBinary), 'stimCat and lickBinary must be vectors.');
assert(size(optoBins,2)==3, 'optoBins must be nTrials × 3.');
n = numel(lickBinary);
stimCat   = stimCat(:);
lickBinary = lickBinary(:);

% keep only trials with all needed variables defined
if ~exist('selFlag'); selFlag = 'all';end

switch selFlag

    case 'optoStim'
        selFlag = (optoBins(:,1)== 1 & optoBins(:,2)== 0 & optoBins(:,3)== 0) |...
            (optoBins(:,1)== 0 & optoBins(:,2)== 0 & optoBins(:,3)== 0);
        stim = stimCat(selFlag);
        opto = optoBins(selFlag,:);
        y    = lickBinary(selFlag);
    case 'optoChoice'
        selFlag = (optoBins(:,1)== 0 & optoBins(:,2)== 1 & optoBins(:,3)== 0) |...
            (optoBins(:,1)== 0 & optoBins(:,2)== 0 & optoBins(:,3)== 0);
        stim = stimCat(selFlag);
        opto = optoBins(selFlag,:);
        y    = lickBinary(selFlag);
    case 'noFull'
        selFlag = ~(optoBins(:,1)== 1 & optoBins(:,2)== 1 & optoBins(:,3)== 1);
        stim = stimCat(selFlag);
        opto = optoBins(selFlag,:);
        y    = lickBinary(selFlag);
    case 'all'
        stim = stimCat;
        opto = optoBins;
        y    = lickBinary;
end 
% optional: enforce coding as {-1,+1} for stimulus
stim(stim>0)  = +1;
stim(stim<=0) = -1;
    
% interactions (stim-dependent opto effects)
I1 = stim .* opto(:,1);   % stimulus-optoStim interaction
I2 = stim .* opto(:,2);   % stimulus-optoChoice interaction
I3 = stim .* opto(:,3);   % stimulus-optoFull interaction
% assemble a master table once, fit different formulas on it
T = table(y, stim, opto(:,1), opto(:,2), opto(:,3), I1, I2, I3, ...
          'VariableNames', {'Lick','Stim','OptStim','OptChoice','OptPostC','I1','I2','I3'});
% ---------- fit all models ----------
m = numel(forms);
models = struct('name',[],'formula',[],'model',[],'BIC',[],'logL',[],'df',[]);
for i = 1:m
    mdl = fitglm(T, forms{i}, 'Distribution','binomial','Link','logit');
    pHat = predict(mdl, T);          % predicted P(lick) on selected trials only
    yUse = T.Lick; 
    models(i).name    = names{i};
    models(i).formula = forms{i};
    models(i).model   = mdl;
    models(i).BIC     = mdl.ModelCriterion.BIC;
    models(i).logL    = mdl.LogLikelihood;
    models(i).df      = mdl.NumEstimatedCoefficients;
    models(i).w      = mdl.Coefficients.Estimate;
    [models(i).gridY, models(i).gridP] = packStimOptoGrid(T, yUse, pHat);   % NEW
    % figure 
    %figure;
    %fn_plotHistLine(smoothdata(models(i).gridY{1,2},'movmean',30),'histCountArgIn',{0:0.05:1,'Normalization','probability'},'plotArgIn',{'Color',matlabColors(1)}); hold on;
    %xline(nanmean(models(i).gridP{1,2}),'--','Color',matlabColors(1)); 
    %fn_plotHistLine(smoothdata(models(i).gridY{2,2},'movmean',30),'histCountArgIn',{0:0.05:1,'Normalization','probability'},'plotArgIn',{'Color',matlabColors(2)});
    %xline(nanmean(models(i).gridP{2,2}),'--','Color',matlabColors(2)); 
    %xlabel('Action Rate'); ylabel('Probability')
    %legend({'Behavior HIT','Model HIT','Behavior FA','Model FA'});
    %title('Behavior vs. Model Fit for choice-opto')

    models(i).gridY = cellfun(@(x)(nanmean(x)),models(i).gridY);
    models(i).gridP = cellfun(@(x)(nanmean(x)),models(i).gridP);
end


% ---------- return ----------
out.models  = models;
out.logL  = [models.BIC];
out.names   = names;
out.forms = forms;
out.w = {models.w};
out.gridY = {models.gridY};
out.gridP = {models.gridP};
end


function [Cy, Cp] = packStimOptoGrid(T, y, p)
% 2×3 cell: rows = Stim {+1,-1}, cols = opto {stimOnly, choiceOnly, full}
Cy = cell(2,3);
Cp = cell(2,3);

% opto masks
mStim   =  T.OptStim==1   & T.OptChoice==0;   % [1 0 0]
mChoice =  T.OptStim==0   & T.OptChoice==1;   % [0 1 0]
mFull   =  T.OptStim==1   & T.OptChoice==1;   % [1 1 1]
optoMs  = {mStim, mChoice, mFull};

% row 1: target (+1), row 2: foil (-1)
stimVals = [+1, -1];

for r = 1:2
    ms = (T.Stim == stimVals(r));
    for c = 1:3
        idx = ms & optoMs{c};
        if any(idx)
            Cy{r,c} = [y(idx)];   % [observed_lick , predicted_prob]
            Cp{r,c} = [p(idx)]; 
        else
            Cy{r,c} = [NaN NaN];
            Cp{r,c} = [NaN NaN];
        end
    end
end
end

