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

% figure; histogram(sdt.target); hold on; % this causes like 200 figures to
% be plotted. Why? 
% histogram(sdt.foil);
% ylimm = ylim*1.1; 
% plot([criterion criterion],ylimm); ylim(ylimm);
% legend('target','foil','criteria')
% axis tight

sdt.hit = hit;
sdt.fa = false_positives;
sdt.criterion = criterion;



end 