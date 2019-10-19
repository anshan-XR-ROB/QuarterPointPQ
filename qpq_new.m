% QPQ_new
function pq = qpq_new(nsq, v)

n = size (v, 2);     % number of vectors in the training set
d = size (v, 1);     % vector dimension
ds = d / nsq;        % dimension of the subvectors to quantize
nsqbits = 8;         % the number of subquantizers is fixed to 8 in this implementation
ks = 2^nsqbits;      % number of centroids per subquantizer

pq.nsq = nsq;
pq.ks = ks;
pq.ds = ds;
pq.centroids = cell (nsq, 1);

for q = 1:nsq
    vs = v((q-1) * ds + 1 : q *ds, :);
    %[centroids_tmp,~] = vl_kmeans(vs, ks, 'algorithm', 'elkan','NumRepetitions',100) ;
    [assign, centroids_tmp, ~, ~, D] = litekmeans(double(vs'),ks,'MaxIter',100);
    pq.centroids{q} = centroids_tmp';
end

end
