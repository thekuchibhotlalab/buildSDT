%% SU's old code -- not used, don't run
allOptoMat{1,2}='Opto Light bins'; allOptoMat{1,3}='Lick Binary';  
lickBinary=[];optoBins=[];optoBins2=[];lickBinary2=[];stimCat=[];
for tt=2:7
    clear lickTemp stimTemp 
    lickTemp=allOptoMat{tt,3};
    lickTemp=cell2mat(lickTemp);lickTemp=lickTemp';
    stimTemp=allOptoMat{tt,4};
    stimTemp=cell2mat(stimTemp);stimTemp=stimTemp';
    lickBinary=vertcat(lickBinary, lickTemp);
    stimCat=vertcat(stimCat, stimTemp);
    optoTemp=allOptoMat{tt,2};
    for pp=1:length(optoTemp)
        clear optoTemp2
        optoTemp2=cell2mat(optoTemp(1,pp));
%         disp(pp);
        optoBins=vertcat(optoBins, optoTemp2);
    end
%     optoBins2=vertcat(optoBins2, optoBins);
%     lickBinary2=vertcat(lickBinary2, lickBinary);
end
opts = statset('glmfit');
opts.MaxIter = 1000; % default value for glmfit is 100.
X=horzcat(stimCat, optoBins); 
y=lickBinary;
tbl = table(stimCat, optoBins, lickBinary,'VariableNames',["Stimulus","Opto Bins","Lick Binary"]);
% mdl = glmfit(optoBins2,lickBinary2,'logit','options', opts);
% mdl = fitglm(X,y,'y ~ x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10 + x11 + x12 + x13 + x14 + x15 + x16 + x17+ x18+ x19+x20','link','logit','Distribution','binomial');
mdl = fitglm(X,y,'y ~ x1 + x2 + x3 + x4','link','logit','Distribution','binomial');

%% load regressor data, flip stimulus regressor from [0 1] to [1 -1] for [T F]
load('optoModelData.mat','allOptoMat');

stimReg = allOptoMat(2:end,4); 
stimReg= cellfun(@(x)(1-fn_cell2mat(x,1)*2),stimReg,'UniformOutput',false); % change stim to 1 and -1
optoReg = allOptoMat(2:end,2); 
optoReg= cellfun(@(x)(fn_cell2mat(x,1)),optoReg,'UniformOutput',false); 
%optoDurReg = allOptoMat(2:end,5); 
%optoDurReg= cellfun(@(x)(fn_cell2mat(x,1)),optoDurReg,'UniformOutput',false); % change stim to 1 and -1
lickPred = allOptoMat(2:end,3); 
lickPred= cellfun(@(x)(fn_cell2mat(x,1)),lickPred,'UniformOutput',false);
% keep opto as 0 and 1 (becase 0 literally means 'no effect', no the opposite)

% save new data
save('optoModelRegressor_final.mat','stimReg','optoReg', 'lickPred');

%% Build full model of optoStim and optoChoice regressors, visualize weight and fit
load('optoModelRegressor_final.mat');
% ---------- model set ----------
forms = {}; names = {};
% 1) The model used for weights analysis
forms{1} = 'Lick ~ 1 + Stim  +  OptStim + OptChoice + I1 + I2';
names{1} = 'Best';

%stimRegMat = fn_cell2mat(stimReg,1); stimReg = {};stimReg{1} = stimRegMat; 
%optoRegMat = fn_cell2mat(optoReg,1); optoReg = {};optoReg{1} = optoRegMat; 
%lickPredMat = fn_cell2mat(lickPred,1);lickPred = {};lickPred{1} = lickPredMat; 
w = {}; pred = {}; gridP = {}; gridY = {}; loglikeli = [];

for i = 1:length(stimReg)
    out = fn_fitOptoModel(stimReg{i}, optoReg{i}, lickPred{i},forms,names,'noFull');
    p = out.models.model.Coefficients.pValue; 
    w{i} = out.w{1}; %w{i}(p>0.05) = nan; 
    pred{i} = out.models.model.Fitted.Response;
    gridP{i}  = out.models.gridP(:,1:2);
    gridY{i}  = out.models.gridY(:,1:2);

end 
w = fn_cell2mat(w,2);
figure;
%bar([-1 0],nanmean(w([ 1 2],:),2),0.3,'FaceColor',matlabColors(1),'LineStyle','none'); hold on;
bar([1 4],nanmean(w([5 3],:),2),0.3,'FaceColor',matlabColors(1),'LineStyle','none'); hold on;
bar([2 5],nanmean(w([6 4],:),2),0.3,'FaceColor',matlabColors(2),'LineStyle','none'); hold on;

plot([1 4], w([5 3],:),'o','Color',matlabColors(1,0.3));
plot([2 5], w([6 4],:),'o','Color',matlabColors(2,0.3));
xlim([0 6]); yline(0)
legend({'OptoStim','OptoChoice'});
xticks([1.5 4.5]); xticklabels({'Discrimination','Bias'})
ylabel('GLM weights')

gridP = fn_cell2mat(gridP,3);gridY = fn_cell2mat(gridY,3);
figure; hold on; 
plot([0 1],[0 1],'Color',[0.8 0.8 0.8])
scatter(squeeze(gridY(1,1,:)),squeeze(gridP(1,1,:)),30,matlabColors(1),'*')
scatter(squeeze(gridY(1,2,:)),squeeze(gridP(1,2,:)),30,matlabColors(1),'o')
scatter(squeeze(gridY(2,1,:)),squeeze(gridP(2,1,:)),30,matlabColors(2),'*')
scatter(squeeze(gridY(2,2,:)),squeeze(gridP(2,2,:)),30,matlabColors(2),'o')
xlabel('Behavioral Action Rate')
ylabel('Predicted Action Rate')
legend({'','OptoStim, T','OptoStim, F','OptoChoice, T','OptoChoice, F'})

