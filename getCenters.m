function [ Y ] = getCenters( centroids,dis,invertList )
    ks = size(invertList);
    n = size(dis,1);
    dim = size(centroids,2);
    Y = zeros(n,dim);
    for c1=1:ks(1)
        nonempty = find(~cellfun('isempty',invertList(c1,:)));
        for c2 = nonempty
             xidx = invertList{c1,c2};
             %Y(xidx,:) = repmat(centroids(c1,:),length(xidx),1);
             Y(xidx,:) = repmat(0.75*centroids(c1,:)+0.25*centroids(c2,:),length(xidx),1); %use this is better
        end
    end
end

