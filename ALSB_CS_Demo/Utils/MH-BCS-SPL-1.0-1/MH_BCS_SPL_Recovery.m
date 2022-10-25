
function [X_hat X_initial] = MH_BCS_SPL_Recovery(Y, Phi, Opts)

subrate = Opts.Subrate;
num_rows = Opts.NumRows;
num_cols = Opts.NumCols;

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
tic
X_hat = BCS_SPL_DDWT_Decoder(Y_R, Phi_R, num_rows, num_cols, L);
toc
X_initial = X_hat;

%disp('MH-BCS-SPL Reconstruction...');
tic
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

toc


