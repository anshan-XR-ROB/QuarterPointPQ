function [ cost ] = calcDistortion( dis,d)
P = [dis ones(size(dis,1),1)];
A = [0.75; 0.25; -3/16*d];
% A = [1; 0; 0]; %using nearest center
disTable = P*A;
cost = 0.0;
for n=1:size(dis,1)
    cost = cost+disTable(n,1);
end

end
