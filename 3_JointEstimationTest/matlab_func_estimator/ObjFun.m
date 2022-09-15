function Y = ObjFun(X)
%
% Computation of objective function value
% Objective function is based cross correlation coefficient
%
% Input arguments:
%   @X  : variables (including frequency and phase component)
%
% Output arguments:
%   @Y  : Objective function value of input variable
%
% Author: Zhiyu Shen @Nanjing University
% Date  : Aug 2, 2022
%

%#ok<*GVMIS>
global Ct                               % Necessary information of sequence to be estimated
global Fs                               % Sampling rate

X = X.';

% Set parameters
N = length(Ct);                         % Compute signal length
Xt = (0 : N - 1) / Fs;                  % Time index of samples

Freq = X(1, :);                         % Frequency of current iteration
Phi = X(2, :);                          % Phase of current iteration

% Vecterize settings
F = Freq.';                             % Frequency of current iteration: Rx1
P = repmat(Phi.', 1, N);                % Phase of current iteration: RxL

% Construct estimating signal
Sn = sin(2 * pi * F * Xt + P);                              % RxN

% Compute mean and variance of estimating signal
miuS = sum(Sn, 2) / N;                                      % Rx1
sigmaS = sqrt(sum((Sn - repmat(miuS, 1, N)).^2, 2) / N);    % Rx1

% Compute cross-correlation coefficient (Person correlation coefficient)
Ce = (Sn - repmat(miuS, 1, N)) ./ repmat(sigmaS, 1, N);     % RxN
Rou = Ct * Ce.' / (N - 1);                                  % Rx1

% Compute objective function value
Y = exp(2 - Rou);

end