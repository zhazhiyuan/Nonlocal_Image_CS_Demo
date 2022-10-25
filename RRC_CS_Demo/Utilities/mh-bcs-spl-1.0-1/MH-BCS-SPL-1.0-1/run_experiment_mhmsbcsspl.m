% 
% function run_experiment_mhmsbcsspl()
% 
% This is the main program of iterative multihypothesis multiscale
% predictions and residual reconstruction for CS images.
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

function run_experiment_mhmsbcsspl()

format long

addpath(genpath('../BCS-SPL-1.4-1'));
addpath(genpath('../MS-BCS-SPL-1.2-1'));
addpath(genpath('../WaveletSoftware'));
addpath(genpath('../SSIM'));
addpath(genpath('../waveletcdf97'));
addpath(genpath('Images'));

image{1} = 'lena';
% image{2} = 'barbara';
% image{3} = 'goldhill';
% image{4} = 'mandrill';
% image{5} = 'peppers';
% image{6} = 'clown';
% image{7} = 'crowd';
% image{8} = 'couple';
% image{9} = 'man';
% image{10} = 'boat';
% image{11} = 'cameraman';
% image{12} = 'girl';
% image{13} = 'barbara2';

subrate = 0.1;
% subrate = 0.2;
% subrate = 0.3;
% subrate = 0.4;
% subrate = 0.5;

switch subrate
  case 0.1
    run_subrate_01(image);
  case 0.2
    run_subrate_02(image);
  case 0.3
    run_subrate_03(image);
  case 0.4
    run_subrate_04(image);
  case 0.5
    run_subrate_05(image);
  otherwise
    disp('Invalid subrate');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function run_subrate_01(image)

test_subrate = 0.1;
block_sizes = [16 32 64];
num_levels = 3; 
projection_type = 'dct';

for test = 1:length(image)
    
    filename = image{test};
    fprintf('Test image: %s \n', filename);

    [ subrates, actual_subrate ] = MS_BCS_SPL_GetSubrates(test_subrate, num_levels);
    disp(['Actual subrate = ' num2str(actual_subrate)]);

    original_filename = [filename '.pgm'];
    original_image = double(imread(original_filename));
    [num_rows num_cols] = size(original_image);

    projection_file = ['projections.ms.' projection_type '.' num2str(test_subrate) '.mat'];

    Phi = MS_BCS_SPL_GenerateProjection(block_sizes, subrates, projection_file, projection_type);   
    y = MS_BCS_SPL_Encoder(original_image, Phi);

    cnt = numel(y{1});
    for level = 1:num_levels
        for subband = 1:3
            cnt = cnt + numel(y{level + 1}{subband});
        end
    end

    disp(['True subrate = ' num2str(cnt / num_rows / num_cols)]);
    

    %% Initial CS Recovery Using MS-BCS-SPL
    disp('Initial MS-BCS-SPL reconstruction...');
    tic
    reconstructed_image = MS_BCS_SPL_DDWT_Decoder(y, Phi, subrates, num_rows, num_cols, (num_levels+1));
    toc
    psnr0 = PSNR(original_image, reconstructed_image);
    initial_img = reconstructed_image;


    disp('MH-MS-BCS-SPL reconstruction...');
    tic
    %% MH Prediction and Residual Reconstruction
    % Multihypothesis predictions in wavelet domain
    iteration = 3;                % maximum iterations
    match_size = [1/4 1/4];       % initial subblock size for each level: sublock size(l) = block_size(l) * match_size(l)
    window_size = [1 1];          % initial search window size for each level
    test_lambda = 10;             % empirical setting for Tikhonov regularization parameter

    res_rec_image = cell(1,iteration+1);
    res_rec_image{1} = reconstructed_image;
    SSIMR = zeros(1,iteration);

    for i = 1:iteration

        if i > 1
            match_size = 2 .* match_size;
            window_size = 2 .* window_size;
        end

        if match_size(1) == 1
            window_size = [6 6];
            predicted_image = MH_MS_BCS_SPL_Multihypothesis_Predictions_RDWT(y,Phi,subrates,reconstructed_image,match_size,window_size,test_lambda);
        else
            predicted_image = MH_MS_BCS_SPL_Multihypothesis_Predictions_DWT(y,Phi,subrates,reconstructed_image,match_size,window_size,test_lambda);
        end

        psnr1 = PSNR(original_image, predicted_image);

        % Residual Reconstruction
        final_image = MH_MS_BCS_SPL_Residual_Reconstruction(y, Phi, subrates, num_levels, predicted_image);
        psnr2 = PSNR(original_image, final_image);

        disp(['match size = ' num2str(match_size(1)) ',' num2str(match_size(2)) '; window size = ' num2str(window_size(1)) ',' num2str(window_size(2)) '']);
        disp(['Pred_image PSNR = ' num2str(psnr1) ' dB']);
        disp(['Resi_recon PSNR = ' num2str(psnr2) ' dB']);
        fprintf('\n');

        % SSIM of final residual reconstructed image and predicted image
        res_rec_image{i+1} = final_image; 
        SSIMR(i) = ssim(res_rec_image{i}, final_image);

        reconstructed_image = final_image;

        % stop criterion
        if i == 2
            if SSIMR(i) >= 0.9995
                break
            else
                continue
            end
        end

    end

    toc
    
    fprintf('==========================================================================\n');
    disp(['MS-BCS-SPL: PSNR = ' num2str(psnr0) 'dB;  MH-MS: PSNR = ' num2str(psnr2) ' dB.']);
    fprintf('==========================================================================\n');
    fprintf('\n');
    fprintf('\n');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function run_subrate_02(image)

