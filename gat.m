function z = gat(f,alpha,sigma,g)
if alpha == 0
    z = f;
else
    for i = 1:size(f,3)
        z(:,:,i) = 2./alpha.*(sqrt(alpha.*f(:,:,i) + 3./8.*alpha.^2 + sigma.^2 - alpha.*g));
    end
z = real(z);
end