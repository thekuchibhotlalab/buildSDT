import numpy as np

def apply_criteria(sdt, criterion):
    # Step 2: Set the criterion
    stimuli = sdt['stimuli']
    label = sdt['label']
    
    # Step 3: Simulate the decision process
    decisions = stimuli > criterion

    # Step 4: Evaluate the model
    accuracy = np.mean(decisions == label)
    hit = np.sum((decisions & label)) / np.sum(label) if np.sum(label) > 0 else 0
    false_positives = np.sum((decisions & ~label)) / np.sum(~label) if np.sum(~label) > 0 else 0

    # Update sdt dictionary with results
    sdt['hit'] = hit
    sdt['fa'] = false_positives
    sdt['criterion'] = criterion

    return sdt
