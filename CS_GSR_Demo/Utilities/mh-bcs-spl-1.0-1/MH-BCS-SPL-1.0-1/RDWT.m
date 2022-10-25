% function W = RDWT(x, L)
% 
% Computes the poor-mans stationary wavelet through
% multi-phase analysis
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

% Written by E. W. Tramel

function W = RDWT(x, L)

queue{1} = x;

for l=(L+1):-1:2
    new_queue = cell(1,1);
    Npn = 1;
    
    for p=1:length(queue)
        y = queue{p};
        
        [num_rows num_cols] = size(y);

        hr = num_rows/2;
        hc = num_cols/2;
        
        % Calculate phase pyramids
        wee = phase_wavelet(y,'ee');
        weo = phase_wavelet(y,'eo');
        woe = phase_wavelet(y,'oe');
        woo = phase_wavelet(y,'oo');
        
        % Pass the basebands to be processed at the next level
        new_queue{Npn}   = wee(1:hr,1:hc);
        new_queue{Npn+1} = weo(1:hr,1:hc);
        new_queue{Npn+2} = woe(1:hr,1:hc);
        new_queue{Npn+3} = woo(1:hr,1:hc);
        
        % Set the values at this level
        % Horziontal
        W{l}{1}{Npn}   = wee(1:hr,(hc+1):num_cols);
        W{l}{1}{Npn+1} = weo(1:hr,(hc+1):num_cols);
        W{l}{1}{Npn+2} = woe(1:hr,(hc+1):num_cols);
        W{l}{1}{Npn+3} = woo(1:hr,(hc+1):num_cols);
        
        % Vertical
        W{l}{2}{Npn}    = wee((hr+1):num_rows,1:hc);
        W{l}{2}{Npn+1}  = weo((hr+1):num_rows,1:hc);
        W{l}{2}{Npn+2}  = woe((hr+1):num_rows,1:hc);
        W{l}{2}{Npn+3}  = woo((hr+1):num_rows,1:hc);
        
        % Diagonal
        W{l}{3}{Npn}   = wee((hr+1):num_rows,(hc+1):num_cols);
        W{l}{3}{Npn+1} = weo((hr+1):num_rows,(hc+1):num_cols);
        W{l}{3}{Npn+2} = woe((hr+1):num_rows,(hc+1):num_cols);
        W{l}{3}{Npn+3} = woo((hr+1):num_rows,(hc+1):num_cols);
        
        Npn = Npn + 4;
    end
 
    queue = new_queue;
end

W{1} = queue;

function w = phase_wavelet(x, phase)
[num_rows num_cols] = size(x);
switch phase
    case 'eo'
        x = [x(:,2:num_cols) x(:,1)];
    case 'oe'
        x = [x(2:num_rows,:); x(1,:)];
    case 'oo'
        x = [x(:,2:num_cols) x(:,1)];
        x = [x(2:num_rows,:); x(1,:)];
end

w = waveletcdf97(x, 1);


