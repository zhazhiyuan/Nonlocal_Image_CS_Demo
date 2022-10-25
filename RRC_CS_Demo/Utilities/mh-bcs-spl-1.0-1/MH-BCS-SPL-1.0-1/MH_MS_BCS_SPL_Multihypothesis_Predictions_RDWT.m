% function predicted_image = ...
%     MH_MS_BCS_SPL_Multihypothesis_Predictions_RDWT(y, Phi, subrates, ...
%     reference, match_size, window_size, test_lambda)
% 
% MH_MS_BCS_SPL_Multihypothesis_Predictions_RDWT is a function to
% generate multiple hypotheses for a block from various RDWT phases. 
% A Tikhonov regularization to an ill-posed least-squares optimization
% is applied to appropriately weight the hypothesis predictions.
%
% 
% [Notice]
% (1) MH_MS_BCS_SPL_Multihypothesis_Predictions_RDWT is used when
%     subblocks are the same as the block size. Please refer to
%     MH_MS_BCS_SPL_Multihypothesis_Predictions_DWT when subblocks are smaller 
%     than the block size. In this function, an input argument "match_size" 
%     is used to specify the subblock size.
%     The MH predictions are carried out in various RDWT phases.
%
% (2) Tikhonov regularization parameter: lambda
%     An empirical value is used for the regularization parameter.
%     Empirical values: 0.1 - 1.0
%
%     Tikhonov solution: 
%     weights = (A_t * A + lambda .* Gramm_t * Gramm)_t * A_t * y  (A_t
%     denotes the transpose of A)
%     
%
% [Parameters]
% Y              : CS measurements
% Phi            : block based random sampling matrix
% reference      : input image for generating hypotheses
% match_size     : match_size is used to specify the subblock size in the
%                  process of generating multiple hypotheses.
%                  Since block sizes are different in three wavelet
%                  decomposition levels in MS-BCS-SPL [2], subblock are also 
%                  different in those levels. In MS-BCS-SPL, the
%                  information in the base band and all the subbands in the
%                  first level are well preserved (subrate = 1.0), therefore MH
%                  predictions only carried out within subbands whose
%                  sampling subrates are less than 1.0. In our experiment,
%                  a 3-level DWT is performed, match_size is a vector
%                  contains two elements to specify the subblock sizes of 
%                  level 2 and level 3.
% 
%                  Example: denote B_l as the block size at level l and b_l as
%                  the subblock size at level l.
%                  match_size = [1/2 1/2] --> b_l2 = B_l2 * 1/2 and
%                  b_l3 = B_l3 * 1/2
% 
%                  Although at some subrate, such as subrate = 0.4, MH
%                  predictions only carried out at the third level (the
%                  finest level), match_size is still a two elements
%                  vector. The first element of match_size which is for
%                  level 2 can be any number.
% window_size    : search window size for generating multiple hypotheses.
%                  window_size is a vector contains two elements which
%                  correspond to level 2 and level 3.
% 
%                  Example: window_size = [4 8] --> 
%                  search window size = 4 for level 2
%                  search window size = 8 for level 3
% test_lambda    : Tikhonov regularization parameer, an emprical setting is
%                  used in the experiments. (usually 0.1-1.0)
%
% [Return]
% predicted_image: a predicted image generated from multihypothesis predictions
%                  procedure
%
%
% See also MH_MS_BCS_SPL_Multihypothesis_Predictions_DWT
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
% Written by C. Chen, April. 2011
% Department of Electical and Computer Engineering,
% Miss State Univ.
% Last modified by C. Chen, Nov. 2011
%

function predicted_image = ...
    MH_MS_BCS_SPL_Multihypothesis_Predictions_RDWT(y, Phi, subrates, ...
    reference, match_size, window_size, test_lambda)

[num_rows num_cols]= size(reference);
L = length(Phi); % figure out how many wavelet decomposition levels

% figure out how to handle our projection structure
if (isnumeric(Phi{1}))
  for level = 1:L
    block_sizes(level) = sqrt(size(Phi{level}, 2));
    Phi_matrix = Phi{level};
    Phi_transpose{level} = @(y) Phi_matrix' * y;
    Phi{level} = @(x) Phi_matrix * x;
  end
elseif (iscell(Phi{1}))
  for level = 1:L
    block_sizes(level) = Phi{level}{1};
    Phi_transpose{level} = Phi{level}{3};
    Phi{level} = Phi{level}{2};
  end
else
  disp('Incorrect Phi format');
  return;
end

% perform the RDWT on the reference image
RW = RDWT(reference, L);

% set up the blocked DWT structure of the result
predicted_image = cell(1,L+1);

