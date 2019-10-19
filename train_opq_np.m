function [centers_table, idx_table, distortion, R_opq_np] = train_opq_np(X, M, centers_table_init, R_init, num_iter_outer, num_iter_inner, filename)

% X: [nSamples, dim] training samples
% M: number of subspacs
k = 256; % fixed number of centers per subspaces (8 bits per subspaces)
dim = size(X, 2);
d = dim / M;
idx_table = zeros(size(X, 1), M);

R = R_init;
centers_table = centers_table_init;
opq_distortion_vec = zeros(1, num_iter_outer);
for iter_outer = 1:num_iter_outer
    
    Y = zeros(size(X));
    
    % line 3 in Algorithm 1
    Xproj = X*R; % pre-projecting X
    
    distortion = 0;  
    for m = 1:M
        Xsub = Xproj(:, (1:d) + (m-1)*d);
        
        % line 5 in Algorithm 1
%         opts = statset('Display','off','MaxIter',num_iter_inner);
%         [~, centers] = kmeans(Xsub, k, 'Options', opts, 'Start', centers_table{m}, 'EmptyAction', 'singleton');
        [~, centers] = litekmeans(double(Xsub), k, 'MaxIter', num_iter_inner, 'Start', double(centers_table{m}));
        centers_table{m} = centers;
        
        % line 6 in Algorithm 1
        dist = sqdist(centers', Xsub');
        [dist, idx] = min(dist);
        idx_table(:,m) = idx(:);
        
        % compute distortion
        dist = mean(dist);
        distortion = distortion + dist;
        
        % compute Y      
        centers_t = centers; 
        Ysub = centers_t(idx(:),:);
        Y(:, (1:d) + (m-1)*d) = Ysub;
    end
    opq_distortion_vec(1, iter_outer) = distortion;
    fprintf('opq-np: iter: %d, distortion: %e\n', iter_outer, distortion);
    R_opq_np = R; % save the output R
    % line 8 in Algorithm 1 (update R)
    [U, S, V] = svd(X'*Y);
    R = U * V';
end
%save(filename, 'opq_distortion_vec');
end
