function n = normTV(x,lam)

g = D(x);
gx = abs(g(:,:,1));
gy = abs(g(:,:,2));

n = lam * sum(gx(:)) + lam * sum(gy(:));



function v = norm1(x)
    v = norm(x(:),1);
end

end