test_subrate = 0.2;
block_sizes = [16 32 64];
num_levels = 3; 
projection_type = 'dct';

for test = 1:length(image)

    filename = image{test};
    fprintf('Test image: %s \n', filename);
    
    [ subrates, actual_subrate ] = MS_BCS_SPL_GetSubrates(test_subrate, num_levels);
    disp(['Actual subrate = ' num2str(actual_subrate)]);

    original_filename = [filename '.pgm'];
    original_image = double(imread(original_filename));
    [num_rows num_cols] = size(original_image);
    
    projection_file = ['projections.ms.' projection_type '.' num2str(test_subrate) '.mat'];

    Phi = MS_BCS_SPL_GenerateProjection(block_sizes, subrates, projection_file, projection_type);   
    y = MS_BCS_SPL_Encoder(original_image, Phi);

    cnt = numel(y{1});
    for level = 1:num_levels
        for subband = 1:3
            cnt = cnt + numel(y{level + 1}{subband});
        end
    end

    disp(['True subrate = ' num2str(cnt / num_rows / num_cols)]);
    

    %% Initial CS Recovery Using MS-BCS-SPL
    disp('Initial MS-BCS-SPL reconstruction...');
    tic
    reconstructed_image = MS_BCS_SPL_DDWT_Decoder(y, Phi, subrates, num_rows, num_cols, (num_levels+1));
    toc
    psnr0 = PSNR(original_image, reconstructed_image);
    initial_img = reconstructed_image;
    

    disp('MH-MS-BCS-SPL reconstruction...');
    tic
    %% MH Prediction and Residual Reconstruction
    % Multihypothesis prediction in wavelet domain
    iteration = 6;                % maximum iterations
    match_size = [1/8 1/8];       % initial subblock size for each level: sublock size(l) = block_size(l) * match_size(l)
    window_size = [1 1];          % initial search window size for each level
    test_lambda = 10;             % empirical setting for Tikhonov regularization parameter

    res_rec_image = cell(1,iteration+1);
    res_rec_image{1} = reconstructed_image;
    SSIMR = zeros(1,iteration);

    for i = 1:iteration
        
        if i > 1 && i < 4
            match_size = match_size .* 2;
            window_size = window_size .* 2;
        end

        if i >= 4
            window_size = [6 6];
            match_size = [1 1];
        end

        if match_size(1) == 1
            predicted_image = MH_MS_BCS_SPL_Multihypothesis_Predictions_RDWT(y,Phi,subrates,reconstructed_image,match_size,window_size,test_lambda);
            psnr1 = PSNR(original_image, predicted_image);        
        else       
            predicted_image = MH_MS_BCS_SPL_Multihypothesis_Predictions_DWT(y,Phi,subrates,reconstructed_image,match_size,window_size,test_lambda);
            psnr1 = PSNR(original_image, predicted_image);
        end

        % Residual recovery  
        final_image = MH_MS_BCS_SPL_Residual_Reconstruction(y, Phi, subrates, num_levels, predicted_image);
        psnr2 = PSNR(original_image, final_image);

        disp(['match size = ' num2str(match_size(1)) ',' num2str(match_size(2)) '; window size = ' num2str(window_size(1)) ',' num2str(window_size(2)) '']);
        disp(['Pred_image PSNR = ' num2str(psnr1) ' dB']);
        disp(['Resi_recon PSNR = ' num2str(psnr2) ' dB']);
        fprintf('\n');

        % SSIM of final residual reconstructed image and predicted image
        res_rec_image{i+1} = final_image; 
        SSIMR(i) = ssim(res_rec_image{i}, final_image);
        reconstructed_image = final_image;

        % stop criterion
        if i == 3
            if SSIMR(i) >= 0.9995
                break
            else
                continue
            end
        end

    end
    
    toc
    
    fprintf('==========================================================================\n');
    disp(['MS-BCS-SPL: PSNR = ' num2str(psnr0) 'dB;  MH-MS: PSNR = ' num2str(psnr2) ' dB.']);
    fprintf('==========================================================================\n');
    
    [SSIMR']
    
    fprintf('\n');
    fprintf('\n');
    

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function run_subrate_03(image)

test_subrate = 0.3;
block_sizes = [16 32 64];
num_levels = 3; 
projection_type = 'dct';

for test = 1:length(image)

    filename = image{test};
    fprintf('Test image: %s \n', filename);
    
    [ subrates, actual_subrate ] = MS_BCS_SPL_GetSubrates(test_subrate, num_levels);
    disp(['Actual subrate = ' num2str(actual_subrate)]);

    original_filename = [filename '.pgm'];
    original_image = double(imread(original_filename));
    [num_rows num_cols] = size(original_image);
    
    projection_file = ['projections.ms.' projection_type '.' num2str(test_subrate) '.mat'];

    Phi = MS_BCS_SPL_GenerateProjection(block_sizes, subrates, projection_file, projection_type);   
    y = MS_BCS_SPL_Encoder(original_image, Phi);

    cnt = numel(y{1});
    for level = 1:num_levels
        for subband = 1:3
            cnt = cnt + numel(y{level + 1}{subband});
        end
    end

    disp(['True subrate = ' num2str(cnt / num_rows / num_cols)]);
    

    %% Initial CS Recovery Using MS-BCS-SPL
    disp('Initial MS-BCS-SPL reconstruction...');
    tic
    reconstructed_image = MS_BCS_SPL_DDWT_Decoder(y, Phi, subrates, num_rows, num_cols, (num_levels+1));
    toc
    psnr0 = PSNR(original_image, reconstructed_image);
    initial_img = reconstructed_image;
    

    disp('MH-MS-BCS-SPL reconstruction...');
    tic
    %% MH Prediction and Residual Reconstruction
    % Multihypothesis prediction in wavelet domain
    iteration = 10;                % maximum iterations
    match_size = [1/8 1/8];       % initial subblock size for each level: sublock size(l) = block_size(l) * match_size(l)
    window_size = [1 1];          % initial search window size for each level
    test_lambda = 10;             % empirical setting for Tikhonov regularization parameter

    res_rec_image = cell(1,iteration+1);
    res_rec_image{1} = reconstructed_image;
    SSIMR = zeros(1,iteration);

    for i = 1:iteration
        
        if i > 1 && i < 4
            match_size = match_size .* 2;
            window_size = window_size .* 2;
        end

        if i >= 4
            window_size = [6 6];
            match_size = [1 1];
        end

        if match_size(1) == 1
            predicted_image = MH_MS_BCS_SPL_Multihypothesis_Predictions_RDWT(y,Phi,subrates,reconstructed_image,match_size,window_size,test_lambda);
            psnr1 = PSNR(original_image, predicted_image);        
        else       
            predicted_image = MH_MS_BCS_SPL_Multihypothesis_Predictions_DWT(y,Phi,subrates,reconstructed_image,match_size,window_size,test_lambda);
            psnr1 = PSNR(original_image, predicted_image);
        end

        % Residual recovery  
        final_image = MH_MS_BCS_SPL_Residual_Reconstruction(y, Phi, subrates, num_levels, predicted_image);
        psnr2 = PSNR(original_image, final_image);

        disp(['match size = ' num2str(match_size(1)) ',' num2str(match_size(2)) '; window size = ' num2str(window_size(1)) ',' num2str(window_size(2)) '']);
        disp(['Pred_image PSNR = ' num2str(psnr1) ' dB']);
        disp(['Resi_recon PSNR = ' num2str(psnr2) ' dB']);
        fprintf('\n');

        % SSIM of final residual reconstructed image and predicted image
        res_rec_image{i+1} = final_image; 
        SSIMR(i) = ssim(res_rec_image{i}, final_image);
        reconstructed_image = final_image;

        % stop criterion
        if SSIMR(i) >= 0.9999
            break
        else
            continue
        end

    end
    
    toc
    
    fprintf('==========================================================================\n');
    disp(['MS-BCS-SPL: PSNR = ' num2str(psnr0) 'dB;  MH-MS: PSNR = ' num2str(psnr2) ' dB.']);
    fprintf('==========================================================================\n');
    fprintf('\n');
    fprintf('\n');


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function run_subrate_04(image)

test_subrate = 0.4;
block_sizes = [16 32 64];
num_levels = 3; projection_type = 'dct';

for test = 1:length(image)

    filename = image{test};
    fprintf('Test image: %s \n', filename);
    
    [ subrates, actual_subrate ] = MS_BCS_SPL_GetSubrates(test_subrate, num_levels);
    disp(['Actual subrate = ' num2str(actual_subrate)]);

    original_filename = [filename '.pgm'];
    original_image = double(imread(original_filename));
    [num_rows num_cols] = size(original_image);

    projection_file = ['projections.ms.' projection_type '.' num2str(test_subrate) '.mat'];

    Phi = MS_BCS_SPL_GenerateProjection(block_sizes, subrates, projection_file, projection_type);   
    y = MS_BCS_SPL_Encoder(original_image, Phi);

    cnt = numel(y{1});
    for level = 1:num_levels
        for subband = 1:3
            cnt = cnt + numel(y{level + 1}{subband});
        end
    end
    disp(['True subrate = ' num2str(cnt / num_rows / num_cols)]);

    disp('Initial MS-BCS-SPL reconstruction...');
    tic
    reconstructed_image = MS_BCS_SPL_DDWT_Decoder(y, Phi, subrates, num_rows, num_cols, (num_levels+1));
    t0 = toc;
    
    psnr0 = PSNR(original_image, reconstructed_image);
    disp(['MS-BCS-SPL PSNR = ' num2str(psnr0) ' dB; Time = ' num2str(t0) ' seconds.']);
    fprintf('\n');
    
    disp('MH-MS-BCS-SPL reconstruction...');
    % Multihypothesis prediction in wavelet domain
    iteration = 20;    
    match_size = [1/8 1/8];
    window_size = [1 1];
    test_lambda = 1.0; 

    pred_image = cell(1,iteration+1);
    pred_image{1} = reconstructed_image;
    SSIMP = zeros(1,iteration);

    record = 0;
    time = cputime;
    
    for i = 1:iteration
         
        if match_size(1) == 1
            tic
            predicted_image = MH_MS_BCS_SPL_Multihypothesis_Predictions_RDWT(y,Phi,subrates,reconstructed_image,match_size,window_size,test_lambda);
            t1 = toc;
            psnr1 = PSNR(original_image, predicted_image);
            record = record + 1;
        else
            tic
            predicted_image = MH_MS_BCS_SPL_Multihypothesis_Predictions_DWT(y,Phi,subrates,reconstructed_image,match_size,window_size,test_lambda);
            t1 = toc;
            psnr1 = PSNR(original_image, predicted_image);
        end      

        
        % Residual recovery  
        tic
        final_image = MH_MS_BCS_SPL_Residual_Reconstruction(y, Phi, subrates, num_levels, predicted_image);
        t2 = toc;
        psnr2 = PSNR(original_image, final_image);
        
        disp(['match size = ' num2str(match_size(1)) '; window size = ' num2str(window_size(1)) '']);
        disp(['Pred_image PSNR = ' num2str(psnr1) ' dB; pred time = ' num2str(t1) ' secs.']);
        disp(['Resi_recon PSNR = ' num2str(psnr2) ' dB; reco time = ' num2str(t2) ' secs.']);
        fprintf('\n');
        
        % SSIM of final residual reconstructed image and predicted image
        pred_image{i+1} = predicted_image; 
        SSIMP(i) = ssim(pred_image{i}, predicted_image);
        reconstructed_image = final_image;
        
        if i > 1
            if match_size(1) == 1/8 && abs(SSIMP(i) - SSIMP(i-1)) <= 0.000125
                match_size = [1/4 1/4];
                window_size = [2 2];
                phase1 = i;
            elseif match_size(1) == 1/4 && abs(SSIMP(i) - SSIMP(i-1)) <= 0.0001
                if i >= phase1 + 2
                    if abs(SSIMP(i) - SSIMP(i-1)) <= 0.00001
                        match_size = [1/2 1/2];
                        window_size = [4 4];
                    end
                else
                    match_size = [1/2 1/2];
                    window_size = [4 4];
                end
                phase2 = i;             
            elseif match_size(1) == 1/2 && i >= phase2 + 2
                if abs(SSIMP(i) - SSIMP(i-1)) <= 0.00005
                    match_size = [1 1];
                    window_size = [6 6];
                    if SSIMP(i) >= 0.99998
                        break
                    end
                end
            end
        end
        
        if record == 1
            break
        end

    end

    runtime = cputime - time;
    psnr3 = PSNR(original_image, final_image);
    
    [SSIMP']

    fprintf('\n');
    fprintf('\n');

end

fprintf('\n');
fprintf('\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function run_subrate_05(image)

test_subrate = 0.5;
block_sizes = [16 32 64];
num_levels = 3; projection_type = 'dct';

[ subrates, actual_subrate ] = MS_BCS_SPL_GetSubrates(test_subrate, num_levels);
disp(['Actual subrate = ' num2str(actual_subrate)]);


for test = 1:1

    filename = image{13};
    fprintf('Test image: %s \n', filename);

    original_filename = [filename '.pgm'];
    original_image = double(imread(original_filename));
    [num_rows num_cols] = size(original_image);

    projection_file = ['projections.ms.' projection_type '.' num2str(test_subrate) '.mat'];

    Phi = MS_BCS_SPL_GenerateProjection(block_sizes, subrates, projection_file, projection_type);   
    y = MS_BCS_SPL_Encoder(original_image, Phi);

    cnt = numel(y{1});
    for level = 1:num_levels
        for subband = 1:3
            cnt = cnt + numel(y{level + 1}{subband});
        end
    end
    disp(['True subrate = ' num2str(cnt / num_rows / num_cols)]);

    disp('Initial MS-BCS-SPL reconstruction...');
    tic
    reconstructed_image = MS_BCS_SPL_DDWT_Decoder(y, Phi, subrates, num_rows, num_cols, (num_levels+1));
    t0 = toc;
    
    psnr0 = PSNR(original_image, reconstructed_image);
    disp(['MS-BCS-SPL PSNR = ' num2str(psnr0) ' dB; Time = ' num2str(t0) ' seconds.']);
    fprintf('\n');
    
    disp('MH-MS-BCS-SPL reconstruction...');
    % Multihypothesis prediction in wavelet domain
    iteration = 20; 
    match_size = [1/8 1/8];
    window_size = [1 1];
    test_lambda = 0.1; 

    pred_image = cell(1,iteration+1);
    pred_image{1} = reconstructed_image;
    SSIMP = zeros(1,iteration);

    record = 0;
    time = cputime;
    
    for i = 1:iteration
         
        if match_size(1) == 1
            tic
            predicted_image = MH_MS_BCS_SPL_Multihypothesis_Predictions_RDWT(y,Phi,subrates,reconstructed_image,match_size,window_size,test_lambda);
            t1 = toc;
            psnr1 = PSNR(original_image, predicted_image);
            record = record + 1;
        else
            tic
            predicted_image = MH_MS_BCS_SPL_Multihypothesis_Predictions_DWT(y,Phi,subrates,reconstructed_image,match_size,window_size,test_lambda);
            t1 = toc;
            psnr1 = PSNR(original_image, predicted_image);
        end      

        
        % Residual recovery  
        tic
        final_image = MH_MS_BCS_SPL_Residual_Reconstruction(y, Phi, subrates, num_levels, predicted_image);
        t2 = toc;
        psnr2 = PSNR(original_image, final_image);
        
        disp(['match size = ' num2str(match_size(1)) '; window size = ' num2str(window_size(1)) '']);
        disp(['Pred_image PSNR = ' num2str(psnr1) ' dB; pred time = ' num2str(t1) ' secs.']);
        disp(['Resi_recon PSNR = ' num2str(psnr2) ' dB; reco time = ' num2str(t2) ' secs.']);
        fprintf('\n');
        
        % SSIM of final residual reconstructed image and predicted image
        pred_image{i+1} = predicted_image; 
        SSIMP(i) = ssim(pred_image{i}, predicted_image);
        reconstructed_image = final_image;
        
        if i > 1
            if match_size(1) == 1/8 && abs(SSIMP(i) - SSIMP(i-1)) <= 0.000125
                match_size = [1/4 1/4];
                window_size = [2 2];
                phase1 = i;
            elseif match_size(1) == 1/4 && abs(SSIMP(i) - SSIMP(i-1)) <= 0.0001
                if i >= phase1 + 2
                    if abs(SSIMP(i) - SSIMP(i-1)) <= 0.00001
                        match_size = [1/2 1/2];
                        window_size = [4 4];
                    end
                else
                    match_size = [1/2 1/2];
                    window_size = [4 4];
                end
                phase2 = i;             
            elseif match_size(1) == 1/2 && i >= phase2 + 2
                if abs(SSIMP(i) - SSIMP(i-1)) <= 0.00005
                    match_size = [1 1];
                    window_size = [6 6];
                    if SSIMP(i) >= 0.99998
                        break
                    end
                end
            end
        end
        
        if record == 1
            break
        end

    end

    runtime = cputime - time;
    psnr3 = PSNR(original_image, final_image);
    
    [SSIMP']

    fprintf('\n');
    fprintf('\n');

end

fprintf('\n');
fprintf('\n');


