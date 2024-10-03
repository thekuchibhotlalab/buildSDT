function sdt = applyCriteria(sdt, criterion)

% Step 2: Set the criterion
%criterion = 0.5;
stimuli = sdt.stimuli; label = sdt.label;
% Step 3: Simulate the decision process
decisions = stimuli > criterion;

% Step 4: Evaluate the model
accuracy = mean(decisions == label);
hit = sum((decisions == true) & (label == true)) ./ sum(label == true);

false_positives =  sum((decisions == true) & (label == false)) ./ sum(label == false);

%figure; fn_plotHistLine(sdt.target,'histCountArgIn',{-1:0.01:3},'Normalization','pdf'); hold on;
%fn_plotHistLine(sdt.foil,'histCountArgIn',{-1:0.01:3});
%ylimm = ylim*1.1; 
%plot([criterion criterion],ylimm); ylim(ylimm);
%legend('target','foil','criteria')
%axis tight

sdt.hit = hit;
sdt.fa = false_positives;
sdt.criterion = criterion;




end 