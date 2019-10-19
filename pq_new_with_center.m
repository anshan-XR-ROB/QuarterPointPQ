% Construct ANN pq codes from a learning set
% This structure is used in particular by the ADC version
% 
% Usage: pq = pq_new (nsq,  v)
% where
%   nsq      number of subquantizers (parameter m in the paper)
%   v        the set of vectors used for learning the structure
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software. 
% See http://www.cecill.info/licences.en.html
%
% This package was written by Herve Jegou
% Copyright (C) INRIA 2009-2011
% Last change: February 2011. 
function pq = pq_new (nsq, v, centers_table_opq_np)

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
%     [centroids_tmp, dis, assign] = yael_kmeans (vs, ks, 'niter', 100, 'verbose', 0);
%    [centroids_tmp,~] = vl_kmeans(vs, ks, 'algorithm', 'elkan','NumRepetitions',100) ;
    [~, centroids_tmp, ~, ~, ~] = litekmeans(double(vs'),ks,'Start', double(centers_table_opq_np{q}),'MaxIter',100);
    pq.centroids{q} = centroids_tmp';
end
