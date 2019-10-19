function [newcenter] = computeCenter( centroids, dis, invertList)
ks = size(centroids,1);
ind = 0;
for c1=1:ks
    nonempty = find(~cellfun('isempty',invertList(c1,:)));
    for c2 =  nonempty
        ind = ind + 1;
        c3 = (centroids(c1,:)+centroids(c2,:))/2;
        newcenter = (centroids(c1,:)+c3)/2;
    end
end
ind
end