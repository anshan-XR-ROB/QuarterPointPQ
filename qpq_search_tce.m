function [ ids ] = qpq_search_tce( pq, nbase, invertList, codeList, nonemptycell, centerDist, vquery, topk)
nq = size(vquery, 2);
ids = zeros(nq, topk, 'single');
%distab  = zeros (pq.ks, pq.nsq, 'single');
parfor n = 1:nq
    n
    distab  = zeros (pq.ks, pq.nsq, 'single');
    dist_res = zeros(nbase,1,'single');
    for q = 1:pq.nsq
        vsub = vquery((q-1)*pq.ds+1:q*pq.ds, n);
        distab (:,q) = yael_L2sqr (single(vsub), single(pq.centroids{q}))';
        for c1=1:pq.ks
            nonempty = nonemptycell{q,c1};
            d = [centerDist{c1,nonempty,q}];
            n_c2 = size(nonempty,2);    
            if(n_c2 ==0)
                continue;
            end
            d1 = repmat(distab(c1,q),1,n_c2);
            d2 = distab(nonempty,q)';
            n1 = ones(1,n_c2);
            dTable = zeros(3,n_c2);
            %c4
            P = [d1; d2; n1];
            a1 = repmat(0.75,1,n_c2);
            a2 = repmat(0.25,1,n_c2);
            A = [a1; a2; -0.1875*d];
            dTable(3,:) = sum(A.*P);
            %c3
            a1 = repmat(0.5,1,n_c2);
            a2 = repmat(0.5,1,n_c2);
            A = [a1; a2; -0.25*d];
            dTable(2,:) = sum(A.*P);
            %c1
            dTable(1,:) = d1;
            
            index  = 1;
            for c2 =  nonempty
                xidx = invertList{c1,c2,q};
                code = codeList{c1,c2,q};
                index2 = 1;
                for idx = xidx
                    cur_code = code(index2);
                    dist_res(idx) = dist_res(idx) + dTable(cur_code+1,index);
                    index2 = index2 + 1;
                end
                index = index + 1;
            end
        end
    end
    [~,ids(n,:)] = yael_kmin (dist_res, topk);
end
