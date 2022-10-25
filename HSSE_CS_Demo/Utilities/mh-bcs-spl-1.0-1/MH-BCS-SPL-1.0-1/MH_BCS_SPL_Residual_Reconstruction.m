% function X_mh = MH_BCS_SPL_Residual_Reconstruction(P_mh, Y, Phi, ...
%     num_rows, num_cols, L)
%
% Perform residual reconstruction using BCS-SPL
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

function X_mh = MH_BCS_SPL_Residual_Reconstruction(P_mh, Y, Phi, ...
    num_rows, num_cols, L)

Y_mh_residual = Y - BCS_SPL_Encoder(P_mh, Phi);

R_mh = BCS_SPL_DDWT_Decoder(Y_mh_residual, Phi, num_rows, num_cols, ...
    L, 1);

X_mh = R_mh + P_mh;

return
