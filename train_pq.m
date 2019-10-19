function [centers_table, idx_table, distortion] = train_pq(X, M, num_iter)

% X: [nSamples, dim] training samples
% M: number of subspacs
k = 256; % fixed number of centers per subspaces (8 bits per subspaces)
dim = size(X, 2);
d = dim / M;
%num_iter = 100;

centers_table = cell(M, 1);
idx_table = zeros(size(X, 1), M);

distortion = 0;
for m = 1:M
    fprintf('subspace #: %d', m);
    Xsub = X(:, (1:d) + (m-1)*d);
    
%     opts = statset('Display','off','MaxIter',num_iter);
%     [~, centers] = kmeans(Xsub, k, 'Options', opts, 'EmptyAction', 'singleton');
    [centers,~] = vl_kmeans(Xsub', k, 'algorithm', 'elkan','NumRepetitions',1) ;
    centers_table{m} = centers';
    
    dist = sqdist(centers, Xsub');
    [dist, idx] = min(dist);
    idx_table(:,m) = idx(:);
    
    % compute distortion
    dist = mean(dist);
    distortion = distortion + dist;
    
    fprintf('    distortion in this subspace: %e\n', dist);
end

end
