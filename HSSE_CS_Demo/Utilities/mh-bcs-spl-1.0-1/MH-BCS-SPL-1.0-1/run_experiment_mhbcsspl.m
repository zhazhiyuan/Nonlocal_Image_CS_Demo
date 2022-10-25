% 
% function run_experiment_mhbcsspl()
% 
% This is the main program of iterative multihypothesis predictions and
% residual reconstruction for CS images.
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

%function run_experiment_mhbcsspl()

format long
% 
% addpath(genpath('../bcs-spl-1.4-1'));
% addpath(genpath('../MS-BCS-SPL-1.2-1'));
% addpath(genpath('../WaveletSoftware'));
% addpath(genpath('../SSIM'));
% addpath(genpath('../waveletcdf97'));
% addpath(genpath('Images'));

% input image
filename = 'Leaves256';        % change test image here

block_size = 32;          % block size

% sampling subrate
subrate = 0.2;

fprintf('Test image: %s \n', filename);
disp(['Sampling subrate = ' num2str(subrate) '']);

original_filename = [filename '.tif'];
original_image = double(imread(original_filename));
[num_rows num_cols] = size(original_image);
    
projection_file = ['projections.' num2str(block_size) '.' num2str(subrate) '.mat'];

Phi = BCS_SPL_GenerateProjection(block_size, subrate, projection_file);

% Random Sampling
Y = BCS_SPL_Encoder(original_image, Phi);

[X_hat X_initial] = MH_BCS_SPL_Decoder(Y, Phi, subrate, num_rows, num_cols);

psnr0 = PSNR(original_image, X_initial);
psnr1 = PSNR(original_image, X_hat);

fprintf(['BCS-SPL reconstructed image   :  PSNR = ' num2str(psnr0) ' dB\n']);
fprintf(['MH-BCS-SPL reconstructed image:  PSNR = ' num2str(psnr1) ' dB\n']);

% % display the images
% figure; imagesc(X_initial); colormap(gray); truesize; title(['BCS-SPL Reconstructed Image, PSNR = ' num2str(psnr0) ' dB']);
% figure; imagesc(X_hat); colormap(gray); truesize; title(['MH-BCS-SPL Reconstructed Image, PSNR = ' num2str(psnr1) ' dB']);

