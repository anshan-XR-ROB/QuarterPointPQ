function [centers_table,distortion, R_qpq_np] = train_qpq_np(X, M, centers_table_init, R_init, num_iter_outer, num_iter_inner, filename)

% X: [nSamples, dim] training samples
% M: number of subspacs
k = 256; % fixed number of centers per subspaces (8 bits per subspaces)
dim = size(X, 2);
n = size(X,1);
d = dim / M;

R = R_init;
centers_table = centers_table_init;
spq_distortion_vec = zeros(1, num_iter_outer);

for iter_outer = 1:num_iter_outer

    Y = zeros(size(X));
    
    % line 3 in Algorithm 1
    Xproj = X*R; % pre-projecting X
    
    distortion = 0;  
    
    for m = 1:M
        Xsub = Xproj(:, (1:d) + (m-1)*d);
        [assign, centers] = litekmeans(double(Xsub), k, 'MaxIter', num_iter_inner, 'Start', double(centers_table{m}));        
        centers_table{m} = centers;
        
        % line 6 in Algorithm 1
        [idx, dist] = yael_nn (centers', Xsub', 2, 2);
        invertList = cell(k,k);
        for i=1:n
            invertList{idx(1,i),idx(2,i)}(end+1) = i;
        end
        [cost] = skmeansCost(single(centers),single(dist'),invertList);
        % compute distortion
        distortion = distortion + cost/n;

        % compute Y 
        %Ysub = centers(idx(1,:),:);
        Ysub = getCenters(single(centers),single(dist),invertList);
        Y(:, (1:d) + (m-1)*d) = Ysub;
    end

    fprintf('spq-np: iter: %d, distortion: %e\n', iter_outer, distortion);
    spq_distortion_vec(1, iter_outer) = distortion;
    R_qpq_np = R; % save the output R
    
    % line 8 in Algorithm 1 (update R)
    [U, ~, V] = svd(X'*Y);
    R = U * V';
end
save(filename, 'spq_distortion_vec');

end
