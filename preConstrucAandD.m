% construct A and D
function [ A, D ] = preConstrucAandD(pq)
    nsq = pq.nsq; 
    A = cell(1,nsq);
    D = cell(1,nsq);
    for j=1:nsq
        centroid = pq.centroids{j};
        d = pdist2(centroid,centroid);
        A{1,j} = [0.75; 0.25; -3/16*d];
        D{1,j} = d;
    end
end