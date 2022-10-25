% function final_image = MH_MS_BCS_SPL_Residual_Reconstruction(y, Phi, ...
%     subrates, num_levels, predicted_image)
%
% Perform residual reconstruction using MS-BCS-SPL
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
%

function final_image = MH_MS_BCS_SPL_Residual_Reconstruction(y, Phi, ...
    subrates, num_levels, predicted_image)

[num_rows num_cols] = size(predicted_image);
y_predicted = MS_BCS_SPL_Encoder(predicted_image, Phi);
y_residual = cell(1,num_levels+1);
y_residual{1} = y{1} - y_predicted{1};

for j = 1:num_levels
    for dir = 1:3
        y_residual{j+1}{dir} = y{j+1}{dir} - y_predicted{j+1}{dir};
    end
end

reconstructed_residual = MS_BCS_SPL_DDWT_Decoder(y_residual, Phi, ...
    subrates, num_rows, num_cols, (num_levels+1), 1);
final_image = predicted_image + reconstructed_residual;
