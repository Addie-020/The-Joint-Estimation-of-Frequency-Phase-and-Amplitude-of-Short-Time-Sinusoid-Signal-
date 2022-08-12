% Description:  Test Program for Joint Estimator for Single Run
% Projet:       Short Sequence Parameter Estimation
% Date:         July 28, 2022
% Author:       Zhiyu Shen

clear
close all
clc

Fs = 50;                            % Sampling frequency (Hz)
Tt = 5;                             % Total time of sampling (s)
Ns = Tt * Fs;                       % Total sampling points

% ft = randi([8 100]) / 100;              % Frequency of test signal (Hz)
% pt = (randi([0 200]) - 100) * pi / 100; % Phase of test signal (rad)

ft = 0.02;                              % Frequency of test signal (Hz)
pt = -0.2;                           % Phase of test signal (rad)

xt = (0 : Ns - 1) / Fs;             % Time index
xn = sin(2 * pi * ft * xt + pt);    % Test signal

M = 50;                             % Search times

options.maxIter = M;
tic
[xBest, yBest, info] = JointEstimator(xn, Fs, options);
toc

fe = xBest(1);
pe = xBest(2);
fErr = abs(fe - ft) / ft;
pErr = abs(pe - pt) / pt;

fprintf('\n-------- Input Signal --------\n');
fprintf('Frequency: %.3d Hz\n', ft);
fprintf('Phase: %.3d rad\n', pt);

fprintf('\n-------- Estimation Result --------\n');
fprintf('Frequency: %.3d Hz\n', fe);
fprintf('Phase: %.3d rad\n', pe);

fprintf('\n-------- Error Analysis --------\n');
fprintf('Frequency Error: %.3d\n', fErr);
fprintf('Phase Error: %.3d\n', pErr);


