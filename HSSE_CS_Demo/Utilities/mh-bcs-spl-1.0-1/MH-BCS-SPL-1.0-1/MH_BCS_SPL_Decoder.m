% function [X_hat X_initial] = MH_BCS_SPL_Decoder(Y, Phi, subrate, ...
%     num_rows, num_cols)
%
%   This function performs MH-BCS-SPL reconstruction of Y using a DDWT
%   sparsity basis. Phi gives the projection matrix. The reconstructed
%   image, of size num_rows x num_cols, is returned as
%   X_hat; the initial BCS-SPL reconstruction is returned as X_initial.
%

%
% MH-BCS-SPL: Multihypothesis Block Compressed Sensing -
%    Smooth Projected Landweber
% Copyright (C) 2012  James E. Fowler
% http://www.ece.mstate.edu/~fowler
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
%

%
% Written by C. Chen, April, 2011
% chenchen870713@gmail.com
% http://www.ece.msstate.edu/~fowler/BCSSPL/
% http://www.ece.msstate.edu/~cc1164/
%
% Electrical and Computer Engineering Department,
% Mississippi State University
%
% Last modified by C. Chen, Nov. 2011
%
%

function [X_hat X_initial] = MH_BCS_SPL_Decoder(Y, Phi, subrate, ...
    num_rows, num_cols)

block_size = sqrt(size(Phi,2));
L = 3;                    % DDWT decomposition levels

% sampling matrix used in CS recovery, three measurements are used as
% a holdout set for stopping criterion
num_measurements = size(Phi, 1);
true_measurement = num_measurements - 3;

Phi_R = Phi(1:true_measurement,:);

Y_R = Y(1:true_measurement,:);

%% Initial CS Recovery Using BCS-SPL
%disp('Initial BCS-SPL reconstruction...');

X_hat = BCS_SPL_DDWT_Decoder(Y_R, Phi_R, num_rows, num_cols, L);

X_initial = X_hat;

%disp('MH-BCS-SPL Reconstruction...');

% Calculate the residual in the projection domain
r0 = MH_BCS_SPL_Test_Residual(X_hat, Y, Phi, true_measurement);


%% MH Prediction and Residual Reconstruction
w = 6;               % initial search window size, 5 - 8. we use w = 6 for subrate = 0.1, 0.2, 0.3 and w = 8 for subrate = 0.4, 0.5
match_size = 1/2;    % initial subblock size: subblock size = block_size * match_size
iteration = 20;      % maximum iterations
test_lambda = 1.0;   % empirical setting for Tikhonov regularization parameter

recover_image = cell(1,iteration+1);
recover_image{1} = X_hat;

residual = zeros(iteration+1, 6);  % residual matrix to keep records of the residual in each iteration
SSIMR = zeros(1,iteration);        % SSIM measurement matrix to keep records of the SSIM values of two successive reconstructed images in each iteration
residual(1,:) = r0;

for i = 1:iteration
    
    % For speed up purpose, we use mh_prediction_fast at subrate = 0.1 and
    % use MH_BCS_SPL_Multihypothesis_Predictions at subrate = 0.2, 0.3, 0.4, 0.5; however, it is
    % not necessary to use MH_BCS_SPL_Multihypothesis_Predictions_Fast at subrate = 0.1.
    if subrate > 0.1
        P_mh = MH_BCS_SPL_Multihypothesis_Predictions(Y_R, Phi_R, X_hat, block_size, match_size, w, test_lambda);
    else
        P_mh = MH_BCS_SPL_Multihypothesis_Predictions_Fast(Y_R, Phi_R, X_hat, block_size, match_size, w, test_lambda);
    end
    
    
    X_mh = MH_BCS_SPL_Residual_Reconstruction(P_mh, Y_R, Phi_R, num_rows, num_cols, L); % residual reconstruction using BCS-SPL
    r1 = MH_BCS_SPL_Test_Residual(X_mh, Y, Phi, true_measurement);                      % calculate the residual in the projection domain using the holdout set
    recover_image{i+1} = X_mh;
    residual(i+1,:) = r1;
    
    SSIMR(i) = ssim(recover_image{i}, X_mh);
    X_hat = X_mh;
    
    % parameters update and stopping criterion
    if i == 1
        if sum(residual(i+1,:)<residual(i,:)) < 4
            if match_size < 1
                residual(i+1,:) = residual(i,:);
                match_size = 1; w = 10; % update parameters, w = 10 to 16 when subblock size = block size
                X_hat = recover_image{i};
                recover_image{i+1} = recover_image{i};
            end
        end
    else
        if sum(residual(i+1,:)<residual(i,:)) < 4
            if match_size < 1
                residual(i+1,:) = residual(i,:);
                match_size = 1; w = 10; % update parameters
                X_hat = recover_image{i};
                recover_image{i+1} = recover_image{i};
            else
                X_hat = recover_image{i};
                break
            end
        elseif i > 1
            if abs(SSIMR(i) - SSIMR(i-1)) <= 0.0001 % tau = 0.0001, can be adjusted
                if match_size < 1
                    match_size = 1; w = 10; % update parameters
                else
                    break
                end
            end
            
        end
    end
    
end




