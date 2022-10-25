% function residual = MH_BCS_SPL_Test_Residual(x, y, phi_matrix, ...
%     true_measurement)
%
% Calculate residual using holdset in the projection domain.
% In the experiment, we have three measurements as a holdset y_holdout.
%
% x                 : input image
% y                 : measurements, y = [y_recovery y_holdout].
% phi_matrix        : random sampling matrix, phi_matrix = [phi_recovery phi_holdout]
% true_measurement  : number of measurements used in the CS recovery
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

function residual = MH_BCS_SPL_Test_Residual(x, y, phi_matrix, ...
    true_measurement)

residual = zeros(1,6);
yy = BCS_SPL_Encoder(x,phi_matrix);

o_y = y(true_measurement+1:end,:);
o_y_1 = o_y(1,:);
o_y_2 = o_y(2,:);
o_y_3 = o_y(3,:);

t_y = yy(true_measurement+1:end,:);
t_y_1 = t_y(1,:);
t_y_2 = t_y(2,:);
t_y_3 = t_y(3,:);

residual(1) = sum((o_y_1 - t_y_1).^2) ./ sum(o_y_1.^2);
residual(2) = sum((o_y_2 - t_y_2).^2) ./ sum(o_y_2.^2);
residual(3) = sum((o_y_3 - t_y_3).^2) ./ sum(o_y_3.^2);
residual(4) = sum((o_y_1 - t_y_1).^2);
residual(5) = sum((o_y_2 - t_y_2).^2);
residual(6) = sum((o_y_3 - t_y_3).^2);