% baseband is always preserved, copy it over
predicted_image{1} = y{1}; 

for l=1:L
  for dir=1:3
      if subrates(l) >= 1.0
          % perfectly recoverable (subrate = 1.0), get result via transpose
          predicted_image{l+1}{dir} = Phi_transpose{l}(y{l+1}{dir});                   
      else 
          % perform prediction for non-perfect levels (subrate < 1.0)        
          level_rows = round(num_rows ./ (2.^(L-l+1))); 
          level_cols = round(num_cols ./ (2.^(L-l+1))); 
          
          B = block_sizes(l);                         % block size at current decomposition level
          block_num_rows = level_rows/B;
          Nb = size(y{l+1}{dir},2);                   % number of blocks
                  
          predicted_image{l+1}{dir} = zeros(B^2,Nb);  % add zeros here                        
          Wl = window_size(l-1);                      % search window size at current level
          
          Nh = (2*Wl+1)^2;                            % number of hypotheses for the current block in a search window
          phases = length(RW{l+1}{dir});              % phases of RDWT
          
          % extend all the reference phases for border blocks at this subband at this level
          for j = 1:phases
            RW{l+1}{dir}{j} = symextend(RW{l+1}{dir}{j},Wl);
          end
          
          % generate predictions for current block at this subband at this level         
          for block_row = 1:B:level_rows
              for block_col = 1:B:level_cols      
                  
                  index = ((block_col-1)/B)*block_num_rows + (block_row-1)/B + 1;
                  cur_proj = y{l+1}{dir}(:,index);
                  
                  i = block_row + Wl;
                  j = block_col + Wl; 
                               
                  H = zeros(B^2, Nh*phases);              % get prediction set, H, in each phase of RDWT
                  for r = 1:phases
                      H(:,(r-1)*Nh+1:r*Nh) = im2col(RW{l+1}{dir}{r}(i-Wl:i+Wl+B-1, j-Wl:j+Wl+B-1), [B B], 'sliding');  
                  end                  

                  % Although MH_MS_BCS_SPL_Multihypothesis_Predictions_RDWT is used in our experiment when subblock size = block size,
                  % we can still perform MH predictions using subblocks < block size in RDWT if we want.
                  if match_size(l-1) < 1               
                      dim = 1/match_size(l-1);            
                      sb  = B * match_size(l-1);          % subblock size at current level
                      H1  = zeros(B^2, Nh*dim^2*phases);  % prediction set for using subblocks

                      for r = 1:size(H,2)
                          tmp = reshape(H(:,r), B, B);    % reshape a hypothesis to BxB block to perform MH predictions for subblocks in that block
                          for row = 1:dim
                              for col = 1:dim
                                  sub_blk = tmp((row-1)*sb+1:row*sb, (col-1)*sb+1:col*sb);
                                  hy_cols = (r-1)*dim^2 + (row-1)*dim + col;
                                  H1(:,hy_cols) = MH_BCS_SPL_Zero_Padding(sub_blk,row,col,sb,B,dim);
                              end
                          end   
                      end
                      H = H1;
                      clear H1
                  end
                             
                  A = Phi{l}(H);                          % project the hypotheses
                  norms = A - repmat(cur_proj,[1 size(A,2)]);
                  norms = sum(norms.^2); 
                  
                  if round(min(norms)) == 0               % remove hypothesis with nearly zero norm in the projection domain, otherwise the weight                     
                     zero_norm = find(norms==min(norms)); % of that hypothesis will be 1 and other hypotheses will be 0.
                     A(:,zero_norm) = [];
                     H(:,zero_norm) = [];
                     norms(zero_norm) = [];
                  end
                                   
                  G = diag(norms);                             % diagonal Tikhonov matrix

                  if match_size(l-1) == 1
                      lambda = test_lambda;                    % emprical setting when subblock = block size
                  else
                      lambda = adaptive_lambda(cur_proj, A);   % adaptive lambda when subblock < block size
                  end
                  
                  % Find Weights
                  weights = (A'*A + lambda.*G)\(A'*cur_proj);

                  % Get block prediction
                  predicted_image{l+1}{dir}(:,index) = H * weights(:);
                
              end
          end
          
      end
  end
end

% Cast back into the spatial domain
predicted_image = InverseBlockDWT(predicted_image);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function lambda = adaptive_lambda(cur_proj, A)
%
% A heuristic method of choosing an adaptive tikhonov regularization
% parameter.
%
std_Y = std(cur_proj);
std_A = std(A);
lambda1 = std_Y^2/sum((std_A-std_Y).^2);
lambda2 = lambda1/std(std_A);                        
lambda = (lambda1 + lambda2)/2;

