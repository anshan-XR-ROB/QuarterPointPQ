% QPQ assign
function [invertList, nonemptycell, centerDist] = qpq_assign (pq, v)

n = size (v, 2);
d = size (v, 1);
%c = zeros (pq.nsq, n, 'uint8');
invertList = cell(max(pq.ks), max(pq.ks), pq.nsq);
centerDist = cell(max(pq.ks), max(pq.ks), pq.nsq);
nonemptycell = cell(pq.nsq, max(pq.ks)); 
% process separately each subquantizer
for q = 1:pq.nsq 
    % find the nearest centroid for each subvector
    vsub = v((q-1)*pq.ds+1:q*pq.ds, :);
    [c_idx, c_dist] = yael_nn(single(pq.centroids{q}), single(vsub), 2, 2);
    %c(q, :) = c_idx(1,:) - 1;
    idx = single(c_idx);
    for i=1:size(idx,2)
        invertList{idx(1,i),idx(2,i),q}(end+1) = i;
    end
    list = invertList(:,:,q);
    for c1 = 1:pq.ks
        nonempty =find(~cellfun('isempty', list(c1,:)));
        nonemptycell{q,c1} = int32(nonempty);
    end
    centroid = pq.centroids{q};
    for c1 = 1:pq.ks
        nonempty = nonemptycell{q,c1};
        for c2 =  nonempty
            %quarterPoint{c1,c2,q} = (centroid(:,c1) + (centroid(:,c1) + centroid(:,c2))/2)/2;
            centerDist{c1,c2,q} = sum((centroid(:,c1)-centroid(:,c2)).*(centroid(:,c1)-centroid(:,c2)));
        end
    end
end

end
