%% MNIST 784D
% load('data/mnist-train.mat');
% X_train = single(X');
%% MNIST 50D
% A = rand(784,784);
% B = orth(A);
% C = B(:,1:50);
% X_train = double(X_train) * C;
%% covtype dataset
% load('data/covtype.mat');
% X_train = X;
%% random dataset
X_train = single(rand(10000,1000));

n  = size(X_train,1);
d  = size(X_train,2);
num_iter = 20;

ncenters = [10];% 3 10 50 100 200];
for k = ncenters
    %kmeans clustering
    tStart = tic;
    [~, centers] = litekmeans(X_train, k, 'MaxIter', 1);
    kmeans_distortion_vec = zeros(1, num_iter);
    for iter = 1:num_iter
        if iter ~= 1
            [~, centers] = litekmeans(X_train, k, 'MaxIter', 1, 'Start', centers);
        end
        %kmeans distortion
        dist = sqdist(centers', X_train');
        [dist, idx] = min(dist);
        distortion = mean(dist);
        kmeans_distortion_vec(1,iter) = distortion;
    end
    % figure('color','w');
    % scatter(centers(:,1), centers(:,2), 60, 'r', 'fill');
    % hold on;
    time_kmeans = toc(tStart);
    fprintf('kmeans distortion: max iters: %d, distortion: %e, time: %e\n', num_iter, distortion, time_kmeans);
    
    %v-kmeans clustering
    tStart = tic;
    [assign, centers] = litekmeans(X_train, k, 'MaxIter', 1);
    skmeans_distortion_vec = zeros(1, num_iter);
    % scatter(X_train(:,1), X_train(:,2), 10, 'k');
    % hold on;
    for iter =1:num_iter
        if iter ~= 1
            [assign, centers] = litekmeans(X_train, k, 'MaxIter', 1, 'Start', centers);
        end
        [idx, dist] = yael_nn(centers', X_train', 2, 2);
        invertList = cell(k,k);
        for i=1:n
            invertList{idx(1,i),idx(2,i)}(end+1) = i;
        end
%        %% compute new center
%         [newcenter] = computeCenter(single(centers),single(dist'),invertList); 
%        
       %% compute distortion
        [cost] = skmeansCost(single(centers),single(dist'),invertList);
        distortion = cost / n;
        skmeans_distortion_vec(1,iter) = distortion;
%             scatter(centers(:,1), centers(:,2), 20, 'r');
%             pause;
    end
    time_vkmeans = toc(tStart);
    fprintf('s-kmeans distortion: max iters: %d, distortion: %e, time: %e\n', num_iter, distortion, time_vkmeans);
    
    figure('color','w');
    plot(kmeans_distortion_vec,'r', 'LineWidth', 2);
    hold on;
    plot(skmeans_distortion_vec,'b', 'LineWidth', 2);
    hold on;
    set(gca,'XTick', [0:1:num_iter]);
    xlabel('Iterations','FontSize',16);
    ylabel('Distortion','FontSize',16);
    title(['MNIST:D=', num2str(d), ' N=', num2str(n), ' k=', num2str(k)],'FontSize',16);
    legend('Kmeans','S-Kmeans',0);
    
end
