function [ ids ] = qpq_search( pq, nbase, invertList, nonemptycell, centerDist, vquery, topk)
nq = size(vquery, 2);
ids = zeros(nq, topk, 'single');
distab  = zeros (pq.ks, pq.nsq, 'single');
DistTable = zeros(pq.nsq,pq.ks,pq.ks);
for n = 1:nq
    for q=1:pq.nsq
        vsub = vquery((q-1)*pq.ds+1:q*pq.ds, n);
        distab (:,q) = yael_L2sqr (single(vsub), single(pq.centroids{q}))';
        for c1=1:pq.ks
            nonempty = nonemptycell{q,c1};
            d = [centerDist{c1,nonempty,q}];
            n_c2 = size(nonempty,2);
            d1 = repmat(distab(c1,q),1,n_c2);
            d2 = distab(nonempty,q)';
            n1 = ones(1,n_c2);
            P = [d1; d2; n1];
            a1 = repmat(0.75,1,n_c2);
            a2 = repmat(0.25,1,n_c2);
            A = [a1; a2; -3/16*d];
            dTable = sum(A.*P);
            DistTable(q,c1,nonempty)=dTable;
        end
    end
    dist_res = zeros(nbase,1,'single');
    for q = 1:pq.nsq
        for c1=1:pq.ks
            index  = 1;
            nonempty = nonemptycell{q,c1};
            for c2 =  nonempty
                xidx = invertList{c1,c2,q};
                dist_res(xidx) = dist_res(xidx) + DistTable(q,c1,c2);
                index = index + 1;
            end
        end
    end
    [~,ids(n,:)] = yael_kmin (dist_res, topk);
end
