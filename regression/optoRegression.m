function [allOptoMat,X,y,tbl,mdl]=optoRegression(allDataTestsOnly,days)

allOptoMat={};allOptoMat{1,1}='Matrix'; 
SESS = 1; CTXT = 2; TONE = 3; OUTCOME = 4; 
START = 5; STOP = 6; TONE_T = 7; LICKL = 8; LICKR = 9;
% first take all of the trials from the matrix variable 
for ee=2:size(allDataTestsOnly)
    clear daysIdx
    tempMat=allDataTestsOnly{ee,26};
    daysIdx=days{ee,2}; % this is the logical variable for what days are used for the experimental data
    expRange=days{ee,3}; 
    if ee==4
        expRange=expRange(6:12);
    else
    end
    
    daysIdx=daysIdx(expRange);
    daysIdx=expRange(daysIdx);

    optoMat=[];
    for ww=1:length(daysIdx)
        optoIdx=find(tempMat(:,SESS)==daysIdx(ww));
        optoMatTemp=tempMat(optoIdx,:);
        optoMat=vertcat(optoMat, optoMatTemp);
    end
    allOptoMat{ee}=optoMat;
end
allOptoMat=allOptoMat';
% using 100ms bins
for ww=2:size(allOptoMat)
    clear tempMat stim
    optoDummyCode={};lickPredictor={};
    tempMat=allOptoMat{ww,1};
    for qq=1:size(tempMat)
        if tempMat(qq,CTXT)==6
            optoDummyCode{qq}=[0 1 0];
        elseif tempMat(qq,CTXT)==5
            optoDummyCode{qq}=[1 0 0];
        elseif tempMat(qq,CTXT)==1
            optoDummyCode{qq}=[1 1 1];
        else
            optoDummyCode{qq}=[0 0 0];
        end
            % use lick latency for the choice context, which is closed loop
%             optoOffTime=tempMat(qq,LICKL);
%             if isnan(optoOffTime)
%                 optoDummyCode{qq}=[0 1 1 1 1 1 1 1 1 1 1 1 1 ...
%                     1 1 1 1 1 1 1 1 1 1 ...
%                     1 1 1 1 1];
%             else
%                 optoBins=optoOffTime*10;optoBins=floor(optoBins);
%                 if optoBins > 27
%                     optoBins=27;
%                 else
%                 end
%                 optoBins=ones(1,optoBins);
%                 optoDummyCode{qq}=horzcat(0,optoBins);
%                 optoDummyCode{qq}= [optoDummyCode{qq} zeros(1,(28-length(optoDummyCode{qq})))]; % check if this works... 
%             end
% 
%         elseif tempMat(qq,CTXT)==5
%             optoDummyCode{qq}=[1 0 0 0 0 0 0 0 0 0 0 0 0 ...
%                 0 0 0 0 0 0 0 0 0 0 ... 
%                 0 0 0 0 0];
%         elseif tempMat(qq,CTXT)==2
%             optoDummyCode{qq}=[1 1 1 1 1 1 1 1 1 1 1 1 1 ...
%                 1 1 1 1 1 1 1 1 1 1 ...
%                 1 1 1 1 1];
%         else
%             optoDummyCode{qq}=[0 0 0 0 0 0 0 0 0 0 0 0 0 ...
%                 0 0 0 0 0 0 0 0 0 0 ... 
%                 0 0 0 0 0];
%         end
        % also add the outcome; whether the animal got it right
        if tempMat(qq,OUTCOME)==1 
            lickPredictor{qq}=1;
        elseif tempMat(qq,OUTCOME)==3
            lickPredictor{qq}=1;
        elseif tempMat(qq,OUTCOME)==2
            lickPredictor{qq}=0;
        elseif tempMat(qq,OUTCOME)==4
            lickPredictor{qq}=0;
        else
            warning('Error. Outcome is a weird value.');
        end
        
        % change this to 1 and -1
        if tempMat(qq,TONE)==1 
            stim{qq}=0;
        elseif tempMat(qq,TONE)==2
            stim{qq}=1;
        else
            warning('Error. Tone is a weird value.');
        end
    % build the dataset
    allOptoMat{ww,2}=optoDummyCode;
    allOptoMat{ww,3}=lickPredictor;
    allOptoMat{ww,4}=stim;
    end
end

%% concatenating the cell into double for 
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
figure;
scatter(X(:,1),y)
hold on
cag_range = linspace(5,50,100);
beta = mdl.Coefficients.Estimate;
plot(cag_range, 1./(1+exp(-(beta(1)+beta(2)*cag_range))))
hold off
xlabel('Opto Bins');

a = X; b = corr(a);
figure; imagesc(b); colorbar

end