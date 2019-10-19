function [costTotal] = skmeansCost( centroids, dis, invertList)
ks = size(centroids,1);
costTotal = 0.0;

for c1=1:ks
    nonempty = find(~cellfun('isempty',invertList(c1,:)));
    cost = 0.0;
    for c2 =  nonempty
        d = sum((centroids(c1,:)-centroids(c2,:)).*(centroids(c1,:)-centroids(c2,:)));
        xidx = invertList{c1,c2};
        if ~isempty(xidx)
            cost_t = calcDistortion(dis(xidx,:),d);
            cost = cost + cost_t;
        end
    end
    costTotal = costTotal + cost;
end

end

