function params = analysis_parameters()

params.filePattern = 'Strain*';

params.excludePrefixes = ["N_A", "XXX"];

params.burstThreshold = 9000;
params.minBurstResponses = 3;

params.correctRange = [0.099 0.101];
params.incorrectRange = [0.109 0.111];
params.timeoutRange = [0.119 0.121];
params.infusionRange = [0.529 0.531];

end
