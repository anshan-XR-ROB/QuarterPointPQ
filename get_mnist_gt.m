%get_mnist_gt
addpath ('../yael_v401/matlab');

load('data/mnist-train.mat');
% 60000*784
X_base = single(X);
load('data/mnist-test.mat');
X_query = single(X);
% compute ids_gnd
[ids_gnd, dis] = yael_nn (X_base, X_query, 100, 2);
save('mnist_gnd.mat', 'ids_gnd');
