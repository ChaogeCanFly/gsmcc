%{
Copyright � 2019 Alexey A. Shcherbakov. All rights reserved.

This file is part of gsmcc.

gsmcc is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

gsmcc is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with sphereml. If not, see <https://www.gnu.org/licenses/>.
%}
%%
function [W] = mul_N_h(V)
    global no;
    global ns;
    global eb;
    global el;
    global MG;
    
    W = zeros(3*no*ns,1);
    N = 2^nextpow2(2*no-1);
    for k = 1:ns
        kk = (k-1)*3*no;
        ff = zeros(3,no);
        ta = zeros(4,N);
        
        ta(3,1:no) = V((kk+1):(kk+no),1);
        ff(1,:) = -ta(3,1:no);
        ta(1,1:no) = V((kk+no+1):(kk+2*no),1);
        ff(2,:) = -ta(1,1:no);
        ta(2,1:no) = V((kk+2*no+1):(kk+3*no),1);
        ff(3,:) = ta(2,1:no);
        
        ta = fft(ta,N,2);
        for i = 1:N
            ta(3,i) = ta(3,i)*MG(1,k,i);
        end
        ta(3,:) = ifft(ta(3,:),N);
        ff(1,:) = ff(1,:) + ta(3,1:no);
        
        for i = 1:N
            ta(3,i) = ta(1,i)*MG(2,k,i);
            ta(1,i) = ta(1,i)*MG(1,k,i);
            ta(4,i) = ta(2,i)*MG(2,k,i);
            ta(2,i) = ta(2,i)*MG(1,k,i);
        end
        ta = ifft(ta,N,2);
        ff(2,:) = ff(2,:) + (el(1,k)/eb)*ta(1,1:no);
        ff(3,:) = ff(3,:) - (eb/el(1,k))*ta(2,1:no);

        ta(:,no+1:N) = 0;
        ta = fft(ta,N,2);
        for i = 1:N
            ta(1,i) = (ta(1,i) - ta(4,i))*MG(2,k,i);
            ta(2,i) = (ta(2,i) + ta(3,i))*MG(2,k,i);
        end
        ta(1:2,:) = ifft(ta(1:2,:),N,2);
        ff(2,:) = ff(2,:) - ta(2,1:no);
        ff(3,:) = ff(3,:) - ta(1,1:no);

        W((kk+1):(kk+no),1) = ff(1,:);
        W((kk+no+1):(kk+2*no),1) = ff(2,:);
        W((kk+2*no+1):(kk+3*no),1) = ff(3,:);
    end
end

