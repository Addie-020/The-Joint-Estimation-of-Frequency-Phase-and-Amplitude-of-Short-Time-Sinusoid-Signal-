% Description:  Comparison of Estimators with Varying Sampling Time
% Projet:       Joint Estimatior of Frequency and Phase
% Date:         Oct 3, 2022
% Author:       Zhiyu Shen

clear
close all
clc

%% Generate Signal to Be Estimated

% Set parameter type and define signal to be estimated
fprintf('Set parameter type: fixed, random, user input');
paramType = input('Input type: (f/r/u) [f]:', 's');
if isempty(paramType) || (paramType == 'f')
    ft = 0.01;                              % Frequency of test signal (Hz)
    pt = pi/3;                              % Phase of test signal (rad)
elseif paramType == 'r'
    ft = randi([1 100]) / 100;              % Frequency of test signal (Hz)
    pt = randi([0 200]) * pi / 100;         % Phase of test signal (rad)
elseif paramType == 'u'
    ft = input('Frequency (Hz): ');
    pt = input('Initial phase (rad): ');
else
    error('Invalid input!');
end

% Set sampling parameters (Hz)
Fs = input('Sampling frequency(Hz) [10]: ');
if isempty(Fs)
    Fs = 10;
end

% Add noise to signal
addNoise = input('Add noise to signal? Y/N [N]: ', 's');
if isempty(addNoise) || (addNoise == 'N')
    noiseFlag = 0;
elseif addNoise == 'Y'
    % Define SNR
    snrSig = input('SNR(dB) [40]: ');
    if isempty(snrSig)
        snrSig = 40;
    end
    noiseFlag = 1;
end


%% Iteration

cycles = 0.3 : 0.1 : 2.5;         % Number of cycles
Tt = cycles / ft;                 % Total time of sampling (s)
numCycle = length(cycles);        % Iteration times
freqMseA = zeros(1, numCycle);    % MSE of frequency (Joint)
phaMseA = zeros(1, numCycle);     % MSE of phase (Joint)
timeMeanA = zeros(1, numCycle);   % Mean of time (Joint)
timeVarA = zeros(1, numCycle);    % Variance of time (Joint)
freqMseB = zeros(1, numCycle);    % MSE of frequency (Peak)
phaMseB = zeros(1, numCycle);     % MSE of phase (Peak)
timeMeanB = zeros(1, numCycle);   % Mean of time (Peak)
timeVarB = zeros(1, numCycle);    % Variance of time (Peak)
freqMseC = zeros(1, numCycle);    % MSE of frequency (Phase)
phaMseC = zeros(1, numCycle);     % MSE of phase (Phase)
timeMeanC = zeros(1, numCycle);   % Mean of time (Phase)
timeVarC = zeros(1, numCycle);    % Variance of time (Phase)

poolobj = parpool(12);
parfor i = 1 : numCycle
    
    Ns = round(Tt(i)*Fs);               % Total sampling points
    
    % Generate original signal sequence
    xt = (0 : Ns-1) / Fs;               % Time index
    at = 1;                             % Signal amplitude
    xn0 = at * cos(2*pi*ft*xt + pt);    % Test signal

    % Define estimator options
    maxIter = 10;                       % Maximum iteration time for each estimation
    numEst = 50;                        % Estimation times for each test

    % Add noise with varying SNR and estimate
    if ~noiseFlag
        xn = xn0;
    else
        sigmaN = at / 10.^(snrSig/20);      % Standard variance of noise
        sigNoise = sigmaN * randn(1, Ns);   % Additive white Gaussian noise
        xn = xn0 + sigNoise;
    end

    % Estimate with Joint Estimator
    [freqMseA(i), phaMseA(i), timeMeanA(i), timeVarA(i)] = JointEstimatorTest(xn, ...
        ft, pt, Fs, Tt(i), numEst, maxIter);
    % Estimate with DTFT Peak Search
    [freqMseB(i), phaMseB(i), timeMeanB(i), timeVarB(i)] = PeakSearchTest(xn, ...
    ft, pt, Fs, Tt(i), numEst)
    % Estimate with Phase Difference Method
    [freqMseC(i), phaMseC(i), timeMeanC(i), timeVarC(i)] = PhaseDiffTest(xn, ...
    ft, pt, Fs, Tt(i), numEst)

    fprintf('Estimation No.%d, Number of cycles = %.1f\n', i, cycles(i));

end
delete(poolobj);


%% Plot

% Plot relationship between MSE and SNR
errPlt = figure(1);
errPlt.Name = "Relationship between MSE and SNR";
errPlt.WindowState = 'maximized';
% Plot frequency MSE-SNR curve
subplot(2, 1, 1);
hold on
plot(cycles, log10(freqMseA), 'LineWidth', 2, 'Color', '#0072BD', 'Marker', '*', 'MarkerSize', 8);
plot(cycles, log10(freqMseB), 'LineWidth', 2, 'Color', '#D95319', 'Marker', '+', 'MarkerSize', 8);
plot(cycles, log10(freqMseC), 'LineWidth', 2, 'Color', '#77AC30', 'Marker', '+', 'MarkerSize', 8);
hold off
xlabel("Number of Cycles", "Interpreter", "latex");
ylabel("$\log_{10}(MSE_{frequency})$", "Interpreter", "latex");
legend('Joint Estimator', 'Peak Search', 'Phase Difference');
set(gca, 'Fontsize', 20);
% Plot phase MSE-SNR curve
subplot(2, 1, 2);
hold on
plot(cycles, log10(phaMseA), 'LineWidth', 2, 'Color', '#0072BD', 'Marker', '*', 'MarkerSize', 8);
plot(cycles, log10(phaMseB), 'LineWidth', 2, 'Color', '#D95319', 'Marker', '+', 'MarkerSize', 8);
plot(cycles, log10(phaMseC), 'LineWidth', 2, 'Color', '#77AC30', 'Marker', '+', 'MarkerSize', 8);
hold off
xlabel("Number of Cycles", "Interpreter", "latex");
ylabel("$\log_{10}(MSE_{phase})$", "Interpreter", "latex");
legend('Joint Estimator', 'Peak Search', 'Phase Difference');
set(gca, 'Fontsize', 20);


%% Print Estimation Information

fprintf('\n');
fprintf('Signal frequency: %.3f Hz\n', ft);
fprintf('Signal phase: %.3f rad\n', pt);
if ~noiseFlag
    fprintf('Noise not added.\n');
else
    fprintf('SNR: %.3f dB\n', snrSig);
end



