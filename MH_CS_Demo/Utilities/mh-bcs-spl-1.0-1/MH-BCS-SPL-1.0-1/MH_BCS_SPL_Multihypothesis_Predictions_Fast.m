% function predicted_image = ...
%     MH_BCS_SPL_Multihypothesis_Predictions_Fast(Y, Phi, reference, ...
%     block_size, match_size,w,test_lambda)
% 
% MH_BCS_SPL_Multihypothesis_Predictions_Fast is a function to
% generate multiple hypotheses for a block from spatially surrounding
% blocks. A Tikhonov regularization to an ill-posed least-squares
% optimization is applied to appropriately weight the hypothesis predictions.
% 
% [Notice]
% (1) mh_prediction_fast is similar to
% MH_BCS_SPL_Multihypothesis_Predictions except that
%     mh_prediction_fast uses a hypotheses scattering process to pick out a
%     number of hypotheses which are more important (reflect by the
%     weights, i.e., larger weights --> more important) than others. 
%     It is used in low subrates, such as subrate = 0.1, which typically  
%     need a large amount of hypotheses (i.e., use large search window size) to
%     achieve high quality predicted images.
%     It is time comsuming when solving the hypotheses weights using Tikhonov 
%     regularization if the hypotheses matrix has very large dimensions. To
%     speed up the process, a hypotheses scattering procedure is applied,
%     although the quality of the predicted image may suffer a little
%     degradation in comparison with that using all the hypotheses.
%
% (2) Hypotheses scattering process is optiional even if in low subrates.
%     It is not a necessary step.
%
% (3) Tikhonov regularization parameter: lambda
%     A heuristic method of choosing an adaptive tikhonov
%     regularization parameter for each block applies only when subblocks are 
%     smaller than the block size. If subblocks are the same size as
%     block size, then an empirical value is used. In addition, if
%     both cases shall use the emprical settings, the values could be set as:
%     (a) lambda = 0.001 - 0.003 when subblocks < block size
%     (b) lambda = 1.0 - 1.5 when subblocks = block size
%
%     Tikhonov solution: 
%     weights = (A_t * A + lambda .* Gramm_t * Gramm)_t * A_t * y   (A_t
%     denotes the transpose of A)
%     
%
% [Parameters]
% Y              : CS measurements
% Phi            : block based random sampling matrix
% reference      : input image for generating hypotheses
% block_size     : block size used in inital CS recovery algorithm BCS-SPL
% match_size     : match_size is used to specify the subblock size in the
%                  process of generating multiple hypotheses.
%                  subblock size = block_size * match_size
% w              : search window size for generating multiple
%                  hypotheses, typically 5 to 8
% test_lambda    : Tikhonov regularization parameer, an emprical setting is
%                  used in the experiments
%
% [Return]
% predicted_image: a predicted image generated from multihypothesis predictions
%                  procedure

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
% Written by C. Chen, April. 2011
% Department of Electical and Computer Engineering,
% Miss State Univ.
% Last modified by C. Chen, Nov. 2011
%

function predicted_image = ...
    MH_BCS_SPL_Multihypothesis_Predictions_Fast(Y, Phi, reference, ...
    block_size, match_size,w,test_lambda)

[num_rows num_cols] = size(reference);
b_rows = num_rows/block_size;
b_cols = num_cols/block_size;
predicted_image = zeros(block_size.^2, b_rows * b_cols);

B = block_size * match_size; % subblock size
ext_ref = symextend(reference,block_size); % extend the image boader by mirroring
dim_nb = 1/match_size;

P = @(x) Phi * x; % generate CS measurment via random projections

for i = 1:block_size:num_rows
    for j = 1:block_size:num_cols
        
        index = ((j-1)/block_size)*b_rows + (i-1)/block_size + 1;
        cur_proj = Y(:,index);
        
        ref_win = ext_ref(i+block_size-w:i+2*block_size+w-1, j+block_size-w:j+2*block_size+w-1); % search window for a block      
        H = im2col(ref_win,[block_size block_size],'sliding'); % all the hypotheses for a block
        
        cur_blk_position = 2*w*(w+1) + 1;
        
        %h = H(:,cur_blk_position);
        % Since the current block lies in the null space of the solution, the L2 norm in the projection domain for current block
        % will be zero. Our proposed Tikhonov matrix is formed by those L2 norms in the projection domain, in this case, the weight
        % for current block will always be one and the wights for other hypotheses will be zero. The resulting predicted image will
        % be exactly the same as the input image. So the current block should be removed.
        H(:,cur_blk_position) = [];

        A = P(H); % projected hypotheses matrix
        norms = A - repmat(cur_proj,[1 size(A,2)]);
        norms = sum(norms.^2);
        
        G = diag(norms);                                 % diagonal Tikhonov matrix
        weights = (A'*A + test_lambda.*G)\(A'*cur_proj); % calculate the weights for multiple hypotheses
               
        if match_size == 1           
            predicted_image(:,index) = H * weights(:);      
        else            
           max_iter = (1/match_size)/2;                 
           % scattering the hypotheses for speed up purpose
           while max_iter > 0                  
               thresh = median(abs(weights(:)));
               weights(abs(weights) < thresh) = 0;        
               H(:,weights==0) = [];  
                        
               if max_iter > 1
                  A(:,weights==0) = [];
                  norms(:,weights==0) = [];
                  G = diag(test_lambda .* norms);
                  weights = (A'*A + G)\(A'*cur_proj);
               end
                        
               max_iter = max_iter - 1;
           end
        
        
           % subblock multihypothesis predictions
           num_hy = size(H,2);
           H1 = zeros(block_size^2, dim_nb^2*num_hy);
         
           for r = 1:num_hy
               tmp = reshape(H(:,r),block_size,block_size); % reshape a hypothesis to BxB block to perform MH predictions for subblocks in that block
            
               for row = 1:dim_nb
                   for col = 1:dim_nb
                       sub_blk = tmp((row-1)*B+1:row*B, (col-1)*B+1:col*B);
                       hy_cols = (r-1)*dim_nb^2 + (row-1)*dim_nb + col;
                       H1(:,hy_cols) = MH_BCS_SPL_Zero_Padding(sub_blk,row,col,B,block_size,dim_nb);
                   end
               end
            
           end

           clear H
        
           A = P(H1);
           norms = A - repmat(cur_proj,[1 size(A,2)]);
           norms = sum(norms.^2); 
           
           % A heuristic method of choosing an adaptive tikhonov
           % regularization parameter, lambda, for each block when subblocks
           % are used in generation of multiple hypotheses
           lambda = adaptive_lambda(cur_proj, A);
           
           G = diag(norms);     % diagonal Tikhonov matrix
           weights = (A'*A + lambda.*G)\(A'*cur_proj);             
           predicted_image(:,index) = H1 * weights(:);
          
        end
        
    end
end

predicted_image = col2im(predicted_image,[block_size block_size],[num_rows num_cols],'distinct');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function lambda = adaptive_lambda(cur_proj, A)
%
% A heuristic method of choosing an adaptive tikhonov regularization
% parameter.
%

std_Y = std(cur_proj);
std_A = std(A);
lam1 = std_Y^2/sum((std_A-std_Y).^2);
lam2 = lam1/std(std_A);
lambda = (lam1 + lam2)/2;


