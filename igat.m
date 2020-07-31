function z = igat(f,alpha,sigma,g)
if alpha == 0
    z = f;
else
    for i = 1:size(f,3)
        z(:,:,i) = alpha./4.*f(:,:,i).^2 - 3./8.*alpha - sigma.^2./alpha + g;
    end
z = real(z);
end