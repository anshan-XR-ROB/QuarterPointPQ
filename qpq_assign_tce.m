% QPQ assign
function [invertList, codeList, nonemptycell, centerDist] = qpq_assign_tce(pq, v)

n = size (v, 2);
d = size (v, 1);
% c = zeros (pq.nsq, n, 'uint8');
invertList = cell(max(pq.ks), max(pq.ks), pq.nsq);
%quarterPoint = cell(max(pq.ks), max(pq.ks), pq.nsq);
centerDist = cell(max(pq.ks), max(pq.ks), pq.nsq);
nonemptycell = cell(pq.nsq, max(pq.ks)); 
codeList = cell(max(pq.ks), max(pq.ks), pq.nsq);
% process separately each subquantizer
sum_d1 = 0;
sum_d4 = 0;
for q = 1:pq.nsq 
    % find the nearest centroid for each subvector
    vsub = v((q-1)*pq.ds+1:q*pq.ds, :);
    [c_idx, c_dist] = yael_nn (single(pq.centroids{q}), single(vsub), 2, 2);
%     c(q, :) = c_idx(1,:) - 1;
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
            middlePoint = (centroid(:,c1) + centroid(:,c2))/2;
            quarterPoint = (centroid(:,c1) + middlePoint)/2;
            centerDist{c1,c2,q} = sum((centroid(:,c1)-centroid(:,c2)).*(centroid(:,c1)-centroid(:,c2)));
            %get codes
            list_v = invertList(c1,c2,q);
            for i=1:size(list_v{1,1},2)
                index = list_v{1,1}(1,i);
                d1 = c_dist(1,index);
                d2 = c_dist(2,index);
                d3 = 0.5*d1 + 0.5*d2-0.25*centerDist{c1,c2,q}; %sum((vsub-middlePoint).*(vsub-middlePoint));
                d4 = 0.75*d1 + 0.25*d2-0.1875*centerDist{c1,c2,q};
                code = 0;
                if(d1<d4) code = 0; end
                if(d4<d1 && d4<d3) code = 1; end
                if(d3<d4) code = 2; end
                %if(d1<d4) 
                %  code = 0; 
                %  sum_d1 = sum_d1+1;
                %else
                %  code = 1;
                %  sum_d4 = sum_d4+1;
                %end
                codeList{c1,c2,q}(end+1) = code;
            end
        end
    end
end

%fprintf('d1 = %d, d4 = %d\n', sum_d1, sum_d4);

end