%% Effect of opto-choice dominate over opto-stim in full-trial-opto. 
% Fit full model including full-trial-opto trials, and remove opto-stim and opto-choice to evaulate change in modelfit
load('optoModelRegressor_final.mat');
% ---------- model set ----------
forms = {}; names = {};
% 1) The model used for weights analysis
forms{1} = 'Lick ~ 1 + Stim  +  OptStim + OptChoice + I1 + I2';
names{1} = 'Best';
w = {}; pred = {}; gridP = {}; gridY = {}; loglikeli = [];

for i = 1:length(stimReg)
    out = fn_fitOptoModel(stimReg{i}, optoReg{i}, lickPred{i},forms,names);
    p = out.models.model.Coefficients.pValue;  

    tempOptoFullFlag = (optoReg{i}(:,1)== 1 & optoReg{i}(:,2)== 1 & optoReg{i}(:,3)== 1);
    tempStim = stimReg{i}(tempOptoFullFlag); tempOpto = optoReg{i}(tempOptoFullFlag,:); tempLick = lickPred{i}(tempOptoFullFlag);

     T = table(tempLick, tempStim, tempOpto(:,1), tempOpto(:,2), tempOpto(:,3), tempStim .* tempOpto(:,1), tempStim .* tempOpto(:,2), tempStim .* tempOpto(:,3), ...
          'VariableNames', {'Lick','Stim','OptStim','OptChoice','OptPostC','I1','I2','I3'});
    pHat = predict(out.models.model, T);
    pHat = min(max(pHat, 1e-12), 1-1e-12);          % clip to avoid -Inf
    loglikeli(i,1) = nanmean(tempLick.*log(pHat) + (1-tempLick).*log(1-pHat));

    T = table(tempLick, tempStim, tempOpto(:,1), tempOpto(:,2)*0, tempOpto(:,3)*0, tempStim .* tempOpto(:,1), tempStim .* tempOpto(:,2)*0, tempStim .* tempOpto(:,3)*0, ...
          'VariableNames', {'Lick','Stim','OptStim','OptChoice','OptPostC','I1','I2','I3'});
    pHat = predict(out.models.model, T);
    pHat = min(max(pHat, 1e-12), 1-1e-12);          % clip to avoid -Inf
    loglikeli(i,3) = nanmean(tempLick.*log(pHat) + (1-tempLick).*log(1-pHat));

    T = table(tempLick, tempStim, tempOpto(:,1)*0, tempOpto(:,2), tempOpto(:,3)*0, tempStim .* tempOpto(:,1)*0, tempStim .* tempOpto(:,2), tempStim .* tempOpto(:,3)*0, ...
          'VariableNames', {'Lick','Stim','OptStim','OptChoice','OptPostC','I1','I2','I3'});
    pHat = predict(out.models.model, T);
    pHat = min(max(pHat, 1e-12), 1-1e-12);          % clip to avoid -Inf
    loglikeli(i,2) = nanmean(tempLick.*log(pHat) + (1-tempLick).*log(1-pHat));

end 

figure;
loglikeli = loglikeli - repmat(loglikeli(:,1),1,size(loglikeli,2));
bar(1,nanmean(loglikeli(:,2),1),'FaceColor',matlabColors(1),'LineStyle','none'); hold on;
plot(ones(size(loglikeli,1),1),loglikeli(:,2),'o','Color',matlabColors(1,0.3)); hold on;
bar(2,nanmean(loglikeli(:,3),1),'FaceColor',matlabColors(2),'LineStyle','none')
plot(ones(size(loglikeli,1),1)*2,loglikeli(:,3),'o','Color',matlabColors(2,0.3)); hold on;
ylabel('Change in log-likelihood (positive mean better fit)'); xticks([1 2]);xticklabels({'OptoStim removed','OptoChoice removed'})
title(['Removal of opto-choice, but not opto-stim regressor,' newline...
    'significantly affect prediction of full-trial-opto trials'])
%% Plot not used: evaluate how optoStim and optoChoice regressor improve model fit

% 2) Do stimulus only model comparison  
forms = {}; names = {};
forms{1} = 'Lick ~ 1 + Stim';
names{1} = 'Basic';
forms{2} = 'Lick ~ 1 + Stim + OptStim';
names{2} = 'OptoStim-Bias';
forms{3} = 'Lick ~ 1 + Stim + I1';
names{3} = 'OptoStim-Discri';

figure;a = [];
for i = 1:6
    out = fn_fitOptoModel(stimReg{i}, optoReg{i}, lickPred{i},forms,names,'optoStim');

    a(:,i) = out.logL(2:3)-out.logL(1);
end 

figure; 

plot(a,'-o','Color',matlabColors(1,0.2)); hold on; plot(mean(a,2),'-o','Color',matlabColors(1));
xlim([0 3])
% 2) Do stimulus only model comparison  
forms = {}; names = {};
forms{1} = 'Lick ~ 1 + Stim';
names{1} = 'Basic';
forms{2} = 'Lick ~ 1 + Stim + OptChoice';
names{2} = 'OptoChoice-Bias';
forms{3} = 'Lick ~ 1 + Stim + I2';
names{3} = 'OptoChoice-Discri';

figure;a = [];
for i = 1:6
    out = fn_fitOptoModel(stimReg{i}, optoReg{i}, lickPred{i},forms,names,'optoChoice');

    a(:,i) = out.logL(2:3)-out.logL(1);
end 

figure; 

plot(a,'-o','Color',matlabColors(1,0.2)); hold on; plot(mean(a,2),'-o','Color',matlabColors(1));
xlim([0 3])
