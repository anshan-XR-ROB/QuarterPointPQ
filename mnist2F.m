addpath('../yael_v401/matlab/');
load('data/mnist-train.mat');
X_train = single(X);
X_base = single(X);
load('data/mnist-test.mat');
X_query = single(X);

fvecs_write('data/mnist_learn.fvecs', X_train);
fvecs_write('data/mnist_base.fvecs', X_base);
fvecs_write('data/mnist_query.fvecs', X_query);

load('data/mnist_gnd.mat');
ids_gnd = ids_gnd-1;
ivecs_write('data/gist_groundtruth.ivecs', ids_gnd);

fprintf('Done!');


