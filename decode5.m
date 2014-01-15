function u_closest = decode5( y, G )
%DECODE5( y, G ) Lattice Decode
%   u_closest = DECODE5( y, G ) returns the indexes of the closest
%   lattice vector for a given lower triangular generator matrix G
%   and any row vector y.
%   (Algorithm 5 by A. Ghasemmehdi, E. Agrell)

% A. Ghasemmehdi, E. Agrell, “Faster Recursions in Sphere Decoding,”
% IEEE Trans. Inf. Theory, vol. 57, no. 6, pp. 3530–3536, June 2011.

n=size(G,1);

if ~isLowerTriangular(G) 
    error('decode:notTriangular',...
        'The input matrix has to be lower triangular')
end
if ~(rank(G)==n)
    error('decode:linearDependent',...
        'The input matrix has to be linearly independent')
end
if ~(length(y)==n)
    error('decode:dimensionMismatch',...
        'The input matrix and vector have to be of the same dimension')
end

%= Initialize =%
rho_n=Inf;
k=n+1;
d=zeros(1,n)+n;
dist(n+1)=0;
F(n,1:n)=y(1:n);

while(true) %LOOP_LABEL
    
    loop_down=true;
    while(loop_down)
        if(~(k==1))
            k=k-1;
            for a=d(k):-1:(k+1)
                F(a-1,k)=F(a,k)-u(a)*G(a,k);
            end
            p(k)=F(k,k)/G(k,k);
            u(k)=round(p(k));
            gamma=(p(k)-u(k))*G(k,k);
            step(k)=sgn(gamma);
            dist(k)=dist(k+1)+gamma^2;            
        else
            u_closest=u;
            rho_n=dist(1);
        end
        loop_down=(dist(k)<rho_n);
    end
    
    m=k;
    loop_up=true;
    while (loop_up)
        if (k==n)
            return;
        else
            k=k+1;
            u(k)=u(k)+step(k);
            step(k)=-step(k)-sgn(step(k));
            gamma=(p(k)-u(k))*G(k,k);
            dist(k)=dist(k+1)+gamma^2;
        end
        loop_up=(dist(k)>=rho_n);
    end

    d(m:+1:k-1)=k;
    for a=(m-1):-1:1
        if (d(a)<k)
            d(a)=k;
        else
            break;
        end
    end

end % GOTO LOOP_LABEL